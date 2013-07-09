-- Button Panel View

-- Moon cards version 2
-- Development by Matthew Maday
-- DBA - Weekend Warrior Collective
-- a 100% not-for-profit developer collective

LoadButtons = {}

function LoadButtons:new(params)

	local screen   = display.newGroup()
	
	------------------------------------------------------------------------------------------
	-- Unique Functions to this view
	------------------------------------------------------------------------------------------

	-- onOrientationChange( event )
	-- getButton(image,name,pos,endpos,w,h)
	-- onButtonTouch(event)
	-- buttonPress(obj)
	

	local function onOrientationChange( event )

		if screen == nil then return -1 end
		if screen.state ~= "idle" then return -1 end

	 	local delta = event.delta

		if screen.rotation == 0 and delta < 0 then
			local newAngle = delta-screen.rotation
		else
			local newAngle = delta-screen.rotation
		end
	
		screen:alignContent()

	end
	--------
	function screen:getButton(image,name,pos,endpos,w,h)

		local options = {{ name=name, frames={pos,endpos}, time=0, loopCount=2 }}
		local img = display.newSprite(image, options)

		img:setFrame(1)
		self:insert(img)
		
		function img:touch(event)
			screen:onButtonTouch(event)
		end
		img:addEventListener("touch",img)
		return img
	end
	--------
	function screen:onButtonTouch(event)

		if event.target == self.images.about then 

			if event.phase == "began" then
				if gComponents.support[5] ~= nil then return -1 end

				loadAbout()
				screen:buttonPress(self.images.about)
			end
		elseif event.target == self.images.share then 

			if event.phase == "began" then
				if gComponents.support[5] ~= nil then 
					gComponents.support[5]:transitionAwayFrom()
				end
				
				postMessage( event )
				screen:buttonPress(self.images.share)
			end

		elseif event.target == self.images.refresh then 

			if gComponents.support[5] ~= nil then 
				gComponents.support[5]:transitionAwayFrom()
			end
			if event.phase == "began" then
				gComponents.support[2]:refreshCard()
				screen:buttonPress(self.images.refresh)
			end

		end

		return true
	end
	--------
	function screen:buttonPress(obj)

			obj:setFrame(2)

			if obj.timer ~= nil then
				timer.cancel(obj.timer)
			end
				
			obj.timer = timer.performWithDelay( 200, function()
				obj:setFrame(1)
				obj.timer = nil
			end)

	end
	
	------------------------------------------------------------------------------------------
	-- Common Functions for all views
	------------------------------------------------------------------------------------------

	-- initialize(params, event)
	-- show(time)
	-- hide(time)
	-- activate()
	-- process()
	-- pause()
	-- transitionAwayFrom()
	-- destory()
	-- timeout()
	-- alignContent()


	function screen:initialize(params, event)

		self.images, self.texts, self.groups = {},{},{}

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

		local options = {
			width              = 106,   -- width of one frame
			height             = 38.5,  -- height of one frame
			numFrames 		   = 6,     -- total number of frames in spritesheet
		    sheetContentWidth  = 320,   -- width of original 1x size of entire sheet
    		sheetContentHeight = 77     -- height of original 1x size of entire sheet
		}

		-- create a blank background - important for orientation and predictable image placement
		self.images.blackRect = display.newRect(screen, 0,0,self.myHeight,options.height)
		self.images.blackRect:setReferencePoint( display.TopLeftReferencePoint )
		self.images.blackRect.x,self.images.blackRect.y     = 0,0
		self.images.blackRect:setFillColor(32,98,117)
		
		self:insert(self.images.blackRect)

		-- button sheet
		self.images.buttonSheet = graphics.newImageSheet("content/images/buttons.png", options)
		
		-- about button
		self.images.about  = self:getButton(self.images.buttonSheet, "about", 1,4,options.width,options.height)
		self.images.about.x, self.images.about.y = self.centerY-options.width, options.height*.5

		-- share button
		self.images.share  = self:getButton(self.images.buttonSheet, "share", 2,5,options.width,options.height)
		self.images.share.x, self.images.share.y = self.centerY, options.height*.5

		-- refresh button
		self.images.refresh  = self:getButton(self.images.buttonSheet, "refresh", 3,6,options.width,options.height)
		self.images.refresh.x, self.images.refresh.y = self.centerY+options.width, options.height*.5

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
	function screen:transitionAwayFrom()

		if self.state ~= "idle" then return -1 end

		self.state = "paused"
		Runtime:removeEventListener( "orientation", onOrientationChange )
		

		transition.to( screen, { time=400, delay=0,alpha=0,transition=easing.outQuad, onComplete = function()
			screen:destory()
		end
		})

		goToScene(4)

	end	
	--------
	function screen:destory()
		destroyView(screen)
	end
	--------
	function screen:timeout()
		-- not used in this scene
	end
	--------
	function screen:alignContent()

		if gOrientation == "portrait" or gOrientation == "portraitUpsideDown" then
			screen.rotation = 0
			tweenObject(screen, self.centerX-screen.width*.5, self.centerX-screen.width*.5, self.myHeight-screen.height+40, self.myHeight-screen.height, 1, 1)
		elseif gOrientation == "landscapeRight" or gOrientation == "landscapeLeft" then
			screen.rotation = -90
			tweenObject(screen, self.myHeight, self.myHeight-screen.height, self.centerX+screen.width*.5, self.centerX+screen.width*.5, 1, 1)
		end

	end


	Runtime:addEventListener( "orientation", onOrientationChange )

	screen:initialize(params)
	return screen

end

return LoadButtons
