-- Scroll View

-- Moon cards version 2
-- Development by Matthew Maday
-- DBA - Weekend Warrior Collective
-- a 100% not-for-profit developer collective

LoadScroll = {}

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------
local widget       = require "widget"


function LoadScroll:new(params)

	local screen   = display.newGroup()
	
	------------------------------------------------------------------------------------------
	-- Primary Views
	------------------------------------------------------------------------------------------

	-- initialize()
	-- show()
	-- hide()

	local function onOrientationChange( event )

		if screen == nil then return -1 end
		if screen.state ~= "idle" then return -1 end

	 	local delta = event.delta

		if screen.rotation == 0 and delta < 0 then
			local newAngle = delta-screen.rotation
		else
			local newAngle = delta-screen.rotation
		end

		tweenObject(screen, screen.x, (display.contentWidth-screen.myWidth)*.5, screen.y, 0, 1, 1)
		screen:alignContent()

	end
	--------
	function screen:initialize(params, event)

		self.images       = {}
		self.texts		  = {} 			
		self.groups       = {}
		self.timer        = nil
		self.tween        = nil
		self.myWidth	  = display.viewableContentWidth
		self.myHeight     = display.viewableContentHeight

		if self.myWidth > self.myHeight then
			local tmp     = self.myWidth
			self.myWidth  = self.myHeight
			self.myHeight = tmp
		end

		self.centerX, self.centerY = self.myWidth*.5, self.myHeight*.5
		self.groups[#self.groups+1] = {body=nil}
		
		screen:updateText()
		
		self.state = "idle"
	end
	--------
	function screen:updateText()

		-- remove old instance of the text (fixes formatting issues)
		if screen.textContent ~= nil then
			screen.textContent:removeSelf()
			self.groups.body:removeSelf()
			screen.textContent = nil
			self.groups.body = nil
		end

		self.groups.body = widget.newScrollView
		{left=0,top=0,width=280,height=277,scrollWidth=400,scrollHeight=277,bottomPadding=0,hideBackground=true,id="onBottom",
		horizontalScrollDisabled = true,verticalScrollDisabled = false,listener = scrollListener,}

		self:insert( self.groups.body )

		screen.textContent = display.newText( gRecord.text, 0, 0, 200, 0, "Papyrus", 16)
		screen.textContent:setTextColor(0,0,0) 
		
		screen.x, screen.y = gComponents.support[2].x - screen.textContent.width*.5, 
		gComponents.support[2].y-(gComponents.support[2].height*.25)
		
		self.groups.body :insert( self.textContent )

		-- insert the mask that sits over the text within the card
		local mask = graphics.newMask( "content/images/mask.png" )
		self.groups.body:setMask( mask )
		self.groups.body.maskX,self.groups.body.maskY = 100, 100

		screen:alignContent()

	end
	--------
	function screen:show(time)

		transition.to(self, {time = time, alpha = 1, onComplete = function()
			screen.state = "idle"
		end
		})
	end
	--------
	function screen:hide(time)
		transition.to(self, {time = time, alpha = 0, onComplete = function()
			screen.state = "paused"
		end
		})
	end	
	--------
	function screen:activate()
		Runtime:addEventListener( "orientation", onOrientationChange )
	end
	--------
	function screen:process()
		if self.state ~= "idle" then return -1 end
   end
	--------
	function screen:pause()

		if self.state == "idle" then
			self.state = "paused"
		elseif self.state == "paused" then
			self.state = "idle"
		end 

	end	
	--------
	function screen:destory()

		local pEnd = #self.images

		self.groups.body:removeSelf()
		self.textContent:removeSelf()

		self.groups.body = nil
		self.textContent = nil
		widget = nil

		screen:removeSelf()
		screen = nil
	end
	--------
	function screen:transitionAwayFrom()

		if self.state ~= "idle" then return -1 end

		self.state = "paused"
		Runtime:removeEventListener( "orientation", onOrientationChange )
		

		transition.to( screen, { time=400, delay=0,alpha=0,transition=easing.outQuad, onComplete = function()
			screen:destory()
		end
		})

	end	
	--------
	function screen:timeout()
		-- not used in this scene
	end
	--------
	function screen:alignContent()

		if system.orientation == "portrait" or system.orientation == "portraitUpsideDown" or system.orientation == "faceUp" then

			self.xScale,self.yScale = 1.0,1.0

			local locX = self.centerX - screen.textContent.width*.5
			local locY = self.centerY-(428*.3)
			
			tweenObject(screen, screen.x,locX, locY-40,locY,.5, 1)

		elseif system.orientation == "landscapeRight" or system.orientation == "landscapeLeft" then

			self.xScale,self.yScale = .75,.75

			local locX = self.centerY*1.1 - screen.textContent.width*.5
			local locY = self.centerX - (321*.25) -- THE 321 is 75% of height of the card. OOP executes differently and I just added it manually
			
			tweenObject(screen, screen.x,locX, locY-40,locY,.5, 1)
			
		end

	end


	Runtime:addEventListener( "orientation", onOrientationChange )

	screen:initialize(params)
	return screen

end

return LoadScroll
