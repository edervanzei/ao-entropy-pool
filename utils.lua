local bint = require(".bint")(512)

---Returns a `ByteList` from an hexadecimal string
---@param hex string hexadecimal string
---@return table
function ConvertHexToByteList(hex)
   local result = ByteList:new()

   for i = 1, #hex, 2 do
      local byteStr = hex:sub(i, i + 1)
      local byte = tonumber(byteStr, 16)

      assert(byte ~= nil, "invalid hex")
      result:add(byte)
   end

   return result
end

---Returns a `ByteList` from a `string`
---@param str string any string
---@return table
function ConvertStrToByteList(str)
   local result = ByteList:new()

   for i = 1, #str do
      result:add(string.byte(str, i))
   end

   return result
end

---Returns a `ByteList` from a `Bint`
---@param num Bint `Bint` value
---@return table
function ConvertBintToByteList(num)
   local result = ByteList:new()

   while num > BYTE_SIZE do
      local byte = (num % BYTE_SIZE):tointeger()
      result:add(byte)

      num = num // BYTE_SIZE
   end

   local byte = (num % BYTE_SIZE):tointeger()
   result:add(byte)

   return result
end

---Returns a `ByteList` from a radix64 string
---@param str string radix64 string
---@return table
function ConvertRadix64StrToByteList(str)
   local radix64 = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-"
   local num = bint(0)

   for i = 1, #str do
      local char = str:sub(i, i)
      local istr = radix64:find(char, 1, true)

      assert(istr ~= nil, "invalid string")

      istr = istr - 1
      num = num + istr * bint(64):ipow(#str - i)
   end

   return ConvertBintToByteList(num)
end

---Convert bit to ByteList
---@param bit boolean boolean value
---@return table
function ConvertBooleanToByteList(bit)
   assert(type(bit) == "boolean", "invalid bit")
   local result = ByteList:new()

   if bit then
      result:add(1)
   else
      result:add(0)
   end

   return result
end