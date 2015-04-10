local M = {};

local Reader = require("src.Reader");
local Element = require("src.Lib.Element");
local XMLObject = require("src.Lib.XMLObject");
local CDATA = require("src.Lib.CDATA");
local Doctype = require("src.Lib.Doctype");

local Meta = {
  __index = {    
    -- str is in xml format
    Write = function(this, str, parent)
      parent = parent or nil;
      local converted = (Reader.Do(str, function() end, nil, parent)):GetData();
      
      for i, v in next, converted do
        local ok = false;
        
        for _, element in next, this.buffer do
          if (element == parent) then
            element['@Children'][#element['@Children']+1] = v;
            ok = true;
          else
            for _, child in next, Reader.Recurse(element) do
              if (child == parent) then
                child['@Children'][#child['@Children']+1] = v;
                ok = true;
              end
            end
          end
        end
        
        if not (ok) then
          this.buffer[#this.buffer+1] = v;
        end
      end
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
            for i, child in next, Reader.Recurse(v) do
              if (child == parent) then
                child['@Children'][#child['@Children']+1] = element;
              end
            end
          end
        end
      end
      
      return element;
    end,
    
    CompileAll = function(this)
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
        if (getmetatable(e).__type == "Element") then
          res = BuildElement(e) .. e['@Data'] or '';
          for i, element in next, e['@Children'] do res = res .. GoThroughElement(element); end
          res = res .. '</'..e:GetRawTag()..'>';
        else
          res = res .. tostring(e);
        end
        return res;
      end
      
      for _, element in next, this.buffer do
        if (type(element) == "table") then
          if (getmetatable(element).__type == "Element") then
            result = result .. GoThroughElement(element);
          else
            result = result .. tostring(element);
          end
        elseif (type(element) == "string") then
          result = result .. element;
        end
      end
      
      return Reader.Read(result, function() end), result;
    end,
    
    Compile = function(this)
      local result;
      this.document, result = this:CompileAll();
      
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