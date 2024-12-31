ByteList = {}
ByteList.__index = ByteList

MIN_BYTE_SIZE = 0
BYTE_SIZE = 255

---Create a new `ByteList`
---@param size number? size of the `ByteList`
---@return table
function ByteList:new(size)
   local obj = {}
   setmetatable(obj, ByteList)

   obj.data = {}
   obj.size = size or 0

   for i = 1, obj.size do
      obj.data[i] = 0
   end

   return obj
end

---Add a new byte to the `ByteList`
---@param byte number the byte to add
function ByteList:add(byte)
   assert(byte >= MIN_BYTE_SIZE and byte <= BYTE_SIZE, "invalid byte")

   table.insert(self.data, byte)
   self.size = self.size + 1
end

---Returns a byte in the `ByteList`
---@param i number index of the byte
---@return number
function ByteList:get(i)
   assert(i > 0 and i <= self.size, "invalid index")
   return self.data[i]
end

---Set a byte in the `ByteList`
---@param i number index in the `ByteList`
---@param byte number the byte to set
function ByteList:set(i, byte)
   assert(i > 0 and i <= self.size, "invalid index")
   assert(byte >= MIN_BYTE_SIZE and byte <= BYTE_SIZE, "invalid byte")

   self.data[i] = byte
end

---Returns the size of the `ByteList`
---@return number
function ByteList:length()
   return self.size
end

---Returns the hexadecimal representation of the `ByteList`
---@return string
function ByteList:toHex()
   local hex = ""

   for i = 1, self:length() do
      local byte = self:get(i)
      hex = hex .. string.format("%02X", byte)
   end

   return hex
end

---Returns a slice of the `ByteList`
---@param istart number index of the start of the slice
---@param iend number index of the end of the slice
---@return table
function ByteList:slice(istart, iend)
   local slice = ByteList:new()

   if istart < 1 or iend > self:length() or istart > iend then
      return slice
   end

   for i = istart, iend do
      slice:add(self:get(i))
   end

   return slice
end