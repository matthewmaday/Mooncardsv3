-- General Branding View

-- Moon cards version 2
-- Development by Matthew Maday
-- DBA - Weekend Warrior Collective
-- a 100% not-for-profit developer collective

LoadBrand = {}

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------
 local uiObj    = require ("library.core.ui")

function LoadBrand:new(params)

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

		transition.to( screen, { x=(display.contentWidth-screen.myWidth)*.5,y=0, 
		time=400, delay=0,alpha=1.0,transition=easing.outQuad,rotation=newAngle})
	
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

		-- create a blank background - important for orientation and predictable image placement
		self.images[#self.images+1] = {blackRect=nil}
		self.images.blackRect = display.newRect(screen, 0,0,self.myWidth,self.myHeight)
		self.images.blackRect:setReferencePoint( display.TopLeftReferencePoint )
		self.images.blackRect.x,self.images.blackRect.y     = 0,0
		self.images.blackRect:setFillColor(0,0,0)
	
		self:insert(self.images.blackRect)

		-- background rect that fades in
		self.images[#self.images+1] = {background=nil}
		self.images.background = display.newRect(screen, 0,0,self.myWidth*2,self.centerY)
		self.images.background:setReferencePoint( display.TopLeftReferencePoint )
		self.images.background.x,self.images.background.y     = 0,0
		self.images.background:setFillColor(255,255,255)
		self.images.background.alpha = 0.0
		
		self:insert(self.images.background)

		transition.to( self.images.background, { time=4000, delay=0, alpha=1.0} )

		-- burst image
		self.images[#self.images+1] = {burst=nil}
		self.images.burst = display.newImageRect("content/images/logo_burst.png", 698, 373) 
		self.images.burst.x, self.images.burst.y, self.images.burst.alpha = self.centerX, self.centerY-200, 0
		self.images.burst:setReferencePoint(display.BottomCenterReferencePoint)
		screen:insert(self.images.burst)

		transition.to( self.images.burst, { time=2000, delay=2000, alpha=.5, } )

		-- logo image
		self.images[#self.images+1] = {logo=nil}
		self.images.logo = display.newImageRect("content/images/logo.png", 132, 125) 
		self.images.logo.x, self.images.logo.y, self.images.logo.alpha = self.centerY+30, self.centerY-60, 1
		self.images.logo:setReferencePoint(display.BottomCenterReferencePoint)
		screen:insert(self.images.logo)

		transition.to( self.images.logo, { x= self.centerY,time=7000, delay=0, alpha=1.0, transition=easing.outQuad} )

		-- -- title image
		self.images[#self.images+1] = {title=nil}
		self.images.title = display.newImageRect("content/images/logo_title.png", 202, 10) 
		self.images.title.x, self.images.title.y, self.images.title.alpha = self.centerX, self.centerY+25, 0
		self.images.title:setReferencePoint(display.TopCenterReferencePoint)
		screen:insert(self.images.title)

		transition.to( self.images.title, { y= self.centerY+15,time=1000, delay=2000, alpha=1.0, transition=easing.inQuad} )

		-- -- star image
		self.images[#self.images+1] = {star=nil}
		self.images.star = display.newImageRect("content/images/logo_star.png", 14, 12) 
		self.images.star.x, self.images.star.y, self.images.star.alpha = self.centerX, self.centerY, 0
		self.images.star:setReferencePoint(display.TopCenterReferencePoint)
		self:insert(self.images.star)



		transition.to( screen, { x=(display.contentWidth-screen.myWidth)*.5,y=0, time=400, delay=0,alpha=1.0,transition=easing.outQuad,rotation=0})


		self.timer = timer.performWithDelay( 8000, self.timeout, 1 )

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

		-- manage star
		if self.starSpeed > 0 then
			local center = {self.centerX,self.centerY-38}

			self.starDegree = uiObj.rotateOnCircle(self.images.star, center,360, self.starSpeed, self.starDegree, 300)
			self.starSpeed = self.starSpeed - .029
			
			if self.images.star.alpha < 1 then self.images.star.alpha = self.images.star.alpha + .009 end

		end

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
		self.images.background:removeSelf()
		self.images.burst:removeSelf()
		self.images.logo:removeSelf()
		self.images.title:removeSelf()
		self.images.star:removeSelf()

		self.images.blackRect = nil
		self.images.background = nil
		self.images.burst = nil
		self.images.logo = nil
		self.images.title = nil
		self.images.star = nil

		screen:removeSelf()
		screen = nil
	end
	--------
	function screen:transitionAwayFrom()

		if self.state ~= "idle" then return -1 end

		self.state = "paused"
		Runtime:removeEventListener( "orientation", onOrientationChange )
		
		if self.timer ~= nil then
			timer.cancel( self.timer )
			self.timer = nil
		end
		transition.to( screen, { time=400, delay=0,alpha=0,transition=easing.outQuad, onComplete = function()
			screen:destory()
		end
		})

		goToScene(2)

	end	
	--------
	function screen:timeout()
		screen:transitionAwayFrom()
	end
	--------

	Runtime:addEventListener( "orientation", onOrientationChange )

	screen:initialize(params)
	return screen

end

return LoadBrand
