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
    
    --[[DOM = function(this)
        --[[local function recurse(e, parent) 
          local r = parent or {};
          
          local copy = setmetatable(e, {__index = function(s, k) 
                      if (s[k]) then
                        return s[k]; 
                    else
                        return rawget(s, 'Children')[k]; 
                    end 
                end});
                        
           r[e.Tag] = copy;
           
          for _, child in next, e['Children'] do
            for i, v in next, recurse(child, child) do 
                print(v, type(v))
                local v_copy = setmetatable(v, {__index = function(s, k) 
                    if (s[k]) then
                        return s[k]; 
                    else
                        return rawget(s, 'Children')[k]; 
                    end 
                end});
                
                r[e.Tag].Children[#r[e.Tag].Children+1] = v_copy;
            end
          end
          
          return r;
        end
        
        local function recurse(element)
            local result = {};
            
            local elementCopy = setmetatable(element, {
                    __index = function(s, k) 
                        if (rawget(s, k)) then
                            return rawget(s, k); 
                        else
                            return rawget(s, 'Children')[k]; 
                        end 
                    end
                });
            
            result[elementCopy.Tag] = elementCopy;
            
            for _, child in next, elementCopy.Children do
                for index, children in next, recurse(child) do
                    
                end
            end
            
            return result;
        end
        
        local table = recurse(this.Object.Data[1]);
                    
          return setmetatable({}, {
                __index = function(self, k)
                    for i, v in next, table do
                        if (table[i] == k) then
                            return table[i];
                        end
                    end
                end,
            });
      end,]]
  },
}

function M.new(xml, source)  
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