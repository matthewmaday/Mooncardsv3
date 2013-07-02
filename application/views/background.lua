-- General Screen Background View

-- Moon cards version 2
-- Development by Matthew Maday
-- DBA - Weekend Warrior Collective
-- a 100% not-for-profit developer collective

LoadBackground = {}

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------

function LoadBackground:new(params)

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

		transition.to( screen, { x=(display.contentWidth-screen.myWidth)*.5,y=0, time=400, delay=0,alpha=1.0,transition=easing.outQuad,rotation=newAngle})
	
		screen:alignContent()

	end
	--------
	function screen:initialize(params, event)

		self.images       = {}
		self.listeners    = {}
		self.timer        = nil
		self.myWidth	  = display.contentHeight
		self.myHeight     = display.contentWidth
		self.starSpeed    = 2
		self.starDegree   = 150

		if self.myWidth > self.myHeight then
			self.myHeight = self.myWidth
		elseif self.myHeight > self.myWidth then
			self.myWidth = self.myHeight
		end

		self.centerX, self.centerY = self.myWidth*.5, self.myHeight*.5

		-- blue image at the bottom of the screen
		self.images[#self.images+1] = {blackRect=nil}
		self.images.blackRect = display.newRect(screen, 0,0,self.myWidth*1.5,self.myHeight)
		self.images.blackRect:setReferencePoint( display.TopLeftReferencePoint )
		self.images.blackRect.x,self.images.blackRect.y = 0,self.centerY
		self.images.blackRect:setFillColor(32,98,117)
		self:insert(self.images.blackRect)

		-- burst animation
		self.images[#self.images+1] = {burst=nil}
		self.images.burst = display.newImageRect("content/images/home_burst.png", 800, 800) 
		self.images.burst.x, self.images.burst.y, self.images.burst.alpha = self.centerX, self.centerY, 1
		self.images.burst:setReferencePoint(display.CenterReferencePoint)
		screen:insert(self.images.burst)

		screen:alignContent()
		
		self.state = "idle"
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
		self.images.burst.rotation = (self.images.burst.rotation > 360) and 0 or (self.images.burst.rotation + .1)


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
		
		self.images.blackRect:removeSelf() 
		self.images.burst:removeSelf()

		self.images.blackRect = nil
		self.images.burst = nil

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

		goToScene(2)

	end	
	--------
	function screen:timeout()
		-- not used in this scene
	end
	--------
	function screen:alignContent()

	transition.to( screen, { x=(display.contentWidth-self.myWidth)*.5,y=(display.contentHeight-self.myHeight)*.5, 
	time=400, delay=0,transition=easing.outQuad})


end
	--------

	Runtime:addEventListener( "orientation", onOrientationChange )

	screen:initialize(params)
	return screen

end

return LoadBackground
