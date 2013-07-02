-- General Title View

-- Moon cards version 2
-- Development by Matthew Maday
-- DBA - Weekend Warrior Collective
-- a 100% not-for-profit developer collective

LoadTitle = {}

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------

function LoadTitle:new(params)

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
	
		screen:alignContent()

	end
	--------
	function screen:initialize(params, event)

		self.images       = {}
		self.listeners    = {}
		self.timer        = nil
		self.myWidth	  = display.contentHeight
		self.myHeight     = display.contentWidth
		self.stars        = {}
		self.starSpeed    = 2
		self.starDegree   = 150

		if self.myWidth > self.myHeight then
			local tmp     = self.myWidth
			self.myWidth  = self.myHeight
			self.myHeight = tmp
		end

		print("width and height",self.myWidth,self.myHeight)

		self.centerX, self.centerY = self.myWidth*.5, self.myHeight*.5

		-- center moon
		self.images[#self.images+1] = {sun=nil}
		self.images.sun = display.newImageRect("content/images/home_sunmoon.png", 104, 107) 
		self.images.sun.x, self.images.sun.y, self.images.sun.alpha = self.centerX, self.centerY, 0
		self.images.sun:setReferencePoint(display.CenterReferencePoint)
		screen:insert(self.images.sun)

		transition.to( self.images.sun, { time=2000, delay=100, alpha=1.0} )

   		-- title
		self.images[#self.images+1] = {title=nil}
		self.images.title = display.newImageRect("content/images/home_title.png", 289, 49) 
		self.images.title.x, self.images.title.y, self.images.title.alpha = self.centerX, self.myHeight*.1, 0
		self.images.title:setReferencePoint(display.CenterReferencePoint)
		screen:insert(self.images.title)

		transition.to( self.images.title, { time=2000, delay=0, alpha=1.0} )

		-- continue button
		self.images[#self.images+1] = {continue=nil}
		self.images.continue = display.newImageRect("content/images/home_begin.png", 104, 37) 
		self.images.continue.x, self.images.continue.y, self.images.continue.alpha = self.centerX, self.myHeight*.9, 0
		self.images.continue:setReferencePoint(display.CenterReferencePoint)
		screen:insert(self.images.continue)

		transition.to( self.images.continue, { time=2000, delay=0, alpha=1.0} )

		-- reset the position in case the screen starts off as a landscape view
		transition.to( screen, { x=(display.contentWidth-screen.myWidth)*.5,y=0, time=400, delay=0,alpha=1.0,transition=easing.outQuad})
		screen:alignContent()

		self.timer = timer.performWithDelay( 200, screen.addStar )
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

		local pEnd = #screen.stars

		for i=pEnd,1,-1 do

			local star = screen.stars[i]

			if star.y > (screen.myHeight+100) or star.y < -100 or star.x > (screen.myWidth+100) or star.x < -100 then

				star.x, star.y, star.alpha = screen.centerX, screen.centerY, 0
				star.rotation = (math.random(1,2)*2)-3

				local degrees = math.random(360)
				local radius  = 1+math.random(3)
				local rads    = degrees * (math.pi / 180.0)

				star.width,star.height = 1,1

				star.xSpeed, star.ySpeed = radius/2 * math.cos(rads), radius/2 * math.sin(rads)
				star:setReferencePoint(display.CenterReferencePoint)

			else

				local pAlpha    = star.alpha + .01
				local pRotation = (star.rotation > 360) and 0 or (star.rotation + 1)

				if pAlpha > 1 then pAlpha = 1 end
				star.width,star.height = star.width + .10, star.height + .10

				transition.to( star, { x=star.x+star.xSpeed, y=star.y+star.ySpeed,rotation=pRotation,time=0, delay=0, alpha=pAlpha})

			end
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
		
		self.images.sun:removeSelf()
		self.images.title:removeSelf()
		self.images.continue:removeSelf()

		self.images.sun      = nil
		self.images.title    = nil
		self.images.continue = nil

		local pEnd = #screen.stars
		for i=1,pEnd,1 do
			screen.stars[i]:removeSelf()
			screen.stars[i] = nil
		end
		
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

		goToScene(3)

	end	
	--------
	function screen:addStar()
		
		if #screen.stars < 40 then
			
			print("added star number", #screen.stars+1)

			screen.timer = timer.performWithDelay( 200, screen.addStar, 1 )

			local t = #screen.stars+1
			screen.stars[t] = display.newImageRect("content/images/home_star.png", 5, 5) 
			screen.stars[t].x, screen.stars[t].y, screen.stars[t].alpha = screen.centerX, screen.centerY, 0
			screen.stars[t].rotation    = (math.random(1,2)*2)-3

			local degrees = math.random(360)
			local radius  = 1+math.random(3)
			local rads    = degrees * (math.pi / 180.0)

			screen.stars[t].xSpeed, screen.stars[t].ySpeed = radius/2 * math.cos(rads), radius/2 * math.sin(rads)
			screen.stars[t]:setReferencePoint(display.CenterReferencePoint)
			screen:insert(screen.stars[t])

		end

	end
	--------
	function screen:alignContent()

		if system.orientation == "portrait" or system.orientation == "portraitUpsideDown" then
			transition.to( self.images.title, { y=30, time=400, delay=0,transition=easing.outQuad})
			transition.to( self.images.continue, { y=self.myHeight-30, time=400, delay=0,transition=easing.outQuad})
			transition.to( self.images.sun, { y=self.centerY,  time=400, delay=0,transition=easing.outQuad})
		else
			transition.to( self.images.title, { y=30, time=400, delay=0,transition=easing.outQuad})
			transition.to( self.images.continue, { y=display.contentHeight-30, time=400, delay=0,transition=easing.outQuad})
			transition.to( self.images.sun, { y=self.centerX,  time=400, delay=0,transition=easing.outQuad})
		end

end
	--------

	Runtime:addEventListener( "orientation", onOrientationChange )

	screen:initialize(params)
	return screen

end

return LoadTitle
