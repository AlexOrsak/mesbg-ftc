local max,min,cos,sin=math.max,math.min,math.cos,math.sin
local d,ci,bo,cs={0,1,2,3,4,5,6,8,10,12,18,24},1,nil,false
function detectBaseSize() local b=self.getBoundsNormalized() if b and b.size then bo=(b.size.x or 0)/2 end end
function onScriptingButtonDown(i, pc)
    if Player[pc].getHoverObject()~=self or i>3 or i<1 then return end
    if i==1 then ci=min(ci+1,#d)
    elseif i==2 then ci=max(ci-1,1)
    elseif i==3 then cs=not cs if bo==nil then detectBaseSize() end end
    if not cs or bo==nil then self.setVectorLines() return end
    if d[ci]==0 then self.setVectorLines() return end
    self.setVectorLines({{points=getCircleVectorPoints(d[ci]+bo),color={0,0.8,0.4},thickness=0.05,rotation={0,0,0}}})
    print(d[ci].." inch radius") end
function getCircleVectorPoints(r) local t,a={},0 for i = 1, 65 do t[i]={cos(a)*r,0.1,sin(a)*r} a=a+0.0981747704247 end return t end