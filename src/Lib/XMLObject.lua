local M = {};

local Base_Meta = {
  __index = {
    GetData = function(this)
      return this.Object.Data;
    end,
    
    GetComments = function(this)
      return this.Object.Comments;
    end,
    
    GetPreprocessing = function(this)
      return this.Object.Preprocessing;
    end,
    
    GetSchemas = function(this)
      return this.Object.Schemas;
    end,
    
    --[[FileTextFormat = function(this)
      this.Source = this.Source:gsub();
    end]]
  },
}

local Meta = {
  __index = {
    GetDataObject = function(this)
      local Data_Meta = {
        __index = function(self, key)
          if (key:sub(1, 1) == '$') then
            return rawget(self, key:sub(2));
          else
            for i, v in next, rawget(self, 'Data') do
              if (v["@Tag"] == key) then
                return v;
              end
            end
          end      
        end,
      }
      
      local o = setmetatable({
          Data = this.Object.Data;
      }, Data_Meta);
  
      o.GetElements = function(self, id, occurances)
        occurances = occurances or nil;
        
        local matched = 1;
        local result = {};
        
        for _, element in next, self.Data do
          if (element['@Tag'] == id) then
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
          for _, child in next, e['@Children'] do
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
    
    GetSource = function(this)
      return this.Source;
    end,
    
    GetData = function(this)
      return this.Object.Data;
    end,
    
    GetComments = function(this)
      return this.Object.Comments;
    end,
    
    GetPreprocessing = function(this)
      return this.Object.Preprocessing;
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
        ["Preprocessing"] = {};
        ["Data"] = {};
        ["Schemas"] = {};
      };
      
      Source = source or "";
    }, xml_meta);
end

return M;