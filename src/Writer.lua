local M = {};

local Reader = require("src.Reader");
local Element = require("src.Lib.Element");
local XMLObject = require("src.Lib.XMLObject");

function Recurse(e)        
  local r = {}
  for _, child in next, e['@Children'] do
    r[#r + 1] = child;
    for i, v in next, Recurse(child) do r[#r + 1] = v; end
  end
  
  return r;
end

local Meta = {
  __index = {
    CreateComment = function(this, str)
      this.buffer[#this.buffer+1] = str;
    end,

    CreateElement = function(this, tag, attributes, data, parent, pre)  
      attributes = attributes or {};
      data = data or "";
      parent = parent or nil;
      pre = pre or false;
      
      local str = "";
      if (pre) then
        local start = "<?" .. tag;
        for i, v in next, attributes do start = start .. " "..i.."\""..v.."\"";end
        str = start .. '?>';
      else
        local start = "<" .. tag;
        for i, v in next, attributes do start = start .. " "..i.."=\""..v.."\"";end
        str = start .. '>' .. data .. '</'..tag..'>';
      end
      
      local element;
      element, this.reference = Reader.GetSingle(str, this.reference, parent);
      
      if not (parent) then this.buffer[#this.buffer+1] = element;else      
        for _, v in next, this.buffer do
          if (v == parent) then v['@Children'][#v['@Children']+1] = element; else
            for i, child in next, Recurse(v) do
              if (child == parent) then
                child['@Children'][#child['@Children']+1] = element;
              end
            end
          end
        end
      end
      
      return element;
    end,
    
    Compile = function(this)
      local result = "";
      
      local function BuildElement(e)
        local str = "";
        
        if (e['@Preprocessor']) then
          local start = "<?" .. e:GetRawTag();
          for i, v in next, e['@RawAttributes'] do start = start .. " "..i.."\""..v.."\"";end
          str = start .. '?>';
        else
          local start = "<" .. e:GetRawTag();
          for i, v in next, e['@RawAttributes'] do start = start .. " "..i.."=\""..v.."\"";end
          str = start .. '>'
        end
        
        return str, e;
      end
      
      local function GoThroughElement(e)
        local res = "";
        res = BuildElement(e) .. e['@Data'] or '';
        for i, element in next, e['@Children'] do res = res .. GoThroughElement(element); end
        res = res .. '</'..e:GetRawTag()..'>';
        return res;
      end
      
      for _, element in next, this.buffer do
        result = result .. GoThroughElement(element);
      end
      
      this.document = Reader.Read(result, function() end);
      
      return result;
    end,
    
    DumpToFile = function(this, name, mode)
      mode = mode or 'w+';
      local file = io.open(name, mode);

      if (file) then
        file:write(tostring(this.document));
        file:flush();
      else
        error("\"" .. name .. "\" does not exist!");
      end
    end,
    
    DumpToString = function(this)
      return tostring(this.document);
    end
  }
}

function M.new(xml)
  return setmetatable({
      document = xml or XMLObject.new();
      reference = {};
      buffer = {};
    }, Meta);
end

return M;