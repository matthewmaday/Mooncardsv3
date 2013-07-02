
-- Set location for saved data

-- external libraries
require "io"
local json       = require "json"
local str = require("library.core.str")

-- local variables
local fileio = {}
local fileio_mt  = { __index = fileio }	-- metatable
 
-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

 
-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

-- fileio.new(file)
-- fileio:readFile()	
-- 

function fileio.new(file)	-- constructor

	local newfileIo = {
			   file = file
	}

	return setmetatable( newfileIo, fileio_mt )
end
--------
function fileio:readFile()	

	local result = io.open( self.file, "r" )
	
	if result then

	-- Read file contents into a string
	local dataStr = result:read( "*a" )

	io.close( result ) -- important!

	return dataStr

	else

		return ""
	end
end
--------
function fileio:writeFile(data)

-- Determines which file mode to open the file in. The mode string can be any of the following:
--   "r": read mode (the default); The file pointer is placed at the beginning of the file.
--   "w": write-only mode; Overwrites the file if the file exists. If the file does 
--        not exist, creates a new file for writing.
--   "a": append mode (write only); The file pointer is at the end of the file if the 
--        file exists. That is, the file is in the append mode. If the file does not exist, 
--        it creates a new file for writing.
--   "r+": update mode (read/write), all previous data is preserved; The file pointer will 
--        be at the beginning of the file. If the file exists, it will only be overwritten 
--        if you explicitly write to it.
--   "w+": update mode (read/write), all previous data is erased; Overwrites the existing 
--        file if the file exists. If the file does not exist, creates a new file for 
--        reading and writing.
--   "a+": append update mode (read/write); previous data is preserved, writing is only 
--         allowed at the end of file. The file pointer is at the end of the file if the 
--         file exists. The file opens in the append mode. If the file does not exist, it 
--         creates a new file for reading and writing.

--   The mode string can also have a 'b' at the end, which is needed in some systems to open 
--   the file in binary mode. This string is exactly what is used in the standard C function fopen.

	local file = io.open(self.file, "w+" )
	file:write( data )
	io.close( file )

	-- This removes the file just created
	-- os.remove( filePath )

end

return fileio

