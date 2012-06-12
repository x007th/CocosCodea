--ccSynthesize

local function genSetter(propName)
    return "set" .. string.upper(string.sub(propName, 1, 1)) .. string.sub(propName, 2)
end

function ccSynthesizeBase(t, genGetFn, genSetFn)
    local klass = t[1]
    local propName = t[2]
    local ivarName = t[3] or propName .. "_"
    
    assert(klass and propName)
    
    local mode = t["mode"] or "rw"    
    local read = string.find(mode, "r") ~= nil
    local write = string.find(mode, "w") ~= nil    

    if read then
        local getter = t["getter"] or propName
        klass[getter] = genGetFn(ivarName)
    end
    
    if write then
        local setter = t["setter"] or genSetter(propName)
        klass[setter] = genSetFn(ivarName)
    end    
end

function ccSynthesize(t)
    local function genGet(ivarName)
        return function(inst) assert(inst) return inst[ivarName] end
    end

    local function genSet(ivarName)
        return function(inst, value) inst[ivarName] = value end
    end    
    
    ccSynthesizeBase(t, genGet, genSet)
end

function ccSynthesizeColor(t)
    local function genGet(ivarName)
        return function(inst)
            return ccColorCopy(inst[ivarName])
        end
    end

    local function genSet(ivarName)
        return function(inst, ...)
            inst[ivarName] = color(ccColorVA(...))
        end
    end        
    
   ccSynthesizeBase(t, genGet, genSet)
end

function ccSynthesizeColorRaw(t)
    local function genGet(ivarName)
        return function(inst)
            return ccColorCopyRaw(inst[ivarName])
        end
    end

    local function genSet(ivarName)
        return function(inst, ...)
            inst[ivarName] = color(ccColorRawVA(...))
        end
    end
    
    ccSynthesizeBase(t, genGetColorRaw, genSetColorRaw)
end

function ccSynthesizeVec2(t)
    local function genGet(ivarName)
        return function(inst)
            local v = inst[ivarName]
            return vec2(v.x, v.y)
        end
    end

    local function genSet(ivarName)
        return function(inst, ...)
            local x, y = ccVec2VA(...)
            local v = inst[ivarName]
            v.x, v.y = x, y
        end
    end    
     
    ccSynthesizeBase(t, genGet, genSet)
end
