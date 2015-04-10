local M = {};

local Meta = {
  __type = "CDATA";
  __tostring = function(this) return '<![CDATA['..this.Data..']]>'; end
}

function M.new(data)
  return setmetatable({
    Data = data;
  }, Meta);
end

return M;