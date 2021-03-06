-- Score Module
--

local M = {} -- create our local M = {}
M.score = 0

function M.init( options )
	local customOptions = options or {}
	local opt = {}
	opt.fontSize = customOptions.fontSize or 24
	opt.font = customOptions.font or native.systemFontBold
	opt.x = customOptions.x or display.contentCenterX
	opt.y = customOptions.y or opt.fontSize * 0.5
	opt.maxDigits = customOptions.maxDigits or 6
	opt.leadingZeros = customOptions.leadingZeros or false
	opt.align = customOptions.align or "left"
	opt.width = customOptions.width or 100
	M.filename = customOptions.filename or "scorefile.txt"

	local prefix = ""
	if opt.leadingZeros then 
		prefix = "0"
	end
	
	local text_options = 
	{  
		text = "",
		x = opt.x,
		y = opt.y,
		width = opt.width,     --required for multi-line and alignment
		font = opt.font,   
		fontSize = opt.fontSize,
		align = opt.align  --new alignment parameter
	}
	
	M.scoreText = display.newText(text_options)
	return M.scoreText
end

function M.set( value )
	M.score = value
	M.refreshScore()
end

function M.get()
	return M.score
end

function M.add( amount )
	M.score = M.score + amount
	M.refreshScore()
end

function M.minus( amount )
	M.score = M.score - amount
	M.refreshScore()
end

function M.reset()
	M.score = 0
	M.refreshScore()
end

function M.refreshScore()
	--M.scoreText.text = string.format(M.format, M.score)
	M.scoreText.text = M.score
end

function M.createFile()
	local contents = "0"
	file = io.open( path, "w" )
	file:write( contents )
	io.close( file )
	print("New Score File created: ", M.filename, ".")
	return true
end

function M.save()
	local path = system.pathForFile( M.filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = tostring( M.score )
        file:write( contents )
        io.close( file )
		print("Saved! Score is: " .. M.score)
        return true
    else
		local contents = tostring( M.score )
		file = io.open( path, "w" )
		file:write( contents )
		io.close( file )
    	print("Error: could not read ", M.filename, ".")
        return false
    end
end

function M.load()
    local path = system.pathForFile( M.filename, system.DocumentsDirectory)
    local contents = ""
    local file = io.open( path, "r" )
    if file then
         -- read all contents of file into a string
         local contents = file:read( "*a" )
         local score = tonumber(contents);
         io.close( file )
		 print("Load! Score is: " .. score)
         return score
	else
		M.createFile()
        return false
    end
	
    print("Could not read scores from ", M.filename, ".")
    return nil
end

return M
