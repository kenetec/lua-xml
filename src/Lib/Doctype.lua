local M = {};

local Meta = {
  __type = "DOCTYPE";
  __tostring = function(this) return '<!DOCTYPE'..this.Data..'>'; end
}

function M.new(data)
  return setmetatable({
    Data = data;
  }, Meta);
end

return M;