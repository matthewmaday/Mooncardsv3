module (..., package.seeall)

-- external modules ( remember to put json.lua in the same folder as this file )
local json = require( "json" )
local facebook 	= require( "facebook" )

-- facebook setup
local appId = "162620770581111"

-- Facebook Commands
local fbCommand	
local LOGOUT = 1
local SHOW_DIALOG = 2
local POST_MSG = 3
local POST_PHOTO = 4
local GET_USER_INFO = 5
local GET_PLATFORM_INFO = 6
local statusMessage

local messageToPost

-- facebook handlers
local function createStatusMessage( message, x, y )
	-- Show text, using default bold font of device (Helvetica on iPhone)
	local textObject = display.newText( message, 0, 0, native.systemFontBold, 24 )
	textObject:setTextColor( 255,255,255 )

	-- A trick to get text to be centered
	local group = display.newGroup()
	group.x = x
	group.y = y
	group:insert( textObject, true )

	-- Insert rounded rect behind textObject
	local r = 10
	local roundedRect = display.newRoundedRect( 0, 0, textObject.contentWidth + 2*r, textObject.contentHeight + 2*r, r )
	roundedRect:setFillColor( 55, 55, 55, 190 )
	group:insert( 1, roundedRect, true )

	group.textObject = textObject
	return group
end

local function getInfo_onRelease( event )
	-- call the login method of the FB session object, passing in a handler
	-- to be called upon successful login.
	fbCommand = GET_USER_INFO
	facebook.login( appId, facebookListener, {"publish_stream"}  )
end

local function postMsg_onRelease( event )
	-- call the login method of the FB session object, passing in a handler
	-- to be called upon successful login.
	fbCommand = POST_MSG
	facebook.login( appId, facebookListener, {"publish_stream"} )
end

local function showDialog_onRelease( event )
	-- call the login method of the FB session object, passing in a handler
	-- to be called upon successful login.
	fbCommand = SHOW_DIALOG
	facebook.login( appId, facebookListener, {"publish_stream"}  )
end

local function logOut_onRelease( event )
	-- call the login method of the FB session object, passing in a handler
	-- to be called upon successful login.
	fbCommand = LOGOUT
	facebook.logout()
end

function removeStatusMessage()
	statusMessage.isVisible = false
	statusMessage:removeSelf()
end

local function facebookListener( event )
	print( "Facebook Listener events:" )

	local maxStr = 20		-- set maximum string length
	local endStr

	for k,v in pairs( event ) do
		local valueString = tostring(v)
		if string.len(valueString) > maxStr then
			endStr = " ... #" .. tostring(string.len(valueString)) .. ")"
		else
			endStr = ")"
		end
		print( "   " .. tostring( k ) .. "(" .. tostring( string.sub(valueString, 1, maxStr ) ) .. endStr )
	end
--- End of debug Event routine -------------------------------------------------------

    print( "event.name", event.name ) -- "fbconnect"
    print( "event.type:", event.type ) -- type is either "session" or "request" or "dialog"
	print( "isError: " .. tostring( event.isError ) )
	print( "didComplete: " .. tostring( event.didComplete) )
-----------------------------------------------------------------------------------------
	-- After a successful login event, send the FB command
	-- Note: If the app is already logged in, we will still get a "login" phase
	--
    if ( "session" == event.type ) then
        -- event.phase is one of: "login", "loginFailed", "loginCancelled", "logout"
		statusMessage.textObject.text = event.phase		-- tjn Added

		print( "Session Status: " .. event.phase )

		if event.phase ~= "login" then
			statusMessage.textObject.text = "login error"
			-- Exit if login error
			return
		end

		-- The following displays a Facebook dialog box for posting to your Facebook Wall
		if fbCommand == SHOW_DIALOG then
			statusMessage.textObject.text = "show dialog"
			facebook.showDialog( {action="stream.publish"} )
		end

		-- Request the Platform information (FB information)
		if fbCommand == GET_PLATFORM_INFO then
			statusMessage.textObject.text = "platform info"
			facebook.request( "platform" )		-- **tjn Displays info about Facebook platform
		end

		-- Request the current logged in user's info
		if fbCommand == GET_USER_INFO then
			statusMessage.textObject.text = "get user info"
			facebook.request( "me" )
--			facebook.request( "me/friends" )		-- Alternate request
		end

		-- This code posts a photo image to your Facebook Wall
		--
		if fbCommand == POST_PHOTO then

			statusMessage.textObject.text = "post photo"

			local attachment = {
				name = "Developing a Facebook Connect app using the Corona SDK!",
				link = "http://developer.anscamobile.com/forum",
				caption = "Link caption",
				description = "Corona SDK for developing iOS and Android apps with the same code base.",
				picture = "http://developer.anscamobile.com/demo/Corona90x90.png",
				actions = json.encode( { { name = "Learn More", link = "http://anscamobile.com" } } )
			}

			facebook.request( "me/feed", "POST", attachment )		-- posting the photo
		end

		-- This code posts a message to your Facebook Wall
		if fbCommand == POST_MSG then

			statusMessage.textObject.text = "posting message"

			local postMsg = {
				message = messageToPost
			}

			facebook.request( "me/feed", "POST", postMsg )		-- posting the message
		end
-----------------------------------------------------------------------------------------
	end

    if ( "request" == event.type ) then
        -- event.response is a JSON object from the FB server
        local response = event.response
        statusMessage.textObject.text = "response"
		timer.performWithDelay(1000, removeStatusMessage)

		if ( not event.isError ) then
	        response = json.decode( event.response )

			statusMessage.textObject.text = "response not error"

	        if fbCommand == GET_USER_INFO then
				statusMessage.textObject.text = response.name
				print( "name", response.name )

			elseif fbCommand == POST_PHOTO then
				statusMessage.textObject.text = "Photo Posted"

			elseif fbCommand == POST_MSG then
				statusMessage.textObject.text = "Message Posted"
			else
				-- Unknown command response
				print( "Unknown command response" )
				statusMessage.textObject.text = "Post failed, please try again later!"
			end

        else
        	-- Post Failed
			statusMessage.textObject.text = "Post failed, please try again later!"
		end

	elseif ( "dialog" == event.type ) then
		-- showDialog response
		--
		print( "dialog response:", event.response )
		statusMessage.textObject.text = "event.response"
    end
end

function publishOnFacebook( _messageToPost )

	messageToPost = _messageToPost
	statusMessage = createStatusMessage( "Connecting to Facebook", 0.5*display.contentWidth, 30 )
	fbCommand = POST_MSG
	facebook.login( appId, facebookListener, {"publish_stream"} )

end