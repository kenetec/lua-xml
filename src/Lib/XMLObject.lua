local M = {};

local Base_Meta = {
  __index = {
    GetData = function(this)
      return this.Object.Data;
    end,
    
    GetComments = function(this)
      return this.Object.Comments;
    end,
    
    GetProcessing = function(this)
      return this.Object.Processing;
    end,
    
    GetSchemas = function(this)
      return this.Object.Schemas;
    end,
    
    GetCDATA = function(this)
      return this.Object.CDATA;
    end,
    
    GetDOCTYPE = function(this)
      return this.Object.DOCTYPE;
    end
  },
}

local Meta = {
  __index = {
    GetDataObject = function(this)
      local Data_Meta = {};
      
      local o = setmetatable({
          Data = this.Object.Data;
      }, Data_Meta);
  
      o.GetElements = function(self, id, occurances)
        occurances = occurances or nil;
        
        local matched = 1;
        local result = {};
        
        for _, element in next, self.Data do
          if (element['Tag'] == id) then
            if (occurances ~= nil) then
              if (matched <= occurances) then
                result[#result+1] = element;
              else
                break;
              end
            else
              result[#result+1] = element;
            end
            matched = matched + 1;
          end
        end
        
        if (occurances) then
          if (occurances == 1) then
            return result[1];
          end
        end
        
        return result;
      end
      
      o.GetRootElement = function(self)
        for _, element in next, self.Data do
          return element;
        end
      end
      
      o.GetAllElements = function(self)        
        local result = {};
        
        local cl = 1;
        
        local function recurse(e)        
          local r = {}
          for _, child in next, e['Children'] do
            r[#r + 1] = child;
            for i, v in next, recurse(child) do r[#r + 1] = v; end
          end
          
          return r;
        end
        
        for _, element in next, this:GetData() do
          result[#result+1] = element;
          for _, child in next, recurse(element) do
            result[#result+1] = child;
          end
        end
        
        return result;
      end
      
      return o;
    end,
  },
}

function M.new(xml, source)
  file = file or nil;
  
  local xml_meta = {
    __type = "XMLObject";
    __index = {};
    __tostring = function(this) return tostring(rawget(this, "Source")); end,
  };
  
  for i, v in next, Base_Meta.__index do
    xml_meta.__index[i] = v;
    for a, b in next, Meta.__index do
      xml_meta.__index[a] = b;
    end
  end
  
  return setmetatable({
      Object = xml or {
        ["Comments"] = {};
        ["Processing"] = {};
        ["Data"] = {};
        ["Schemas"] = {};
        ["CDATA"] = {};
        ["DOCTYPE"] = "";
      };
      
      Source = source or "";
    }, xml_meta);
end

return M;