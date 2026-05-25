require("calcBoundingModelScript")
local as,ao={{n="Siege Firing Arc",r={60, 6},clr={{0, 1, 0},{1, 0, 0}},}},0
function onLoad() for i,a in ipairs(as) do self.addContextMenuItem(a.n,function()AD(i)end) end end
function AD(id)
    if ao==id then self.setVectorLines() ao=0 return end ao=id
    local fwd,o=nil,Vector(0,0.1,0)
    local al,list,vi={},{},2 dbs()
    if bo==nil then return end
    for i=1,#as[id].r do
        list={[1]=o}
        fwd=Vector(0,0,as[id].r[i]+bo)
        fwd:rotateOver('y',-22.5) vi=2
        for j=-22.5,22.5,5 do list[vi]=o+fwd vi=vi+1 fwd:rotateOver('y',5) end list[vi]=o
        al[i]={points=list,color=as[id].clr[i],thickness=0.1}
    end self.setVectorLines(al)
end
