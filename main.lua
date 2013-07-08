-- Moon cards version 2
-- Development by Matthew Maday
-- DBA - Weekend Warrior Collective
-- a 100% not-for-profit developer collective

-- This is the main scene

display.setStatusBar( display.HiddenStatusBar )

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------
local fileio     = require ("library.core.fileio")
local json       = require "json"
local facebook   = require( "facebook" )

--------------------------------------------------------------------------------------
-- variable declaritions
--------------------------------------------------------------------------------------

local screen  = display.newGroup()
gComponents   = {focus=nil, legacy=nil, support=nil}
gRecords      = nil
gScreenText   = nil
gPrefs        = nil
gBio          = nil
gOrientation  = nil

local appId = "546384715396788"
local fbCommand = nil
local GET_USER_INFO = "getInfo"
local POST_MSG = "post"

--------------------------------------------------------------------------------------
-- UI functions
--------------------------------------------------------------------------------------

-- touchScreen(event)
-- processScene()
-- tweenObject(obj, startX, endX, startY, endY, startAlpha, endAlpha)
-- cancelTween(obj)

-- -- Facebook listener
	local function facebookListener( event )
		if "request" == event.type then		
			local response = json.decode( event.response )

			-- if response then
			-- 	storyboard.userData.firstName = response.first_name
			-- 	storyboard.userData.lastName = response.last_name
			-- 	storyboard.userData.id = response.id
			-- end
		
			local function networkListener( event )
				if event.isError then
					native.showAlert( "Network Error", "Download of profile picture failed, please check your network connection", { "OK" } )
				else
					print( "Profile picture downloaded successfully" )
				end
				
				-- -- Go to the main screen
				-- storyboard.gotoScene( "mainScreen", "crossFade" )
				
				-- -- Show the storyboard navBar group
				-- storyboard.navBarGroup.isVisible = true
			end
			
			-- Download the profile picture
			-- local path = system.pathForFile( storyboard.userData.firstName .. storyboard.userData.lastName .. storyboard.userData.id .. ".png", system.TemporaryDirectory )
			-- local picDownloaded = io.open( path )

			-- if not picDownloaded then
			-- 	network.download( "http://graph.facebook.com/" .. storyboard.userData.id .. "/picture", "GET", networkListener, storyboard.userData.firstName .. storyboard.userData.lastName .. storyboard.userData.id .. ".png", system.TemporaryDirectory )
			-- else
			-- 	-- Go to the main screen
			-- 	storyboard.gotoScene( "mainScreen", "crossFade" )
				
			-- 	-- Show the storyboard navBar group
			-- 	storyboard.navBarGroup.isVisible = true
			-- end
		
		-- After a successful login event, send the FB command
		-- Note: If the app is already logged in, we will still get a "login" phase
	    elseif "session" == event.type then
	        -- event.phase is one of: "login", "loginFailed", "loginCancelled", "logout"
				
			if event.phase ~= "login" then
				
				-- Exit if login error
				return
			end
			
						-- This code posts a message to your Facebook Wall
			if fbCommand == POST_MSG then
				-- Handle errors
				
				
				-- Set the with friends string accordingly
				
				
				-- Set the message
				local postMsg = 
				{
					message = gRecords.text,
				}
		
				-- Post the message
				facebook.request( "me/feed", "POST", postMsg )

				native.showAlert( "Facebook Message", "Message posted successfully", { "OK" } )

			end
	    end
	

		return true
	end
	
	
-- 	-- Login function
	local function loginUser( event )
		-- call the login method of the FB session object, passing in a handler
		-- to be called upon successful login.
		fbCommand = GET_USER_INFO
		facebook.login( appId, facebookListener, { "publish_stream" } )
	end
	-- Announce!
	function postMessage( event )
		--native.showAlert( "Post function called", "Post function called", { "OK" } )
		--print("fPOS FUNCTION CALLED_____________________________________________________________________")
		fbCommand = POST_MSG
		facebook.login( appId, facebookListener, { "publish_stream" } )
	end
-- function initFacebook()



local function touchScreen(event)

	if event.phase == "began" then 

		if gComponents.focus ~= nil then
			gComponents.focus:transitionAwayFrom() 
		end
	end

end
--------
local function processScene()

	if gComponents.focus ~= nil then
		gComponents.focus:process()
	end

	if gComponents.support ~= nil then
		local pEnd = #gComponents.support

		for i=1,pEnd,1 do 
			gComponents.support[i]:process()
		end
	end
end
--------
function tweenObject(obj, startX, endX, startY, endY, startAlpha, endAlpha)

		obj.x,obj.y,obj.alpha = startX,startY, startAlpha

		cancelTween(obj)

		obj.tween = transition.to(obj, {time=400,x=endX, y=endY,alpha=endAlpha,transition=easing.outQuad,onComplete=function()
			cancelTween(obj)
			end
			})

	end
	--------
function cancelTween(obj)
		
		if obj.tween ~= nil then
			transition.cancel(obj.tween)
			obj.tween = nil
		end
	end
--------

local function onOrientationChange( event )

-- native.showAlert( "Status Update", "Orientation Change", { "OK" } )
	if system.orientation == "portrait" or system.orientation == "portraitUpsideDown" then
			gOrientation = "portrait"
	elseif system.orientation == "landscapeRight" or system.orientation == "landscapeLeft" then
			gOrientation = "landscapeRight"
	end

	if gOrientation == nil then gOrientation = "portrait" end
end


--------------------------------------------------------------------------------------
-- Data Management functions
--------------------------------------------------------------------------------------

-- selectRecord()
-- initExternalData()

function selectRecord()

	if #gPrefs.status.remaining == 0 then

		gPrefs.status.remaining = {}
		for i=1,#gPrefs.status.total,1 do
			gPrefs.status.remaining[#gPrefs.status.remaining+1] = gPrefs.status.total[i]
		end

	end
		
	local recordNum = math.random(#gPrefs.status.remaining)
	gRecord = gScreenText[gPrefs.status.remaining[recordNum]]

	table.remove(gPrefs.status.remaining,recordNum)

	pFile  = fileio.new(system.pathForFile( "prefs.txt", system.DocumentsDirectory))
	pFile:writeFile(json.encode( gPrefs ))
	pFile = nil

end
--------
function initExternalData()
	
	-- load the messages for the card
	local pFile = fileio.new(system.pathForFile( "data/data.txt", system.ResourceDirectory))
	local str   = pFile:readFile()
	gScreenText = json.decode( str)
	pFile       = nil

	-- load bio text
	local pFile    = fileio.new(system.pathForFile( "data/bio.txt", system.ResourceDirectory))
	local str      = pFile:readFile()
	gBio           = json.decode( str)

	-- load the preferences file with information about sequence
	local pPrefs  = fileio.new(system.pathForFile( "prefs.txt", system.DocumentsDirectory))
	local str     = pPrefs:readFile()

	-- the initial prefs doc was not created in the tmp directory on the device, create it now
	if str == "" then

		print("need to create a file for prefs")

		local pTmpPrefs = fileio.new(system.pathForFile( "data/prefs.txt", system.ResourceDirectory))
		str       = pTmpPrefs:readFile()
		pTmpPrefs = nil
		gPrefs    =  json.decode(str)

		pPrefs    = fileio.new(system.pathForFile( "prefs.txt", system.DocumentsDirectory))
		pPrefs:writeFile(str)
		pPrefs    = nil

	else
		gPrefs = json.decode(str)
	end

	selectRecord()

end


--------------------------------------------------------------------------------------
-- Views
--------------------------------------------------------------------------------------

-- loadBrand()
-- loadBackground()
-- loadTitle()
-- loadCard()
-- loadScroll()
-- loadAbout()
-- loadButtons()

local function loadBrand()

	print("adding new brand")
	require "application.views.brand"

	gComponents.focus = LoadBrand:new(nil)
	gComponents.focus:activate()
	gComponents.focus:show()

end
--------
local function loadBackground()

	print("adding background to the animation")
	require "application.views.background"

	gComponents.support = {}

	gComponents.support[1] = LoadBackground:new(nil)
	gComponents.support[1]:activate()
	gComponents.support[1]:show()

end
--------
local function loadTitle()

	print("adding new brand")
	require "application.views.title"

	gComponents.focus = LoadTitle:new(nil)
	gComponents.focus:activate()
	gComponents.focus:show()
	
end
--------
local function loadCard()

	print("adding new brand")
	require "application.views.card"

	gComponents.support[2] = LoadCard:new(nil)
	gComponents.support[2]:activate()
	gComponents.support[2]:show()
	
end
--------
local function loadScroll()

	print("adding new brand")
	require "application.views.scroll"

	gComponents.support[4] = LoadScroll:new(nil)
	gComponents.support[4]:activate()
	gComponents.support[4]:show()
	
end
--------
function loadAbout()

	require "application.views.about"

	gComponents.support[5] = LoadAbout:new(nil)
	gComponents.support[5]:activate()
	gComponents.support[5]:show()
end
--------
local function loadButtons()

	print("adding button panel")
	require "application.views.buttonPanel"

	gComponents.support[3] = LoadButtons:new(nil)
	gComponents.support[3]:activate()
	gComponents.support[3]:show()
	
end


--------------------------------------------------------------------------------------
-- scene execution
--------------------------------------------------------------------------------------

function goToScene(scene)

	-- if a scene is already active, kill it
	if gComponents.focus ~= nil then

		gComponents.focus:transitionAwayFrom()
		gComponents.legacy = gComponents.focus
		gComponents.focus = nil

	end

	-- load a new scene

	if scene == 1 then
		loadBrand()
	elseif scene == 2 then
		loadBackground()
		loadTitle()
	elseif scene == 3 then
		loadCard()
		loadScroll()
		loadButtons()
	end

end

--------------------------------------------------------------------------------------
-- scene execution
--------------------------------------------------------------------------------------

print("----------------------------------------------------------------------------")
print("start application")
print("----------------------------------------------------------------------------")
Runtime:addEventListener("touch",touchScreen)
Runtime:addEventListener("enterFrame",processScene)
Runtime:addEventListener( "orientation", onOrientationChange )

-- loginUser( event )
onOrientationChange( event )
initExternalData()
goToScene(1)


-------------------------------------------------------------------
local monitorMem = function()

    collectgarbage()
    print( "MemUsage: " .. collectgarbage("count") )

    local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
    print( "TexMem:   " .. textMem )
end

-- Runtime:addEventListener( "enterFrame", monitorMem )

return screen



