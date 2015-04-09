#lua-xml
=======================================================================================
lua-xml is a XML library for Lua.


Please read the API at: docs\API.md


#Usage
=======================================================================================
Prefix:

```lua
package.path = package.path .. "PATH TO LUA-XML FOLDER"
local xml = require('lua-xml')
```

Parse an .xml file:

```lua
local document = xml.Load("name.xml")

```

Write an .xml file:

```lua
local writer = xml.CreateWriter()

local r = writer:CreateElement("w:root", {["xmlns:w"] = "https://www.youtube.com/"})

local a1 = writer:CreateElement(
  'w:a',                -- Tag
  {id = "test"},        -- Attributes
  "",                   -- Data
  r,                    -- Parent
  false                 -- Preprocessor
)

writer:Compile()
writer:DumpToFile "test.xml"
```

