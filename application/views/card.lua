-- General Card View

-- Moon cards version 2
-- Development by Matthew Maday
-- DBA - Weekend Warrior Collective
-- a 100% not-for-profit developer collective

LoadCard = {}

--------------------------------------------------------------------------------------
-- External Libraries
--------------------------------------------------------------------------------------

function LoadCard:new(params)

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

		-- insert so that we have accurate screen width and height measurements

		-- create the card display group
		self.groups[#self.groups+1] = {card=nil}
		self.groups.card = display.newGroup()
		screen:insert(self.groups.card)

	  	-- Insert the card background
	  	self.images[#self.images+1] = {cardBkg=nil}
		self.images.cardBkg = display.newImageRect(self.groups.card, "content/images/card_card.png", 320, 428)
		self.groups.card:insert( self.images.cardBkg )

		-- banner
		self.images[#self.images+1] = {bannerBkg=nil}
		self.images.bannerBkg = display.newImageRect("content/images/card_banner.png", 340, 82) 
		self.groups.card:insert(self.images.bannerBkg)

		-- banner text
		self.texts[#self.texts+1] = {banner=nil}
		self.texts.banner = display.newText( self.groups.card, gRecord.title,  self.groups.card.width*.5, -20, "Papyrus", 16 )
		self.texts.banner:setReferencePoint(display.CenterReferencePoint)
		self.groups.card:insert(self.texts.banner)

		-- set initial positions
		screen.x, screen.y = self.centerX, self.centerY-20
		self.images.bannerBkg.x, self.images.bannerBkg.y = 0,-150
		self.texts.banner.x, self.texts.banner.y = 0,-155


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
	function screen:destory()

		local pEnd = #self.images
		
		screen.groups.card:removeSelf()
		screen.images.cardBkg:removeSelf()

		screen.texts.body = nil
		screen.groups.card = nil
		screen.images.cardBkg = nil

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

		goToScene(4)

	end	
	--------
	function screen:timeout()
		-- not used in this scene
	end
	--------
	function screen:alignContent()

		local pBanner    = self.images.bannerBkg
		local pCard      = self.groups.card
		local pBannerTxt = self.texts.banner
		local cardHeight = self.images.cardBkg.height
		local cardWidth  = self.images.cardBkg.width



		if gOrientation == "portrait" or gOrientation == "portraitUpsideDown" then

			-- card
			pCard.xScale,pCard.yScale = 1.0,1.0
			tweenObject(screen, screen.x,self.centerX, screen.y, self.centerY-20,.5, 1)

			-- banner
			tweenObject(pBanner, pBanner.x,0, -220, -150,1, 1)
			
			-- banner text
			tweenObject(pBannerTxt,pBannerTxt.x,0, -225, -155,1, 1)

		elseif gOrientation == "landscapeRight" or gOrientation == "landscapeLeft" then

			-- card
			pCard.xScale,pCard.yScale = .75,.75
			tweenObject(screen, screen.x,self.centerY, screen.y, self.centerX,.5, 1)
			
			-- banner
			tweenObject(pBanner, pBanner.x,0, -220, -150,1, 1)

			-- banner text
			tweenObject(pBannerTxt,pBannerTxt.x,0, -225, -155,1, 1)

		end

	end
	--------
	function screen:refreshCard()

		selectRecord()

		self.texts.banner.text = gRecord.title
		self.texts.banner:setReferencePoint(display.CenterReferencePoint)

		gComponents.support[4]:updateText()

		screen.y = screen.y - 50
		screen:alignContent()
	end


	Runtime:addEventListener( "orientation", onOrientationChange )

	screen:initialize(params)
	return screen

end

return LoadCard
