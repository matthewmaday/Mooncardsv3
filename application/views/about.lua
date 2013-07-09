-- About Panel View

-- Moon cards version 2
-- Development by Matthew Maday
-- DBA - Weekend Warrior Collective
-- a 100% not-for-profit developer collective

LoadAbout = {}

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------

function LoadAbout:new(params)

	local screen   = display.newGroup()
	
	------------------------------------------------------------------------------------------
	-- Unique Functions to this view
	------------------------------------------------------------------------------------------

	-- gowebsite(event)
	-- onOrientationChange( event )

	local function gowebsite(event)

		if event.target == screen.texts.web then
			if event.phase == "began" then
				system.openURL("www.evergreentherapies.com")
			end
			return true -- prevents a click through
		end
	end
	--------
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
 			
		self.myWidth	  = display.viewableContentWidth
		self.myHeight     = display.viewableContentHeight

		if self.myWidth > self.myHeight then
			local tmp     = self.myWidth
			self.myWidth  = self.myHeight
			self.myHeight = tmp
		end

		self.centerX, self.centerY = self.myWidth*.5, self.myHeight*.5

		-- create the card display group
		self.groups.aboutCard = display.newGroup()
		screen:insert(self.groups.aboutCard)

		-- create black background
		self.images.lightbox = display.newRect(screen, 0,0,self.myHeight,self.myHeight)
		self.images.lightbox:setReferencePoint( display.TopLeftReferencePoint )
		self.images.lightbox.x,self.images.lightbox.y,self.images.lightbox.alpha = -(self.myWidth*.5),-(self.myHeight*.5),.5
		self.images.lightbox:setFillColor(0,0,0)

		self.images.lightbox:addEventListener("touch", function(event)
				if event.target == self.images.lightbox then
					screen:transitionAwayFrom()
				end
			end
		)

	  	-- Insert the card background
		self.images.background = display.newImageRect(self.groups.aboutCard, "content/images/popup.png", 299, 191)
		screen:insert( self.images.background )

		 -- popup text
		self.texts.bio = display.newText( screen, gBio.bio, 0,  0, 240,200,"Papyrus", 11 )
		self.texts.bio:setTextColor(70, 70, 70)
		screen:insert( self.texts.bio )

		 -- web address text
		self.texts.web = display.newText( screen, gBio.website, 0,  0, 240,30,"Papyrus", 14 )
		self.texts.web:setTextColor(196, 94, 51)
		screen:insert( self.texts.web )

		screen.texts.web:addEventListener("touch", gowebsite)

		-- position content
		screen.x, screen.y = self.centerX, self.centerY
		self.texts.bio.x, self.texts.bio.y = 0, 30
		self.texts.web.x, self.texts.web.y = 0, 66
		
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
		Runtime:removeEventListener("touch", gowebsite)

		transition.to( screen, { time=400, delay=0,alpha=0,transition=easing.outQuad, onComplete = function()
			screen:destory()
		end
		})

	end	
	--------
	function screen:destory()

		destroyView(screen)
		gComponents.support[5] = nil
		
	end
	--------
	function screen:timeout()
		-- not used in this scene
	end
	---------
	function screen:alignContent()

		if gOrientation == "portrait" or gOrientation == "portraitUpsideDown" then

			tweenObject(screen, screen.x, self.centerX, screen.y, self.centerY, 1, 1)
			self.images.lightbox.x,self.images.lightbox.y = -(self.myWidth*.5),-(self.myHeight*.5)-40

		elseif gOrientation == "landscapeRight" or gOrientation == "landscapeLeft" then
			local xLoc = -(self.centerY) - 38

			tweenObject(screen, screen.x, self.centerY, screen.x, self.centerX, 1, 1)
			self.images.lightbox.x,self.images.lightbox.y = xLoc,-(self.myWidth*.5)
		end

	end

	Runtime:addEventListener( "orientation", onOrientationChange )

	screen:initialize(params)
	return screen

end

return LoadAbout
