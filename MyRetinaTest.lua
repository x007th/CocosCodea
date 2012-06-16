--MyRetinaTest
MyRetinaTest = CCClass(CCLayer)

local function createSprite(name, ofsx, ofsy)
    local sprite = CCSprite(name)
    local pos = CCSharedDirector():winSize()/2
    pos.x, pos.y = pos.x + ofsx, pos.y + ofsy
    sprite:setPosition(pos)    
    return sprite
end

local function createImage(name, ofsx, ofsy)
    local img = readImage(name)
    local sprite = CCSprite(img)
    local pos = CCSharedDirector():winSize()/2
    pos.x, pos.y = pos.x + ofsx, pos.y + ofsy
    sprite:setPosition(pos)    
    return sprite
end

-- non-retina images
local nonretina = 
{
    {"Tyrian Remastered:Boss A", 0, -150 },
    {"Tyrian Remastered:Blimp Boss", 0, 0 },
    {"SpaceCute:Beetle Ship", 0, 180 },
    {"Planet Cute:Chest Closed", -200, 0 },
}
    
-- retina images
local retina =
{
    {"Small World:Church", 200, 0},
}

function MyRetinaTest:init()
    CCLayer.init(self)
    
    local size = self:contentSize()
    
    -- keep these on a different layer
    local layer = CCLayer()
    self:addChild(layer)
    self.layer = layer
    
    self.createFn = createSprite
    self:populate()    
    
    local m = CCMenu(toggle)
    self:addChild(m)    
    
    do
        local label = CCLabelTTF("", "Georgia", 24, CENTER, 30)
        label:setAnchorPoint(.5, .5)
        label:setHasShadow(true)
        label:setShadowColor(128)
        label:setPosition(size.x/2, size.y - size.y/3)
        self:addChild(label)
        self.statusLabel = label
    end
    
    do
        local enable = CCMenuItemFont("Double Size Mode Enabled", "Georgia", 30)
        enable:setTag("enable")
        enable:setUserData("On Retina Devices, church will be huge!")
        
        local disable = CCMenuItemFont("Double Size Mode Disabled", "Georgia", 30)
        disable:setTag("disable")
        disable:setUserData("On Retina Devices, everything but the church will be tiny")
        
        local first, second = disable, enable
        if CC_ENABLE_CODEA_2X_MODE then first, second = enable, disable end
        
        local toggle = CCMenuItemToggle(first, second)
        toggle:setHandler(self, "toggled")
        toggle:setPosition(size.x/2, 80)
        m:addChild(toggle)
        
        self.statusLabel:setString(toggle:selectedItem():userData())        
    end
    
    do
        local useSprites = CCMenuItemFont("Use sprites", "Georgia", 30)
        useSprites:setTag("sprite")        
        useSprites:setUserData(createSprite)
        
        local useImage = CCMenuItemFont("Use image objects", "Georgia", 30)
        useImage:setTag("image")
        useImage:setUserData(createImage)
        
        local toggle = CCMenuItemToggle(useSprites, useImage)
        toggle:setHandler(self, "imageToggled")
        toggle:setPosition(size.x/2, 30)
        m:addChild(toggle)
    end    
    
    do
        local function nextScene()
            local t = CCTransitionJumpZoom(1, MyLayer:scene())
            CCSharedDirector():replaceScene(t)            
        end
        
        local item = CCMenuItemFont("Next Scene", "Georgia", 30)
        item:setHandler(nextScene)
        item:setPosition(size.x/2, size.y-40)
        m:addChild(item)
    end
    
end

function MyRetinaTest:populate()
    local create = self.createFn
    local layer = self.layer
    
    for i,v in ipairs(nonretina) do
        layer:addChild(create(unpack(v)))
    end
    
    for i,v in ipairs(retina) do
        layer:addChild(create(unpack(v)))
    end
end

function MyRetinaTest:toggled(toggle)
    local item = toggle:selectedItem()
    
    if item:tag() == "enable" then
        CC_ENABLE_CODEA_2X_MODE = true
    else
        CC_ENABLE_CODEA_2X_MODE = false        
    end
    
    self.layer:removeAllChildren(true)
    self:populate()    
    self.statusLabel:setString(item:userData())
end

function MyRetinaTest:imageToggled(toggle)
    local item = toggle:selectedItem()
    self.layer:removeAllChildren(true)   
    self.createFn = item:userData()
    self:populate()
end