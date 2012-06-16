CCAction = CCClass()

CCAction:synth{"tag"}

function CCAction:init()
    self.originalTarget = nil
    self.target = nil
    self.tag_ = -1
end

function CCAction:copy()
    return self.class()
end

function CCAction:startWithTarget(target)
    self.originalTarget = target
    self.target = target
end

function CCAction:stop()
    --ccPrint("CCAction:stop " .. tostring(self) .. " - setting target to nil")
    self.target = nil
end

function CCAction:isDone()
    return true
end

function CCAction:step(dt)
    -- override me
end

function CCAction:update(time)
    -- override me
end

-- implements reverse methods for reciprocal classes
function CCAction.impReverse(class1, class2)
    function class1:reverse() return class2() end
    function class2:reverse() return class1() end 
end

----------------------
-- finite time action
----------------------
CCFiniteTimeAction = CCClass(CCAction)

function CCFiniteTimeAction:init(duration)
    CCAction.init(self)
    self.duration_ = (duration ~= nil) and duration or 0
    self.elapsed = 0
end

function CCFiniteTimeAction:copy()
    return self.class(self.duration_)
end

function CCFiniteTimeAction:reverse()
    ccAssert(false, "action does not support reverse()")
end

function CCFiniteTimeAction:duration()
    return self.duration_
end

----------------------
-- repeat forever
----------------------
CCLoop = CCClass(CCAction)

function CCLoop:init(action)
    CCAction.init(self)
    self.action_ = action
end

function CCLoop:copy()
    return CCLoop(self.action_:copy())
end

function CCLoop:reverse()
    return CCRepeatForver(self.action_:reverse())
end

function CCLoop:isDone()
    return false
end

function CCLoop:startWithTarget(target)
    CCAction.startWithTarget(self, target)
    self.action_:startWithTarget(target)
end

function CCLoop:step(dt)
    local action = self.action_
    action:step(dt)
    if action:isDone() then
        local diff = action.elapsed - action.duration_
        action:startWithTarget(self.target)
        
        -- to prevent jerk, according to cocos2d-iphone
        action:step(0)
        action:step(diff)
    end
end

----------------------
-- speed
----------------------
CCSpeed = CCClass(CCAction)

function CCSpeed:init(action, speed)
    CCAction.init(self)
    self.action_ = action
    self.speed_ = speed
end

function CCSpeed:copy()
    return CCSpeed(self.action_:copy(), self.speed_)
end

function CCSpeed:reverse()
    return CCSpeed(self.action_:reverse(), self.speed_)
end

function CCSpeed:isDone()
    return self.action_:isDone()
end

function CCSpeed:stop()
    self.action_:stop()
    CCAction.stop(self)
end

function CCSpeed:startWithTarget(target)
    CCAction.startWithTarget(self, target)
    self.action_:startWithTarget(target)
end

function CCSpeed:step(dt)
    self.action_:step(dt * self.speed_)
end

-- TODO: Follow
