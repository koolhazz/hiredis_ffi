local redis = require("redis_ffi")



-- local redis_2 = require("redis_ffi")

-- if redis_2.CONNECT("192.168.100.167", 4502) then
-- 	redis_2.SET("guoguo", "guoguo")

-- 	print(redis_2.GET("guoguo"))
-- end

local function loop_test()
	if redis.CONNECT("192.168.100.154", 6380) then
		for i = 1, 1 do
			redis.SET("dengyong", "KIKI")
			print("do")
			-- redis.GET("dengyong")

			redis.EXPIRE("dengyong", "100")
			redis.EXPIRE("dengyong", tostring(1000))		
		end
		--redis.RPUSH("jingyang", "1")
	end
end

loop_test()