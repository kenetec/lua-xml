local M = {};

local Element = require("src.Lib.Element");
local XMLObject = require("src.Lib.XMLObject");

function M.LinesToString(file)
  if (type(file) == "userdata") then
    local list = {};
    for l in file:lines() do list[#list+1] = l; end
    return table.concat(list);
  else
    return file;
  end
end

function M.Get(str, reft, parent)
  parent = parent or nil;
  reft = reft or {};
  local result = {};
  
  for comment in str:gmatch('<!--(.-)*-->') do result[#result+1] = comment:sub(2, comment:len()-1); end
  if (str:find('<!--(.-)*-->')) then str = str:gsub('<!--(.-)*-->', '') end
  
  for t, a in str:gmatch('<%?([%w_%-?:?%w_%-?]+)([^>]*)%?>') do
    local attribs = {};
    local reference = {};
    local raw_t = t;
    local raw_a = {};
    
    for key, value in a:gmatch('([%w_%-:?%w_%-]+)=\'?\"?([^>\"\']*)\'?\"?') do
      raw_a[key] = tonumber(value) or value;
      
      local k, n = key:match('([%w_%-]+):([%w_%-]+)');
      if (k and n) then
        reference = {
          ["Key"] = k,
          ["Name"] = n,
          ["Value"] = value}; 
        
        reft[#reft+1] = reference;
        
        for i, ref in next, reft do
          if (ref["Value"]:match('https?://(.-)/(.*)')) then
            if (k == ref["Name"]) then
              key = '[' .. ref["Value"] .. ']' .. n;
            end
          end
        end
        
        if not (key:match('%[(.-)%](.*)')) then key = '[' .. value .. ']' .. n; end
      end
  
      attribs[key] = tonumber(value) or value;
    end
    
    local refer = {};
    if (t:match('([%w_%-]+):([%w_%-]+)')) then
      local key, tag = t:match('([%w_%-]+):([%w_%-]+)');
      for i, ref in next, reft do
        if (ref["Value"]:match('https?://(.-)/(.*)')) then
          if (key == ref["Name"]) then
            t = ('[' .. ref["Value"] .. ']') .. tag;
            refer = ref;
          end
        end
      end
    end
    
    result[#result+1] = Element.new {
      ["Tag"] = t;
      ["Attributes"] = attribs;
      ["RawAttributes"] = raw_a;
      ["Preprocessor"] = true;
      ["Children"] = {};
      ["Reference"] = refer;
      ["ParentPath"] = parent and parent:GetFullPath() or "";
      ["Parent"] = parent;
      ["RawTag"] = raw_t;
    }
  end
  
  for t, a, d in str:gmatch('<([%w_%-:?%w_%-]+)([^>]*)>(.-)</%1>') do
    local attribs = {};
    local reference = {};
    local raw_t = t;
    local raw_a = {};
    
    for key, value in a:gmatch('([%w_%-:?%w_%-]+)=\'?\"?([^>\"\']*)\'?\"?') do
      raw_a[key] = tonumber(value) or value;
      
      local k, n = key:match('([%w_%-]+):([%w_%-]+)');
      if (k and n) then
        reference = {
          ["Key"] = k,
          ["Name"] = n,
          ["Value"] = value}; 
        
        reft[#reft+1] = reference;
        
        for i, ref in next, reft do
          if (ref["Value"]:match('https?://(.-)/(.*)')) then
            if (k == ref["Name"]) then
              key = '[' .. ref["Value"] .. ']' .. n;
            end
          end
        end
        
        if not (key:match('%[(.-)%](.*)')) then key = '[' .. value .. ']' .. n; end
      end
      
      attribs[key] = tonumber(value) or value;
    end
    
    local refer = {};
    if (t:match('([%w_%-]+):([%w_%-]+)')) then
      local key, tag = t:match('([%w_%-]+):([%w_%-]+)');
      for i, ref in next, reft do
        if (ref["Value"]:match('https?://(.-)/(.*)')) then
          if (key == ref["Name"]) then
            t = ('[' .. ref["Value"] .. ']') .. tag;
            refer = ref;
          end
        end
      end
    end
    
    result[#result+1] = Element.new {
      ["Tag"] = t;
      ["Attributes"] = attribs;
      ["RawAttributes"] = raw_a;
      ["Data"] = d;
      ["Preprocessor"] = false;
      ["Children"] = {};
      ["Reference"] = refer;
      ["ParentPath"] = parent and parent:GetFullPath() or "";
      ["Parent"] = parent;
      ["RawTag"] = raw_t;
    }
  end

  return result, reft;
end

function M.GetSingle(str, reft, parent)
  parent = parent or nil;
  reft = reft or {};
  local result = {};
  
  for comment in str:gmatch('<!--(.-)*-->') do result[#result+1] = comment:sub(2, comment:len()-1); end
  if (str:find('<!--(.-)*-->')) then str = str:gsub('<!--(.-)*-->', '') end
  
  for t, a in str:gmatch('<%?([%w_%-?:?%w_%-?]+)([^>]*)%?>') do
    local attribs = {};
    local reference = {};
    local raw_t = t;
    local raw_a = {};
    
    for key, value in a:gmatch('([%w_%-:?%w_%-]+)=\'?\"?([^>\"\']*)\'?\"?') do
      raw_a[key] = tonumber(value) or value;
      
      local k, n = key:match('([%w_%-]+):([%w_%-]+)');
      if (k and n) then
        reference = {
          ["Key"] = k,
          ["Name"] = n,
          ["Value"] = value}; 
        
        reft[#reft+1] = reference;
        
        for i, ref in next, reft do
          if (ref["Value"]:match('https?://(.-)/(.*)')) then
            if (k == ref["Name"]) then
              key = '[' .. ref["Value"] .. ']' .. n;
            end
          end
        end
        
        if not (key:match('%[(.-)%](.*)')) then key = '[' .. value .. ']' .. n; end
      end
  
      attribs[key] = tonumber(value) or value;
    end
    
    local refer = {};
    if (t:match('([%w_%-]+):([%w_%-]+)')) then
      local key, tag = t:match('([%w_%-]+):([%w_%-]+)');
      for i, ref in next, reft do
        if (ref["Value"]:match('https?://(.-)/(.*)')) then
          if (key == ref["Name"]) then
            t = ('[' .. ref["Value"] .. ']') .. tag;
            refer = ref;
          end
        end
      end
    end
    
    result = Element.new {
      ["Tag"] = t;
      ["Attributes"] = attribs;
      ["RawAttributes"] = raw_a;
      ["Preprocessor"] = true;
      ["Children"] = {};
      ["Reference"] = refer;
      ["ParentPath"] = parent and parent:GetFullPath() or "";
      ["Parent"] = parent;
      ["RawTag"] = raw_t;
    }
  end
  
  for t, a, d in str:gmatch('<([%w_%-:?%w_%-]+)([^>]*)>(.-)</%1>') do
    local attribs = {};
    local reference = {};
    local raw_t = t;
    local raw_a = {};
    
    for key, value in a:gmatch('([%w_%-:?%w_%-]+)=\'?\"?([^>\"\']*)\'?\"?') do
      raw_a[key] = tonumber(value) or value;
      
      local k, n = key:match('([%w_%-]+):([%w_%-]+)');
      if (k and n) then
        reference = {
          ["Key"] = k,
          ["Name"] = n,
          ["Value"] = value}; 
        
        reft[#reft+1] = reference;
        
        for i, ref in next, reft do
          if (ref["Value"]:match('https?://(.-)/(.*)')) then
            if (k == ref["Name"]) then
              key = '[' .. ref["Value"] .. ']' .. n;
            end
          end
        end
        
        if not (key:match('%[(.-)%](.*)')) then key = '[' .. value .. ']' .. n; end
      end
      
      attribs[key] = tonumber(value) or value;
    end
    
    local refer = {};
    if (t:match('([%w_%-]+):([%w_%-]+)')) then
      local key, tag = t:match('([%w_%-]+):([%w_%-]+)');
      for i, ref in next, reft do
        if (ref["Value"]:match('https?://(.-)/(.*)')) then
          if (key == ref["Name"]) then
            t = ('[' .. ref["Value"] .. ']') .. tag;
            refer = ref;
          end
        end
      end
    end
    
    result = Element.new {
      ["Tag"] = t;
      ["Attributes"] = attribs;
      ["RawAttributes"] = raw_a;
      ["Data"] = d;
      ["Preprocessor"] = false;
      ["Children"] = {};
      ["Reference"] = refer;
      ["ParentPath"] = parent and parent:GetFullPath() or "";
      ["Parent"] = parent;
      ["RawTag"] = raw_t;
    }
  end

  return result, reft;
end

function M.Optimize(source)
  if (source:find('<([%w_%-?:?%w_%-?]+)([^>]*)/>')) then source = source:gsub('<([%w_%-?:?%w_%-?]+)([^>]*)/>', '<%1%2></%1>'); end
  return source;
end

function M.iGet(source, r, parent)
  local xml = M.Get(M.Optimize(source), r, parent);
  local i = 0;
  local n = #xml;
  
  return function()
    i=i+1;
    if (i <= n) then return xml[i] end
  end
end

function M.Iter(info)
  local i = 0;
  local n = #info;
  
  return function()
    i = i+1;
    if (i <= n) then return info[i]; end
  end
end

function M.Split(s, spliter)
	local list = {};
	local str = "";
	
	for char in string.gmatch(s, '.') do
		if (char ~= spliter) then
			str = str..char;
		else
			list[#list+1] = str;
			str = "";
		end
	end
	
	if (str ~= "") then
		list[#list+1] = str;
	end
	
	return list;
end

function M.Recurse(e)        
  local r = {}
  for _, child in next, e['@Children'] do
    r[#r + 1] = child;
    for i, v in next, M.Recurse(child) do r[#r + 1] = v; end
  end
  
  return r;
end

function M.Read(source, f)  
  local function Do(xml)
    local function GoThroughElement(e, r, f, p)
      local result = {};
      
      for element in M.iGet(e['@Data'], r, p) do
        local pp = p and p:GetFullPath() or "";
        
        if (pp ~= "") then
          pp = pp .. '.' .. tostring(element);
        else
          pp = tostring(element);
        end
        
        p = element;
        
        f(element);
        result[#result+1] = element;
        for i, v in next, GoThroughElement(element, r, f, p) do result[#result]['@Children'][#result[#result]['@Children']+1] = v;end
        
        pp = M.Split(pp, '.');
        table.remove(pp, #pp);
        pp = table.concat(pp, '.');
        p = element['@Parent'];
      end
      return result;
    end
    
    local function GetScope(x, f)      
      local newXml = {
        ["Comments"] = {};
        ["Preprocessing"] = {};
        ["Data"] = {};
        ["Schemas"] = {};
      };
      
      local _, schemas = M.Get(M.Optimize(x));
      newXml.Schemas[#newXml.Schemas+1] = schemas;
      
      for element in M.iGet(x) do        
        f(element);
        
        if (type(element) == "table") then
          if not (element["@Preprocessor"]) then
            element['@Children'] = GoThroughElement(element, schemas, f, element);
            newXml.Data[#newXml.Data+1] = element;
          else
            newXml.Preprocessing[#newXml.Preprocessing+1] = element;
          end
        else
          newXml.Comments[#newXml.Comments+1] = element;
        end
      end
      
      return newXml;
    end
    
    return XMLObject.new(GetScope(xml, f), xml);
  end
  
  return Do(M.LinesToString(source));
end

return M;