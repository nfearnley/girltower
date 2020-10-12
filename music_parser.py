import re
from collections import defaultdict

class ParseError(Exception):
    def __init__(self, classname, s):
        super().__init__(f"Unable to parse {classname}: {s!r}")


class NoteParseError(Exception):
    def __init__(self, s):
        super().__init__("Note", s)

class PitchParseError(Exception):
    def __init__(self, s):
        super().__init__("Pitch", s)

def padded_hex(num, width):
    hex_str = hex(num)[2:]
    num_hex_chars = len(hex_str)
    extra_zeros = "0" * (width - num_hex_chars)
    return extra_zeros + hex_str

class Track:
    def __init__(self, tracknum, notes):
        self.tracknum = tracknum
        self.notes = sorted(notes)
        group_notes = {}
        for note in self.notes:
            group_start = int(note.start / 32) * 32
            if group_start not in group_notes:
                group_notes[group_start] = []
            group_notes[group_start].append(note)
        self.groups = sorted(Group(num, notes) for num, notes in group_notes.items())

        next_letter = "A"
        for group in self.groups:
            for other in self.groups:
                if group == other and other.letter != "?":
                    group.letter = other.letter
                    break
            if group.letter == "?":
                group.letter = next_letter
                next_letter = chr(ord(next_letter) + 1)

    def to_pico8(self):
        for group in self.groups:
            print(f"# {group.groupnum}")
            curr = 0
            for note in group.notes:
                if note.group_start > curr:
                    print("\n".join(["-"] * int(note.group_start - curr)))
                print("\n".join([note.pitch] * note.duration))
                curr = note.group_end
            if curr < 32:
                print("\n".join(["-"] * int(curr - 32)))

    def __eq__(self, other):
        return self.notes == other.notes

    def __lt__(self, other):
        return self.tracknum < other.tracknum

    def __str__(self):
        return "\n".join(str(n) for n in self.notes)

class Group:
    def __init__(self, start, notes):
        self.start = start
        self.notes = notes
        self.letter = "?"

    @property
    def pico8_hex(self):
        # M = MODE (0 = SFX, 1 = Tracker)
        # SS = SPEED
        # BB = LOOP START
        # EE = LOOP END
        # NNNNN = NOTE
        #0MSSBBEENNNNN....
        mode = 1
        speed = 23
        loopstart = 0
        loopend = 0
        hex_out = padded_hex((mode << 24) + (speed << 16) + (loopstart << 8) + loopend, 8)

        prev_end = 0
        for note in self.notes:
            # Add leading padding before each note
            hex_out += "00000" * int(note.group_start - prev_end)
            # Add note
            hex_out += note.pico8_hex
            prev_end = note.group_end
        # Add trailing padding
        hex_out += "00000" * int(32 - prev_end)
        return hex_out

    @property
    def groupnum(self):
        return ord(self.letter)-65+50

    def __eq__(self, other):
        return self.notes == other.notes

    def __lt__(self, other):
        return self.start < other.start

    def __str__(self):
        comment = f"# {self.letter} {int(self.start/32 + 1)} {self.start}\n"
        return comment + "\n".join(str(n) for n in self.notes)

class Note:
    REGEX = re.compile(r"(\d+(?:\.\d+)?) ([A-G]#?\d) (\d+) (\d+)")
    def __init__(self, start, pitch, duration, tracknum):
        self.start = start
        self.pitch = pitch
        self.duration = duration
        self.tracknum = tracknum

    @property
    def end(self):
        return self.start + self.duration

    @property
    def group_start(self):
        return self.start % 32

    @property
    def group_end(self):
        out = self.end % 32
        return out if out else 32

    @property
    def pico8_hex(self):
        pitch_hex = self.pitch.pico8_hex
        ending_pitch_hex = pitch_hex[:-1] + "5"
        return self.pitch.pico8_hex * (self.duration - 1) + ending_pitch_hex

    def __str__(self):
        return f"{self.start:g} {self.pitch} {self.duration}"

    def __lt__(self, other):
        return self.start < other.start

    def __eq__(self, other):
        return (
            self.group_start == other.group_start
            and self.duration == other.duration
            and self.pitch == other.pitch
        )

    @classmethod
    def parse(cls, s):
        m = cls.REGEX.match(s)
        if not m:
            raise NoteParseError(s)
        start, pitchstr, duration, tracknum = m.groups()
        start = float(start)
        duration = int(duration)
        tracknum = int(tracknum)
        pitch = Pitch.parse(pitchstr, offset=-2)
        return Note(start, pitch, duration, tracknum)

class Pitch:
    REGEX = re.compile(r"([A-G]#?)(\d)")
    NOTE_LIST = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    def __init__(self, notenum, octave):
        self.notenum = notenum
        self.octave = octave

    @property
    def pico8_num(self):
        return self.octave * 12 + self.notenum

    @property
    def pico8_hex(self):
        # PP = PITCH (C0 = 0, ...)
        # I = INSTRUMENT
        # V = VOLUME
        # E = EFFECT
        # NNNNN = PPIVE
        pitch = self.pico8_num
        instr = 7
        volume = 1
        effect = 0
        out_hex = padded_hex((pitch << 12) + (instr << 8) + (volume << 4) + effect, 5)
        return out_hex

    @property
    def note(self):
        return self.NOTE_LIST[self.notenum]

    def __str__(self):
        return f"{self.note}{self.octave}"
    
    def __lt__(self, other):
        return self.pico8_num < other.pico8_num

    def __eq__(self, other):
        return (
            self.notenum == other.notenum
            and self.octave == other.octave
        )

    @classmethod
    def parse(cls, s, offset=0):
        m = cls.REGEX.match(s)
        if not m:
            raise PitchParseError(s)
        notestr, octave = m.groups()
        notenum = cls.NOTE_LIST.index(notestr)
        octave = int(octave)
        octave += offset # Offset the octave by an amount
        return Pitch(notenum, octave)

def loadTracks(data):
    # Load each of the "lines"
    _, _, data = data.split("|")
    lines = data.split(";")
    # Remove extra spacing
    lines = [line.strip() for line in lines]
    # Remove blank lines
    lines = [line for line in lines if line]
    # Remove comments
    lines = [line for line in lines if not line.startswith("#")]

    # Parse to notes
    notes = [Note.parse(line) for line in lines]

    # Remove zero-duration notes (I don't even understand how the sequencer has these)
    notes = [note for note in notes if note.duration > 0]

    # Split notes into tracks
    track_notes = defaultdict(list)
    for note in notes:
        track_notes[note.tracknum].append(note)
    tracks = [Track(num, notes) for num, notes in track_notes.items()]
    tracks.sort()

    return tracks

def exportTrack(track):
    outfile = f"track{track.tracknum}.txt"
    with open(outfile, "w") as f:
        print(track, file=f)
    print(f"Done writing {outfile!r}")

def exportSfx(track):
    music = ",".join(str(group.groupnum) for group in track.groups)
    unique_groups = {}
    for group in track.groups:
        unique_groups[group.letter] = group
    outfile = f"sfx{track.tracknum}.txt"
    with open(outfile, "w") as f:
        print(music, file=f)
        print("__sfx__", file=f)
        for group in sorted(unique_groups.values()):
            print(group.pico8_hex, file=f)
    print(f"Done writing {outfile!r}")

def main():
    # Load tracks
    with open("tracks.txt", "r") as f:
        data = f.read()
    tracks = loadTracks(data)
    # Export tracks
    #for track in tracks:
    #    exportTrack(track)

    main_track = next(track for track in tracks if track.tracknum == 16)
    exportSfx(main_track)
    

if __name__ == "__main__":
    main()
