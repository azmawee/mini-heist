-- Playdate CoreLibs: Graphics addons
-- Copyright (C) 2014 Panic, Inc.

import 'CoreLibs/string'

local g = playdate.graphics
local geom = playdate.geometry
local trimWhitespace = playdate.string.trimWhitespace
local trimTrailingWhitespace = playdate.string.trimTrailingWhitespace
local PI = 3.141592653589793
local TWO_PI = 6.283185307179586



-- function playdate.graphics.drawCircleInRect(x, y, w, h)
-- function playdate.graphics.drawCircleInRect(r)
function playdate.graphics.drawCircleInRect(x,...)
	local y, w, h, lineWidth
	if (type(x) == "userdata") then		-- check if x is a playdate.geometry.rect object
		x, y, w, h = x.x, x.y, x.width, x.height
	else
		y, w, h = select(1, ...)
	end
	
	-- if the rect passed in wasn't a square, we still want to draw a circle
	if w > h then
		x = x + ((w - h) / 2)
		w = h
	elseif h > w then
		y = y + ((h - w) / 2)
		h = w
	end

	g.drawEllipseInRect(x, y, w, h)
end


-- function playdate.graphics.fillCircleInRect(x, y, w, h)
-- function playdate.graphics.fillCircleInRect(rect)
function playdate.graphics.fillCircleInRect(x,...)
	local y, w, h
	if (type(x) == "userdata") then		-- check if x is a playdate.geometry.rect object
		x, y, w, h = x.x, x.y, x.width, x.height
	else
		y, w, h = select(1, ...)
	end

	-- if the rect passed in wasn't a square, we still want to draw a circle
	if w > h then
		x = x + ((w - h) / 2)
		w = h
	elseif h > w then
		y = y + ((h - w) / 2)
		h = w
	end

	g.fillEllipseInRect(x, y, w, h)
end


-- function playdate.graphics.drawCircleAtPoint(x, y, radius)
-- function playdate.graphics.drawCircleAtPoint(point, radius)
function playdate.graphics.drawCircleAtPoint(x, ...)
	local y, radius, lineWidth
	if (type(x) == "userdata") then		-- check if x is a playdate.geometry.point object
		x, y = x.x, x.y
		radius = select(1, ...)
	else
		y, radius = select(1, ...)
	end

	local d = radius * 2
	g.drawEllipseInRect(x-radius, y-radius, d, d)
end


-- function playdate.graphics.fillCircleAtPoint(x, y, radius)
-- function playdate.graphics.fillCircleAtPoint(point, radius)
function playdate.graphics.fillCircleAtPoint(x, ...)

	local y, radius
	if (type(x) == "userdata") then		-- check if x is a playdate.geometry.point object
		x, y = x.x, x.y
		radius = select(1, ...)
	else
		y, radius = select(1, ...)
	end
	
	local d = radius * 2
	g.fillEllipseInRect(x-radius, y-radius, d, d)
end



local lineWidthNag = true
function playdate.graphics.drawArc(x, ...)

	local y, radius, startAngle, endAngle
	local tempLineWidth = nil
	
	if (type(x) == "userdata") then
		if x.clockwise then
			x, y, radius, startAngle, endAngle = x.x, x.y, x.radius, x.startAngle, x.endAngle
		else
			x, y, radius, endAngle, startAngle = x.x, x.y, x.radius, x.startAngle, x.endAngle
		end
		tempLineWidth = select(1, ...)
	else
		y, radius, startAngle, endAngle, tempLineWidth = select(1, ...)
	end
	
	if lineWidthNag == true and tempLineWidth ~= nil then
		print("Warning: playdate.graphics.drawRoundRect no longer accepts a lineWidth argument, please set the line width using playdate.graphics.setLineWidth() instead")
		lineWidthNag = false
	end

	local d = radius * 2
	g.drawEllipseInRect(x-radius, y-radius, d, d, startAngle, endAngle)	
	
end




local deg = math.deg
local atan2 = math.atan2

-- xstart, xend, y, amplitude, period, phase shift
function playdate.graphics.drawSineWave(x1, y1, x2, y2, a1, a2, p, ps)
	
	assert(p > 0, "period must be > 0")

	local r = math.deg(math.atan2((y2 - y1), (x2 - x1)))
			
	-- low precision fast sine approximation
	local function lp_sin(x)
		if x < -PI then
			x += TWO_PI
		elseif x >  PI then
			x -= TWO_PI
		end

		if x < 0 then
			return 1.27323954 * x + .405284735 * x * x;
		else
			return 1.27323954 * x - 0.405284735 * x * x;
		end
	end
	
	local points = {}	
	local xspacing = 3
	local w = geom.distanceToPoint(x1, y1, x2, y2)
		
	local theta = 0
	if ps ~= nil then
		theta = TWO_PI * ((ps % p) / p)
	end

	local delta = (TWO_PI / p) * xspacing
	
	local x = 0
	local y = lp_sin(theta) * a1
	
	points[#points+1] = x
	points[#points+1] = y

	for _ = xspacing, w, xspacing do
		
		local ia = a1 + (a2 - a1) * (x/w)
		
		y = lp_sin(theta) * ia

		points[#points+1] = x
		points[#points+1] = y
		
		x += xspacing
		theta += delta
		if theta > TWO_PI then theta = theta - TWO_PI end
	end
	
	-- calculate the final point
	theta = TWO_PI * ((w % p) / p)
	y = lp_sin(theta) * a2
	points[#points+1] = w
	points[#points+1] = y
	
	local poly = geom.polygon.new(table.unpack(points))
	local af = geom.affineTransform.new()
		
	if r ~= 0 then
		af:rotate(r)		
	end

	af:translate(x1, y1)
	af:transformPolygon(poly)
	
	g.drawPolygon(poly)
end


function playdate.graphics.image.drawAnchored(self, x, y, cx, cy, flip)
	local w, h = self:getSize()
	self:draw(x - cx * w, y - cy * h, flip)
end


function playdate.graphics.image:drawCentered(x, y, flip)
	local w, h = self:getSize()
	self:draw(x - w * 0.5, y - h * 0.5, flip);
end


kTextAlignment = {
	left = 0,
	right = 1,
	center = 2,
}



local function _styleCharacterForNewline(line)
	local _, boldCount = string.gsub(line, "*", "*")
	if ( boldCount % 2 ~= 0 ) then
		return "*"
	end
	
	local _, italicCount = string.gsub(line, "_", "_")
	if ( italicCount % 2 ~= 0 ) then
		return "_"
	end

	return ""
end

local function _addStyleToLine(style, line)
	if #style == 0 then
		return line
	elseif line:sub(1,1) == style then
		return line:sub(2,-1)
	else
		return style .. line
	end
end

-- XXX: doesn't break Japanese characters correctly
-- returns (requiredWidth, requiredHeight, textWasTruncated) - the smallest size up to `width` wide that the text will fit inside, and a boolean indicating if the text had to be truncated
local function _layoutTextInRect(shouldDrawText, str, x, ...)

	if str == nil then 
		return 0, 0, false, nil 
	end
	
	-- returnStringInfo is used to return a table of line information for later drawing into an image
	local y, width, height, lineHeightAdjustment, truncator, textAlignment, singleFont, returnStringInfo
	if (type(x) == "userdata") then		-- check if x is a playdate.geometry.rect object
		x, y, width, height = x.x, x.y, x.width, x.height
		lineHeightAdjustment, truncator, textAlignment, singleFont, returnStringInfo = select(1, ...)
	else
		y, width, height, lineHeightAdjustment, truncator, textAlignment, singleFont, returnStringInfo = select(1, ...)
	end
	
	local stringInfo = nil
	if returnStringInfo == true then
		stringInfo = {}
		stringInfo.textAlignment = textAlignment
		stringInfo.singleFont = singleFont
	end
	
	if width < 0 or height < 0 then
		return 0, 0, false, nil
	end
	
	local font = nil
	if singleFont == nil then 
		font = g.getFont()
		if font == nil then print('error: no font set!') 
			return 0, 0, false, nil 
		end
	end
	
	y = math.floor(y)
	x = math.floor(x)
	lineHeightAdjustment = math.floor(lineHeightAdjustment or 0)
	if truncator == nil then truncator = "" end
	
	local top = y
	local bottom = y + height
	local currentLine = ""
	local lineWidth = 0
	local firstWord = true

	local lineHeight
	local fontLeading
	local fontHeight
	if singleFont == nil then 
		fontLeading = font:getLeading()
		fontHeight = font:getHeight()
		lineHeight = fontHeight + fontLeading
	else
		fontLeading = singleFont:getLeading()
		fontHeight = singleFont:getHeight()
		lineHeight = fontHeight + fontLeading
	end
	-- local unmodifiedLineHeight = lineHeight
	
	local maxLineWidth = 0
	
	if height < fontHeight then
		return 0, 0, false	-- if the rect is shorter than the text, don't draw anything
	else
		lineHeight += lineHeightAdjustment
	end
	
	local function getLineWidth(text)
		if singleFont == nil then
			return g.getTextSize(text)		
		else
			return singleFont:getTextWidth(text)
		end
	end
	
	local function drawAlignedText(t, twidth)
		
		if twidth > maxLineWidth then
			maxLineWidth = twidth
		end
		
		if stringInfo ~= nil then
			stringInfo[#stringInfo+1] = {
				text = t,
				width = twidth,
				y = y
			}
		end
		
		if shouldDrawText == false then
			return
		end
		
		local alignedX = x
		if textAlignment == kTextAlignment.right then
			alignedX = x + width - twidth
		elseif textAlignment == kTextAlignment.center then
			alignedX = x + ((width - twidth) / 2)
		end
		if singleFont == nil then
			g.drawText(t, alignedX, y)
		else
			singleFont:drawText(t, alignedX, y)
		end
	end
	
	local function utf8sub(s,i,j)
		i=utf8.offset(s,i)
		if j ~= -1 then j=utf8.offset(s,j+1)-1 end
		return string.sub(s,i,j)
	end
	
	local function drawTruncatedWord(wordLine)
		lineWidth = getLineWidth(wordLine)
		local truncatedWord = wordLine
		local stylePrefix = _styleCharacterForNewline(truncatedWord)
		
		while lineWidth > width and utf8.len(truncatedWord) > 1 do	-- shorten word until truncator fits
			truncatedWord = utf8sub(truncatedWord, 1, -2)		-- remove last character, and try again
			lineWidth = getLineWidth(truncatedWord)
		end

		drawAlignedText(truncatedWord, lineWidth)
	
		local remainingWord = _addStyleToLine(stylePrefix, utf8sub(wordLine, utf8.len(truncatedWord)+1, -1))

		lineWidth = getLineWidth(remainingWord)
		firstWord = true
		return remainingWord
	end
	
	
	local function drawTruncatedLine()
		currentLine = trimTrailingWhitespace(currentLine)	-- trim whitespace at the end of the line
		lineWidth = getLineWidth(currentLine .. truncator)
		
		while lineWidth > width and getLineWidth(currentLine) > 0 do	-- shorten line until truncator fits
			currentLine = utf8sub(currentLine, 1, -2)	-- remove last character, and try again
			lineWidth = getLineWidth(currentLine .. truncator)
		end
		
		currentLine = currentLine .. truncator
		lineWidth = getLineWidth(currentLine)
		firstWord = true

		drawAlignedText(currentLine, lineWidth)
		
		local textBlockHeight = y - top + fontHeight
		return maxLineWidth, textBlockHeight, true, stringInfo
	end
	
	
	local function drawLineAndMoveToNext(firstWordOfNextLine)

		firstWordOfNextLine = _addStyleToLine(_styleCharacterForNewline(currentLine), firstWordOfNextLine)
		
		drawAlignedText(currentLine, lineWidth)
		y += lineHeight
		currentLine = firstWordOfNextLine
		lineWidth = getLineWidth(firstWordOfNextLine)
		firstWord = true
	end
	
	
	local lines = {}
	local i = 1
	for line in str:gmatch("[^\r\n]*") do		-- split into hard-coded lines
		lines[i] = line
		i += 1
	end
	
	local line
		
	for i = 1, #lines do
		line  = lines[i]
		
		local firstWordInLine = true
		local leadingWhiteSpace = ""
		
		for word in line:gmatch("%S+ *") do	-- split into words
			
			-- preserve leading space on lines
			if firstWordInLine == true then
				local leadingSpace = line:match("^%s+")
				if leadingSpace ~= nil then
					leadingWhiteSpace = leadingSpace
				end
				firstWordInLine = false
			else
				leadingWhiteSpace = ""
			end

			-- split individual words into pieces if they're too wide
			if firstWord then
				if #currentLine > 0 then
					while getLineWidth(leadingWhiteSpace..currentLine) > width do
						currentLine = drawTruncatedWord(leadingWhiteSpace..currentLine)
						y += lineHeight
					end
				else
					word = leadingWhiteSpace .. word
					while getLineWidth(word) > width do
						if y + fontHeight <= bottom then
							if y + lineHeight + fontHeight <= bottom then
								word = drawTruncatedWord(leadingWhiteSpace .. word)
							else 	-- a line after this one will not fit
								currentLine = word
								return drawTruncatedLine() -- no room for another line
							end
							leadingWhiteSpace = ""
						end
						y += lineHeight
					end
				end
				firstWord = false
			end
			
			if getLineWidth(currentLine .. leadingWhiteSpace .. trimWhitespace(word)) <= width then
				currentLine = currentLine .. leadingWhiteSpace .. word
			else 
				if y + lineHeight + fontHeight <= bottom then
					currentLine = leadingWhiteSpace .. trimTrailingWhitespace(currentLine)	-- trim whitespace at the end of the line
					lineWidth = getLineWidth(currentLine)
					drawLineAndMoveToNext(leadingWhiteSpace .. word)
				else
					-- the next line is lower than the boundary, so we need to truncate and stop drawing
					currentLine = leadingWhiteSpace ..currentLine .. word
					if y + fontHeight <= bottom then
						return drawTruncatedLine()
					end
					local textBlockHeight = y - top + fontHeight
					return maxLineWidth, textBlockHeight, true, stringInfo
				end
			end
			
		end
		
		if (lines[i+1] == nil) or (y + lineHeight + fontHeight <= bottom) then
			
			if #currentLine > 0 then
				while getLineWidth(currentLine) > width do
					currentLine = drawTruncatedWord(currentLine)
					y += lineHeight
				end
			end
			
			lineWidth = getLineWidth(currentLine)
			drawLineAndMoveToNext('')
		else
			return drawTruncatedLine()
		end
	end
	
	local textBlockHeight = y - top - lineHeight + fontHeight
	return maxLineWidth, textBlockHeight, false, stringInfo
end


-- XXX: doesn't break Japanese characters correctly
-- playdate.graphics.drawTextInRect(str, x, y, width, height, [leadingAdjustment, [truncationString, [alignment, [font]]]]) 
-- playdate.graphics.drawTextInRect(str, rect, [leadingAdjustment, [truncationString, [alignment, [font]]]]) 
function playdate.graphics.drawTextInRect(str, x, ...)
	return _layoutTextInRect(true, str, x, ...)
end

-- playdate.graphics.getTextSizeForMaxWidth(str, maxWidth, [leadingAdjustment, [font]]])
function playdate.graphics.getTextSizeForMaxWidth(str, maxWidth, lineHeightAdjustment, singleFont)
	local w, h, _ = _layoutTextInRect(false, str, 0, 0, maxWidth, math.maxinteger, lineHeightAdjustment or 0, "", kTextAlignment.left, singleFont)
	return w, h
end

local _originalGetTextSize <const> = playdate.graphics.getTextSize
function playdate.graphics.getTextSize( str )
	if str == nil then
		return 0, 0
	end
	return _originalGetTextSize( str )
end

-- playdate.graphics.imageWithText(text, maxWidth, [maxHeight, [bgColor, [leadingAdjustment, [truncationString, [alignment, [font]]]]]])
-- returns image, textWasTruncated
function playdate.graphics.imageWithText(str, maxWidth, maxHeight, bgColor, lineHeightAdjustment, truncator, textAlignment, singleFont)

	if maxHeight == nil then maxHeight = math.maxinteger end
	if bgColor == nil then bgColor = g.kColorClear end
	
	local w, h, truncated, textInfo = _layoutTextInRect(false, str, 0, 0, maxWidth, maxHeight, lineHeightAdjustment, truncator, textAlignment, singleFont, true)
	
	if textInfo == nil then
		return nil, false
	end
	
	local textAlignment = textInfo.textAlignment
	local singleFont = textInfo.singleFont
	local img = g.image.new(w, h, bgColor)
	g.lockFocus(img)
		
	local function drawAlignedText(t, y, twidth)
		local alignedX = 0
		if textAlignment == kTextAlignment.right then
			alignedX = w - twidth
		elseif textAlignment == kTextAlignment.center then
			alignedX = ((w - twidth) // 2)
		end
		if singleFont == nil then
			g.drawText(t, alignedX, y)
		else
			singleFont:drawText(t, alignedX, y)
		end
	end
	
	local i, line
	for i = 1, #textInfo do
		line = textInfo[i]
		drawAlignedText(line.text, line.y, line.width)
	end
	
	g.unlockFocus()
	return img, truncated
end


function playdate.graphics.drawTextAligned(str, x, y, textAlignment, lineHeightAdjustment)

	local font = g.getFont()
	if font == nil then print('error: no font set!') return 0, 0 end
	local lineHeight = font:getHeight() + font:getLeading() + math.floor(lineHeightAdjustment or 0)
	local ox = x
	str = ""..str -- if a number was passed in, convert it to a string
	local styleCharacterForNewline = ""

	for line in str:gmatch("[^\r\n]*") do		-- split into hard-coded lines
		line = _addStyleToLine(styleCharacterForNewline, line)
		
		local width = g.getTextSize(line)
		
		if textAlignment == kTextAlignment.right then
			x = ox - width
		elseif textAlignment == kTextAlignment.center then
			x = ox - (width / 2)
		end
		
		g.drawText(line, x, y)
		
		y += lineHeight
		styleCharacterForNewline = _styleCharacterForNewline(line)
	end
	
end


function playdate.graphics.font:drawTextAligned(str, x, y, textAlignment, lineHeightAdjustment)
	
	local lineHeight = self:getHeight() + self:getLeading() + math.floor(lineHeightAdjustment or 0)
	local ox = x
	str = ""..str -- if a number was passed in, convert it to a string

	for line in str:gmatch("[^\r\n]*") do		-- split into hard-coded lines
		
		local width = self:getTextWidth(line)
		
		if textAlignment == kTextAlignment.right then
			x = ox - width
		elseif textAlignment == kTextAlignment.center then
			x = ox - (width / 2)
		end
		
		self:drawText(line, x, y)
		
		y += lineHeight
	end
end


-- playdate.graphics.drawLocalizedTextAligned(text, x, y, alignment, [language, [lineHeightAdjustment]])
function playdate.graphics.drawLocalizedTextAligned(text, x, y, alignment, language, lineHeightAdjustment)
	local localizedText = g.getLocalizedText(text, language)
	g.drawTextAligned(localizedText, x, y, alignment, lineHeightAdjustment)
end


-- playdate.graphics.drawLocalizedTextInRect(str, x, y, width, height, [lineHeightAdjustment, [truncator, [textAlignment, [font, [language]]]]])
-- playdate.graphics.drawLocalizedTextInRect(str, rect, [lineHeightAdjustment, [truncator, [textAlignment, [font, [language]]]]])
function playdate.graphics.drawLocalizedTextInRect(text, x, ...)
	
	local index
	if (type(x) == "userdata") then		-- check if x is a playdate.geometry.rect object
		index = 4
	else
		index = 7
	end
	
	local font, language = select(index, ...)	
	local args = table.pack(...)
	
	-- check to see if the language is in the "font" spot, as that's where the docs used to say to put it	
	if language == nil and type(font) == 'number' or type(font) == 'string' then
		language = font
		font = nil
		table.remove(args, index)
	end
	
	local localizedText = g.getLocalizedText(text, language)
	g.drawTextInRect(localizedText, x, table.unpack(args))
end
