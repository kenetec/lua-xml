local M = {};

function M.newElement(T)
   local Meta = {
    __type = "Element";
    __tostring = function(this)
        return rawget(this, 'Tag');
    end
   }; 
    
  local o = setmetatable(T, Meta);

  o.GetElements = function(this, id, occurances)
    occurances = occurances or nil;
          
    local matched = 1;
    local result = {};
    
    for _, element in next, this['Children'] do
      if (type(id) == "string") then
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
      elseif (type(id) == "number") then
        if (_ == id) then
          return element;
        end
      end
    end
   
    if (occurances) then
      if (occurances == 1) then
        return result[1];
      end
    end
    
    return result;
  end
  
  o.GetElementsByAttributes = function(this, arg, occurances)
    occurances = occurances or nil;
          
    local matched = 1;
    local result = {};
    
    for _, element in next, this['Children'] do
      for ea_key, ea_val in next, element['Attributes'] do
        if (arg[ea_key]) then
          if (arg[ea_key] == ea_val) then
            if (occurances ~= nil) then
              if (matched <= occurances) then
                result[#result+1] = element;
              else
                break;
              end
            else
              result[#result+1] = element;
            end
            matched = matched + 1
          end
        else
          for i, key in next, arg do
            if (key == ea_key) then
              if (occurances ~= nil) then
                if (matched <= occurances) then
                  result[#result+1] = element;
                else
                  break;
                end
              else
                result[#result+1] = element;
              end
              matched = matched + 1
            end
          end
        end
      end
    end
   
    if (occurances) then
      if (occurances == 1) then
        return result[1];
      end
    end
    
    return result;
  end
  
  o.Find = function(this, id, level, occurances)
    occurances = occurances or nil;
    level = level or nil;
    
    local matched = 1;
    local result = {};
    
    local cl = 1;
    
    local function recurse(e)        
      if (level) then
        if (cl <= level) then
          local r = {};
          
          local function goThroughChildren(t)
            local temp = {};
            for _, c in next, t do 
              for _, child in next, c['Children'] do
                temp[#temp + 1] = child; 
              end
            end
            return temp;
          end
          
          for _, child in next, e['Children'] do r[#r + 1] = child;end
          
          local final = {};
          cl=cl+1;
          while (cl <= level) do
            for _, v in next, goThroughChildren(r) do r[#r+1] = v;end
            cl=cl+1;
          end
          
          --Remove duplicates
          local hash = {};
          local res = {};
          
          for i, v in next, r do
            if (not hash[v]) then
              res[#res+1] = v;
              hash[v]=true;
            end
          end
          
          return res;
        else
          return;
        end
      else
        local r = {}
        for _, child in next, e['Children'] do
          r[#r + 1] = child;
          for i, v in next, recurse(child) do r[#r + 1] = v; end
        end
        
        return r;
      end
    end
    
    for _, element in next, recurse(this) do
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
    
    return result;
  end
  
  o.Iter = function(this, target)
      target = target or nil;
      local tab;
      
      if (target) then
          tab =  this:Find(target);
      else
        tab = {};
        
        local function recurse(e)        
            local r = {}
            for _, child in next, e['Children'] do
              r[#r + 1] = child;
              for i, v in next, recurse(child) do r[#r + 1] = v; end
            end
            
            return r;
        end
        
        for _, element in next, recurse(this) do
            tab[#tab+1] = element;
        end
      end
      
      local iteration = 0;
      local num = #tab;
      
      
      return function()
          iteration = iteration + 1;
          if (iteration <= num) then return tab[iteration]; end
      end
  end
  
  o.GetTag = function(this)
    return this['Tag']:match('%[.-%](.*)') or this['Tag'];
  end
  
  o.GetFullPath = function(this)
    if (this['ParentPath'] == "") then return tostring(this); end
    return this['ParentPath'] .. '.' .. tostring(this);
  end

  return o;
end

function M.newDoctype(data)
    local DocMeta = {
        __type = "DOCTYPE";
        __tostring = function(this) return '<!DOCTYPE'..this.Data..'>'; end
    }

    return setmetatable({
        Data = data;
    }, DocMeta);
end

function M.newCData(data)
    local CDMeta = {
        __type = "CDATA";
        __tostring = function(this) return '<![CDATA['..this.Data..']]>'; end
    }
    
    return setmetatable({
        Data = data;
    }, CDMeta);
end

return M;