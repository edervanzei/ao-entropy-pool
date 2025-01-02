local bint = require(".bint")(512)
local crypto = require(".crypto")
local utils = require(".utils")

local function maybeCreateUser(user)
   if Users[user] == nil then
      Users[user] = 0
   end
end

local function createGenerator(f)
   return function (hex)
      local stream = crypto.utils.stream.fromHex(hex)
      return f(stream).asHex()
   end
end

RANDOM_NUMBER_GENERATOR_LIST = {
   ["sha2_256"]=createGenerator(crypto.digest.sha2_256),
   ["sha2_512"]=createGenerator(crypto.digest.sha2_512),
   ["sha3_256"]=createGenerator(crypto.digest.sha3_256),
   ["sha3_512"]=createGenerator(crypto.digest.sha3_512),
   ["keccak256"]=createGenerator(crypto.digest.keccak256),
   ["keccak512"]=createGenerator(crypto.digest.keccak512)
}

OUTPUT_FORMAT = {
   HEX="hex",
   ARRAY="array"
}

POOL_SIZE = POOL_SIZE or 8192
Pool = Pool or EntropyPool:new(POOL_SIZE)

MAX_BYTES_REQUEST = MAX_BYTES_REQUEST or 2048 -- Maximum bytes that can be generated in a single message
MAX_MESSAGES = MAX_MESSAGES or 12 -- Maximum number of messages per user per Cron tick
Users = Users or {} -- Store the total number of messages from users in the current Cron tick
Messages = Messages or {} -- Store messages that cannot be added to the pool (MAX_MESSAGES)

Handlers.add("Cron",
   Handlers.utils.hasMatchingTag("Action", "Cron"),
   function ()
      Users = {}

      while #Messages > 0 do
         local random = Pool:randomUInt32(RANDOM_NUMBER_GENERATOR_LIST["sha2_256"])
         local msg = table.remove(Messages, random % #Messages + 1)

         Pool:add(msg.Id)
         Pool:add(msg.Ts)
         Pool:add(msg.Anchor)
         Pool:add(msg.Block)
      end
   end
)

Handlers.add("Add-Entropy",
   function () return "continue" end,
   function (msg)
      local user = msg.From

      maybeCreateUser(user)
      Users[user] = Users[user] + 1

      local id     = ConvertRadix64StrToByteList(msg.Id)
      local ts     = ConvertBintToByteList(bint(msg.Timestamp))
      local anchor = ConvertBintToByteList(bint(msg.Anchor))
      local block  = ConvertBintToByteList(bint(msg["Block-Height"]))

      if Users[user] > MAX_MESSAGES then
         table.insert(Messages, {
            Id=id,
            Ts=ts,
            Anchor=anchor,
            Block=block
         })
      else
         Pool:add(id)
         Pool:add(ts)
         Pool:add(anchor)
         Pool:add(block)
      end
   end
)

Handlers.add("Get-Random",
   Handlers.utils.hasMatchingTag("Action", "Get-Random"),
   function (msg)
      local bytes = tonumber(msg["Bytes"])
      assert(bytes <= MAX_BYTES_REQUEST, "maximum bytes per message exceeded")

      local generator = RANDOM_NUMBER_GENERATOR_LIST[msg["Generator"] or "sha2_256"]
      assert(generator ~= nil, "invalid generator")

      local format = msg["Output-Format"] or "hex"
      assert(utils.includes(format, utils.values(OUTPUT_FORMAT)), "invalid output format")

      local data = nil
      local random = Pool:random(bytes, generator)

      if format == OUTPUT_FORMAT.HEX then
         data = random:toHex()
      elseif format == OUTPUT_FORMAT.ARRAY then
         data = "[" .. table.concat(random.data, ",") .. "]"
      end

      msg.reply({ Data=data })
   end
)

Handlers.add("Get-Generators",
   Handlers.utils.hasMatchingTag("Action", "Get-Generators"),
   function (msg)
      local data = table.concat(utils.keys(RANDOM_NUMBER_GENERATOR_LIST), ",")
      msg.reply({ Data=data })
   end
)

Handlers.add("Get-Output-Formats",
   Handlers.utils.hasMatchingTag("Action", "Get-Output-Formats"),
   function (msg)
      local data = table.concat(utils.values(OUTPUT_FORMAT), ",")
      msg.reply({ Data=data })
   end
)