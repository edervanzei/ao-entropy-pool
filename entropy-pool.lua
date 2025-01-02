EntropyPool = {}
EntropyPool.__index = EntropyPool

---Create a new `EntropyPool`
---@param size number size of the `EntropyPool`
---@return table
function EntropyPool:new(size)
   local obj = {}
   setmetatable(obj, EntropyPool)

   obj.pool = ByteList:new(size)
   obj.size = size
   obj.cursor = 1

   return obj
end

---Add entropy to the `EntropyPool`
---@param bytes table bytes to add
function EntropyPool:add(bytes)
   assert(getmetatable(bytes) == ByteList, "param must be ByteList")

   for i = 1, bytes:length() do
      local result = self.pool:get(self.cursor) ~ bytes:get(i)
      self.pool:set(self.cursor, result)

      self.cursor = self.cursor % self.size + 1
   end
end

---Returns random bytes from the `EntropyPool`
---@param size number number of random bytes
---@return table
function EntropyPool:random(size, generator)
   local result = ByteList:new(size)
   local offset = 0

   --TEMP
   local digestSize = ConvertHexToByteList(generator("00")).size

   while offset < size do
      local slice = self.pool:slice(self.cursor, self.cursor + digestSize)

      local hashHex = generator(slice:toHex())
      local hashBytes = ConvertHexToByteList(hashHex)

      local bytesToCopy = math.min(hashBytes:length(), size - offset)
      for i = 1, bytesToCopy do
         result:set(offset + i, hashBytes:get(i))
      end

      offset = offset + bytesToCopy
      self:add(hashBytes)
   end

   return result;
end

function EntropyPool:randomUInt32(generator)
   local result = 0
   local bytes = self:random(4, generator)

   for i = 1, bytes:length() do
      result = result + (bytes:get(i) << (8*(i-1)))
   end

   return result
end