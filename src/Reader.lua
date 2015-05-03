local M = {};

local ElementObject = require("src.Lib.Element");
local XMLObject = require("src.Lib.XMLObject");

-- Converts XML file to string, or string to string
local function ToString(arg)
    if (type(arg) == "userdata") then
        local list = {};
        
        for l in arg:lines() do 
            list[#list+1] = l; 
        end
        
        return table.concat(list);
    elseif (type(arg) == "string") then
        return tostring(arg);
    end
end

-- Splits string at desired character
local function Split(s, spliter)
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

-- Recurses through element's children
function M.Recurse(element)
    local result = {};

    for _, child in next, element.Children do
        result[#result+1] = child;
        for _, sub in next, M.Recurse(child) do result[#result+1] = sub; end
    end

    return result;
end

-- Get all XML data from source
function M.GetXML(source, reference, parent, xmlParent)
    reference = reference or {};
    parent = parent or nil;

    -- Optimize XML
    source = source:gsub("<([%w_%-?:?%w_%-?]+)([^>]*)/>", "<%1%2></%1>");
    
    -- Create XML Object
    local result = xmlParent or XMLObject.new(nil, source);
    
    -- Read and remove comments
    for comment in source:gmatch("<!--(.-)*-->") do 
        result.Object.Comments[#result.Object.Comments+1] = comment:sub(2, comment:len()-1); 
    end
    source = source:gsub("<!--(.-)*-->", "") 
    
    -- Read and remove DOCTYPE
    result.Object.DOCTYPE = ElementObject.newDoctype(source:match("<!DOCTYPE([^>]*)>"));
    source = source:gsub("<!DOCTYPE([^>]*)>", "");

    -- Read and remove CData
    for data in source:gmatch("<!%[CDATA%[(.*)%]%]>") do
        result.Object.CDATA[#result.Object.CDATA+1] = ElementObject.newCData(data);
    end

    source = source:gsub("<!%[CDATA%[(.*)%]%]>", "");

    local function GetProcessor(source, result, reference, parent)
        -- Read and remove processor
        for name, attrib in source:gmatch("<%?([%w_%-?:?%w_%-?]+)([^>]*)%?>") do
            local attributes = {};
            local ref = {};
            local raw_name = name;
            local raw_attributes = {};

            -- Read attributes
            for key, value in attrib:gmatch("([%w_%-:?%w_%-]+)=\'?\"?([^>\"\']*)\'?\"?") do
                raw_attributes[key] = tonumber(value) or value;

                -- Find references
                local shkey, shname = key:match("([%w_%-]+):([%w_%-]+)");
                if (shkey and shname) then
                    ref = {
                        Key = shkey,
                        Name = shname,
                        Value = value;
                    };

                    reference[#reference+1] = ref;

                    for _, refer in next, reference do
                        if (refer.Value:match("https?://(.-)/(.*)")) then
                            if (ref.Key == refer.Name) then
                                key = '[' .. refer.Value .. ']' .. shname;
                            end
                        end
                    end

                    if not (key:match('%[(.-)%](.*)')) then 
                        key = '[' .. value .. ']' .. shname; 
                    end
                end

                attributes[key] = tonumber(value) or value;
            end

            -- Find reference in line
            local refer = {};

            if (name:match("([%w_%-]+):([%w_%-]+)")) then
                local key, tag = name:match('([%w_%-]+):([%w_%-]+)');

                for i, reft in next, reference do
                    if (reft.Value:match("https?://(.-)/(.*)")) then
                        if (key == reft.Name) then
                            name = ('[' .. reft.Value .. ']') .. tag;
                            refer = reft;
                        end
                    end
                end
            end
            
            result.Object.Processing[#result.Object.Processing+1] = ElementObject.newElement {
                Tag = name;
                Attributes = attributes;
                Data = {};

                RawAttributes = raw_attributes;
                RawTag = raw_name;

                Processor = true;

                Children = {};
                Reference = refer;

                ParentPath = parent and parent:GetFullPath() or "";
                Parent = parent;
            };
        end
    end

    local function GetData(source, result, reference, parent)
        for name, attrib, data in source:gmatch('<([%w_%-:?%w_%-]+)([^>]*)>(.-)</%1>') do
            local attributes = {};
            local ref = {};
            local raw_name = name;
            local raw_attributes = {};

            -- Read attributes
            for key, value in attrib:gmatch("([%w_%-:?%w_%-]+)=\'?\"?([^>\"\']*)\'?\"?") do
                raw_attributes[key] = tonumber(value) or value;

                -- Find references
                local shkey, shname = key:match("([%w_%-]+):([%w_%-]+)");
                if (shkey and shname) then
                    ref = {
                        Key = shkey,
                        Name = shname,
                        Value = value;
                    };

                    reference[#reference+1] = ref;

                    for _, refer in next, reference do
                        if (refer.Value:match("https?://(.-)/(.*)")) then
                            if (ref.Key == refer.Name) then
                                key = '[' .. refer.Value .. ']' .. shname;
                            end
                        end
                    end

                    if not (key:match('%[(.-)%](.*)')) then 
                        key = '[' .. value .. ']' .. shname; 
                    end
                end

                attributes[key] = tonumber(value) or value;
            end

            -- Find reference in line
            local refer = {};

            if (name:match("([%w_%-]+):([%w_%-]+)")) then
                local key, tag = name:match('([%w_%-]+):([%w_%-]+)');

                for i, reft in next, reference do
                    if (reft.Value:match("https?://(.-)/(.*)")) then
                        if (key == reft.Name) then
                            name = ('[' .. reft.Value .. ']') .. tag;
                            refer = reft;
                        end
                    end
                end
            end
            
            result.Object.Data[#result.Object.Data+1] = ElementObject.newElement {
                Tag = name;
                Attributes = attributes;
                Data = data;

                RawAttributes = raw_attributes;
                RawTag = raw_name;

                Processor = false;

                Children = {};
                Reference = refer;

                ParentPath = parent and parent:GetFullPath() or "";
                Parent = parent;
            };
        end
    end

    GetProcessor(source, result, reference, parent);
    GetData(source, result, reference, parent);

    return result, reference;
end

-- Reads XML, if there is a function then it will be called after every iteration
local function ReadXml(arg, xml, parent)
    xml = xml or XMLObject.new(nil, arg);

    --local function IterElement(e, r, f, p)
    local function IterElement(element, reference, parent)
        local result = {};
        
        for _, child in next, M.GetXML(element.Data, reference, parent).Object.Data do      
          --f(element);
          result[#result+1] = child;
          for i, v in next, IterElement(child, reference, child) do 
            if (result[#result]['Children']) then 
                result[#result]['Children'][#result[#result]['Children']+1] = v;
            else 
                result[#result+1] = v; 
            end 
          end

          parent = child.Parent;
        end

        return result;
    end

    local function Do(source)
        local result, schemas = M.GetXML(source, nil, parent, xml);

        local schemahash = {};
        local schemares = {};
        
        for i, v in next, schemas do
            if (not schemahash[v]) then
                schemares[#schemares+1] = v;
                schemahash[v]=true;
            end
        end

        result.Object.Schemas = schemares;

        for _, element in next, result.Object.Data do
            element.Children = IterElement(element, schemares, element);
        end

        return result;
    end

    return Do(arg);
end

-- Main function for external use of reading xml
function M.Read(arg)
    return ReadXml(ToString(arg));
end

return M;