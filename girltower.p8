pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- girl tower
-- by natalie fearnley

function _init()
  towers={tower:new({x=35,y=35})}
  enemies={}
  effects={}
  music(0)
end

function _update()
  if btnp(⬅️) and curs.x > 0 then
    curs.x-=1
  elseif btnp(➡️) and curs.x < 15 then
   	curs.x+=1
  end
  if btnp(⬆️) and curs.y > 0 then
    curs.y-=1
  elseif btnp(⬇️) and curs.y < 15 then
   	curs.y+=1
  end
  if btnp(❎) then
  	--add(towers, tower:new(t))
  	add(enemies, enemy:new())
  end
  for tow in all(towers) do
   tow:update()
  end
  for enem in all(enemies) do
   enem:update()
  end
  for eff in all(effects) do
   eff:update()
  end
  curs:update()
end

function _draw()
  cls()
  map(0,16,0,0,16,16)
  map(0,0,0,0,16,16)
  for tow in all(towers) do
   tow:draw()
  end
  for enem in all(enemies) do
   enem:draw()
  end
  for eff in all(effects) do
   printh(rnd())
   eff:draw()
  end
  curs:draw()
  print("xp: "..game.xp,96,0)
  print("hp: "..game.hp,96,6)
end

-->8
-- tower
tower = {}
tower.__index = tower

function tower:new(args)
 args = args or {}
 o = setmetatable({}, self)
 o.x = args.x or 0
 o.y = args.y or 0
 o.p_one = nildef(args.p_one, 8)
 o.p_two = nildef(args.p_two, 12)
 o.target = nil
 o.cooldown = 0
 o.range = nildef(args.range, 24)
 return o
end

function tower:update()
	self.cooldown = max(0,self.cooldown-1)
 self:updatetarget()
 self:fire()
end

function tower:fire()
 if (self.target == nil) return
 if (self.cooldown > 0) return
 self.target:hit(150)
 self.cooldown = 10
 z = zap:new({x1=self.x,y1=self.y,x2=self.target.x,y2=self.target.y})
 add(effects, z)
 printh(z)
end

function tower:draw()
	pal(8,self.p_one)
 pal(12,self.p_two)
 spr(4,self.x-3,self.y-3)
	pal()
end

function tower:updatetarget()
 if not self:inrange(self.target) then
  self.target = nil
 end
 if self.target ~= nil then
  return
 end
	for e in all(enemies) do
	 if self:inrange(e) then
	  self.target = e
	  break
	 end
	end
end

function tower:inrange(other)
 if other == nil then
  return false
 end
 if not other.alive then
  return false
 end
 if abs(self.x-other.x) > self.range then
  return false
 end
 if abs(self.y-other.y) > self.range then
  return false
 end
 -- todo: add real range calc
 return true
end
-->8
-- enemy
function getxy(step)
 coarse=flr(step/8)+1
 fine=step%8
 x,y,dx,dy=unpack(path[coarse])
 x+=dx*fine
 y+=dy*fine
 return x,y
end

enemy = {}
enemy.__index = enemy

function enemy:new(args)
 args = args or {}
 o = setmetatable({}, self)
 o.speed=nildef(args.speed,1)
 o.step = 0
 o.x,o.y = getxy(0)
 o.hp = nildef(args.hp,200+flr(rnd(400)))
 o.maxhp = o.hp
 o.alive = true
 return o
end

function enemy:update()
 -- you're dead
 if self.hp == 0 then
  del(enemies,self)
  game.xp+=1
  return
 end
 -- we've reached the castle
 done = self:move(self.speed)
 if done then
  del(enemies,self)
  game.hp-=1
  return
 end
end

function enemy:move(val)
 maxstep = (#path-1)*8
 self.step=min(self.step+val, maxstep)
 self.x,self.y=getxy(self.step)
 return self.step == maxstep
end

function enemy:draw()
 drawhp(self.x-3,self.y-3,8,self.hp,self.maxhp)
 spr(6,self.x-3,self.y-3)
 print(self.hp,96,32)
end

function enemy:hit(dmg)
 self.hp = max(0, self.hp-dmg)
 self.alive = self.hp > 0
end

-- draw an hp bar
function drawhp(x,y,w,val,maxval)
 hp = flr(val*w*3/maxval)
 for i=0,w-1 do
  col=8+clamp(0,hp-3*i,3)
  pset(x+i,y,col)
 end
end

path = {
 {43, 131, 0,-1},
 {43, 123, 0,-1},
 {43, 115, 1, 0},
 {51, 115, 1, 0},
 {59, 115, 1, 0},
 {67, 115, 1, 0},
 {75, 115, 0,-1},
 {75, 107, 0,-1},
 {75,  99, 0,-1},
 {75,  91,-1, 0},
 {67,  91,-1, 0},
 {59,  91,-1, 0},
 {51,  91,-1, 0},
 {43,  91,-1, 0},
 {35,  91,-1, 0},
 {27,  91, 0, 1},
 {27,  99, 0, 1},
 {27, 107, 0, 1},
 {27, 115,-1, 0},
 {19, 115,-1, 0},
 {11, 115, 0,-1},
 {11, 107, 0,-1},
 {11,  99, 0,-1},
 {11,  91, 0,-1},
 {11,  83, 0,-1},
 {11,  75, 0,-1},
 {11,  67, 0,-1},
 {11,  59, 0,-1},
 {11,  51, 0,-1},
 {11,  43, 0,-1},
 {11,  35, 1, 0},
 {19,  35, 1, 0},
 {27,  35, 0, 1},
 {27,  43, 0, 1},
 {27,  51, 0, 1},
 {27,  59, 1, 1},
 {35,  67, 1, 0},
 {43,  67, 1, 0},
 {51,  67, 1, 0},
 {59,  67, 1, 0},
 {67,  67, 0,-1},
 {67,  59, 0,-1},
 {67,  51, 0,-1},
 {67,  43, 0,-1},
 {67,  35,-1, 0},
 {59,  35,-1, 0},
 {51,  35,-1, 0},
 {43,  35, 0,-1},
 {43,  27, 0,-1},
 {43,  19, 0,-1},
 {43,  11, 0,-1},
 { 5,   0, 0, 0}
}
-->8
-- utils

-- return val or def is val is nil
function nildef(val, def)
	if val~=nil then
	 return val
	else
	 return def
	end
end

function clamp(low,val,hi)
 return max(low,min(val,hi))
end
-->8
-- game
game = {
 hp=100,
 xp=0
}

-- cursor
curs = {
	x=8,
	y=8,
	anim=0
}

function curs:update()
 self.anim = (self.anim + 1)%14
end

function curs:draw()
 s=7+(self.anim/2)
 spr(s,self.x*8,self.y*8)
end
-->8
-- effects
zap = {}
zap.__index = zap

function zap:new(args)
 args = args or {}
 o = setmetatable({}, self)
 o.x1=nildef(args.x1,0)
 o.y1=nildef(args.y1,0)
 o.x2=nildef(args.x2,0)
 o.y2=nildef(args.y2,0)
 o.life=nildef(args.life,5)
 return o
end

function zap:update()
	self.life = max(0,self.life-1)
 if self.life == 0 then
  del(effects,self)
 end
end

function zap:draw()
 line(self.x1, self.y1, self.x2, self.y2, 10)
end
__gfx__
0000000000000000000000000000000000855c00080c009000000000880000888880000808880000008880000008880000008880800008880000000000000000
00000000000555555555555555555000058ddc5080c0c90000000000800000080000000800000008000000000000000080000000800000000000000000000000
007007000005dddddddddddddddd5000055dd55080ccc090000a0000000000000000000800000008000000088000000080000000800000000000000000000000
0007700000055555555555555555500005d55d5008c0c900000d4400000000000000000000000008800000088000000880000000000000000000000000000000
000770000005dddddddddddddddd500005dddd5099980cc0004d4000000000000000000080000000800000088000000800000008000000000000000000000000
007007000005dddddddddddddddd500005dddd5009080cc000404000000000008000000080000000800000000000000800000008000000080000000000000000
0000000000055555555555555555500005dddd5009080c0000000000800000088000000080000000000000000000000000000008000000080000000000000000
000000000000000000000000000000000005500009088cc000000000880000888000088800008880000888000088800008880000888000080000000000000000
00000000000000000000000000000000000000000000000033333333333333333333333300000000000000000000000000000000000000000000000000000000
00000000005555555555555555555500000000000000000033333333333333333333333300000000000000000000000000000000000000000000000000000000
00000000005dddddddddddddddddd500005555000000000033336666666666666666333300000000000000000000000000000000000000000000000000000000
00000000005dd555555dd555555dd500005dd5000000000033366666666666666666633300000000000000000000000000000000000000000000000000000000
00000000005dd5dddd5dd5dddd5dd500005dd5000000000033666666666666666666663300000000000000000000000000000000000000000000000000000000
00000000005dd5dddd5dd5dddd5dd500005dd5000000000033666666666666666666663300000000000000000000000000000000000000000000000000000000
00000000005dd555555dd555555dd500005dd5000000000033666663333333333666663300000000000000000000000000000000000000000000000000000000
00000000005dd500005dd500005dd500005dd5000000000033666633333333333366663300000000000000000000000000000000000000000000000000000000
00000000005dd500005dd500005dd500005dd5000000000000000000333333333366663300000000000000000000000000000000000000000000000000000000
00000000005dd555555dd555555dd500005dd5000000000000000000333333333366663300000000000000000000000000000000000000000000000000000000
00000000005dddddddddddddddddd500005dd5000000000000000000333333333366663300000000000000000000000000000000000000000000000000000000
00000000005dd555555dd555555dd500005dd5000000000000000000333333333366663300000000000000000000000000000000000000000000000000000000
00000000005dd5dddd5dd5dddd5dd500005dd5000000000000000000333333333366663300000000000000000000000000000000000000000000000000000000
00000000005dd5dddd5dd5dddd5dd500005dd5000000000000000000333333333366663300000000000000000000000000000000000000000000000000000000
00000000005dd555555dd555555dd500005dd5000000000000000000333333333366663300000000000000000000000000000000000000000000000000000000
00000000005dd500005dd500005dd500005dd5000000000000000000333333333366663300000000000000000000000000000000000000000000000000000000
00000000005dd500005dd500005dd500005dd5000000000033666633000000003366663300000000000000000000000000000000000000000000000000000000
00000000005dd555555dd555555dd500005dd5000000000033666663000000003666663300000000000000000000000000000000000000000000000000000000
00000000005dddddddddddddddddd500005555000000000033666666000000006666663300000000000000000000000000000000000000000000000000000000
00000000005555555555555555555500005dd5000000000033666666000000006666663300000000000000000000000000000000000000000000000000000000
00000000005dddddddddddddddddd500005dd5000000000033366666000000006666633300000000000000000000000000000000000000000000000000000000
00000000005dddddddddddddddddd500005555000000000033336666000000006666333300000000000000000000000000000000000000000000000000000000
00000000005555555555555555555500000000000000000033333333000000003333333300000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000033333333000000003333333300000000000000000000000000000000000000000000000000000000
__map__
0505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1102020213001102020213000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000024002400000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2102020223003102021223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000024000000002424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400140021030113002424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400240021020223002424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400240031030133002424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400240000000000002424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400211202121300112324000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400213300313202323324000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400240000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400240011020202130024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400340021020202330024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000024000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3102020233000102020233000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2727272727282727272727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2727272727282727272727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2727272727282727272727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2727272727282727272727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2716171827361717182727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2728272827272727282727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2728272827272727282727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2728272827272727282727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2728273617171717382727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2728272727272727272727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2728272727272727272727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2728271617171717171827000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2728272827272727272827000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2728272827272727272827000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2736173827161717173827000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2727272727282727272727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200001d150011500015000150181501815015100161000e1000c1000e1000e1001b1001b1001b1001b1001b1001a1001a1001a1001a1001a1001a1001a1001a10000100001000010000100001000010000100
00040000185501d5502a5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0117000000000000002b7102b7153271032710327103271530710307152e7102e7152d7102d7152b7102b7152971029710297102971029710297152b7102b7152e7102e7152d7102d7152b7102b7152971029715
01170000377103771037710377153271032710327103271530710307152e7102e7152d7102d7152b7102b7152971029710297102971029710297152b7102b7152e7102e7152d7102d7152b7102b7152971029715
011700002b7102b7102b7102b7152e7102e7102e7102e7152d7102d7102d7102d7152b7102b7102b7102b7152a7102a7102a7102a7102a7102a7102a7102a7150000000000000000000032715347153571035715
011700003471535715327103271530715327152e7102e7152d7152e7152b7102b715297152b71528710287152971029710297102971029710297152671528715297152b7152d7152e71530715327153471535715
011700003471034715327103271530710307152e7102e7152d7102d7152b7102b715297102971528710287152971029710297102971029710297152b7102b7152e7102e7152d7102d7152b7102b7152971029715
011700002b7102b7102b7102b7152e7102e7102e7102e7152d7102d7102d7102d7152b7102b7102b7102b7152a7102a7102a7102a71526715287152a7152b7152d7152b7152a715287152b7152a7152b71528715
011700002b7102b7102b7102b7152e7102e7102e7102e7152d7102d7152b7102b715297102971528710287152971029710297102971029710297152b7102b7152e7102e7152d7102d7152b7102b7152971029715
011700002b7102b7102b7102b7102b7102b7151f71521715227152471526715247152271524715267152871529715287152671528715297152b7152d7152e7152d7152b71529715287152b7152a7152b71528715
011700002b7152a7152b7152d7152e7152b7152d7152e7152d7152e7153071532715307152e7152d7152b7152971029710297102971029710297152671528715297152b7152d7152e71530715327153471535715
01170000347153571534715327153071532715307152e7152d7152e7152d7152b7152a7152b7152a715287152a7152871526715287152a7152b7152d7152e7152d7152b7152a715287152b7152a7152b71528715
011700002b7152a7152b7152d7152e7152b7152d7152e7152d7152e7152b7152d715297152b7152871028715297102971029710297152671528715297152b7152d7152b7152a715287152b7152a7152b71528715
011700002b7102b7102b7102b71532710327103271032715307103071030710307152e7102e7102e7102e7152d7102d7102d7102d715327153471536715377153971537715367153471537715367153771534715
0117001013710137101371013710137101371013710137151a7101a7101a7101a7101a7101a7101a7101a71500700007000070000700007000070000700007000070000700007000070000700007000070000700
01170010007001f7151a7151f715007001f7151a7151f715007052671521715267150070526715217152671500700007000070000700007000070000700007000070000700007000070000700007000070000700
__music__
00 3e3f3244
01 3e3f3344
00 3e3f3444
00 3e3f3544
00 3e3f3644
00 3e3f3744
00 3e3f3344
00 3e3f3844
00 3e3f3944
00 3e3f3a44
00 3e3f3b44
00 3e3f3c44
02 3e3f3d44

