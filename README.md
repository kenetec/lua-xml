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

