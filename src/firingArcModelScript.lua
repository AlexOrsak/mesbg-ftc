local as,ao={{n="Siege Firing Arc",r={60, 6},clr={{0, 1, 0},{1, 0, 0}},}},0
local max,min,cos,sin,floor=math.max,math.min,math.cos,math.sin,math.floor
local d,ci,bo,cs={0,1,2,3,4,5,6,8,10,12,18,24},1,nil,false
function onLoad() for i,a in ipairs(as) do self.addContextMenuItem(a.n,function()AD(i)end) end end
function AD(id)
    if ao==id then self.setVectorLines() ao=0 return end ao=id
    local fwd,o=nil,Vector(0,0.1,0)
    local al,list,vi={},{},2 detectBaseSize()
    if bo==nil then return end
    for i=1,#as[id].r do
        list={[1]=o}
        fwd=Vector(0,0,as[id].r[i]+bo)
        fwd:rotateOver('y',-22.5) vi=2
        for j=-22.5,22.5,5 do list[vi]=o+fwd vi=vi+1 fwd:rotateOver('y',5) end list[vi]=o
        al[i]={points=list,color=as[id].clr[i],thickness=0.1}
    end self.setVectorLines(al)
end
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