pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- girl tower
-- by natalie fearnley

function _init()
  x=8
  y=9
  p_one=8
  p_two=12
  music(0)
end

function _update()
  if btnp(⬅️) and x > 0 then
    x-=8
  elseif btnp(➡️) and x < 128 then
   	x+=8
  end
  if btnp(⬆️) and y > 0 then
    y-=8
  elseif btnp(⬇️) and y < 128 then
   	y+=8
  end
  if btnp(🅾️) then
    p_one=(p_one+1)%16
  end
  if btnp(❎) then
    p_two=(p_two+1)%16
  end
end

function _draw()
  cls()
  map(0,0,0,0,8,8)
  pal(12,col)
  pal(8,p_one)
  pal(12,p_two)
  spr(3,x,y)
  pal()
  print(p_one)
  print(p_two)
end

__gfx__
00000000005dd5000000000000855c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005dd50000000000058ddc50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700005dd50055555555055dd550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000005dd500dddddddd05d55d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000005dd5005555555505dddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700005dd500dddddddd05dddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005dd500dddddddd05dddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005dd5005555555500055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dddddddddddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd555555dd555555dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd5dddd5dd5dddd5dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd5dddd5dd5dddd5dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd555555dd555555dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd500005dd500005dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd500005dd500005dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd555555dd555555dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dddddddddddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd555555dd555555dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd5dddd5dd5dddd5dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd5dddd5dd5dddd5dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd555555dd555555dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd500005dd500005dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd500005dd500005dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd555555dd555555dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dddddddddddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dddddddddddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dddddddddddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010021102120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020022102220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0030023102320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0002000000750007500075000750187501875015700167000e7000c7000e7000e7001b7001b7001b7001b7001b7001a7001a7001a7001a7001a7001a7001a7001a70000000000000000000000000000000000000
00040000185501d5502a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01280010005051f5151a5151f515005051f5151a5151f515005052651521515265150050526515215152651500505005050050500505005050050500505005050050500505005050050500505005050050500505
0128001013010130121301213012130121301213012130151a0101a0121a0121a0121a0121a0121a0121a01500005000050000500005000050000500005000050000500005000050000500005000050000500005
01280020000052b0153201032015300152e0152d0152b0152901029012290152b0152e0152d0152b015290152b0102b0152e0102e0152d0152b01529015280152901029012290152b0152e0152d0152b01529015
012800102b0102b0152e0102e0152d0102d0152b0102b0152a0102a0122a0122a0150040500405004050040500405004050040500405004050040500405004050040500405004050040500405004050000500000
012800103201032015350103501534010340153201032015310103101231012310150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 02030444
02 02030506

