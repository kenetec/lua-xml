package.path =".\\?.lua;" .. package.path;

local M = {};
------------------------------------------------------------------------------
local Reader = require('src.Reader');
local Writer = require('src.Writer');
------------------------------------------------------------------------------
function M.Load(arg)
    --f = f or function() end;
    
    local file = io.open(arg, 'r');
    if (file) then 
        local data = Reader.Read(file);
        file:flush();
        return data;
    else
        return Reader.Read(arg);
    end
end
------------------------------------------------------------------------------
function M.typeof(o)
    if (type(o) == "table") then
        if (getmetatable(o)) then
            return getmetatable(o).__type;
        end
    end
    return type(o);
end
------------------------------------------------------------------------------
return M;