--[[
Format:

XML: {
  ["Comments"] = {}; -- Where comments are stored
  ["Preprocessing"] = {}; -- Preprocessing nodes(<?xml?>)
  ["Data"] = {}; -- Where standard nodes at stored
  ["Schemas"] = {}; -- Where schemas are stored
}

Element: {
  ["Tag"] = ""; -- Name of element tag
  ["Attributes"] = {}; -- Attribute storage
  ["Data"] = ""; -- Data
  ["Children"] = {}; -- Sub-children within the element
  ["Reference"] = {"", "url"}; -- Schema reference
}


--]]
package.path = package.path .. ";.\\?.lua";

local M = {};
------------------------------------------------------------------------------
local Reader = require("src.Reader");
local Writer = require("src.Writer");
------------------------------------------------------------------------------
function M.Load(arg, f)
  f = f or function() end;
  
  local file = io.open(arg, 'r');
  if (file) then 
    local data = Reader.Read(file, f);
    file:flush();
    return data;
  else
    return Reader.Read(arg, f);
  end
end
------------------------------------------------------------------------------
function M.CreateWriter(xml)
  return Writer.new(xml);
end
------------------------------------------------------------------------------
return M;