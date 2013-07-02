require("redis_ffi")

local LOOP = 1

local function redis_ffi_test_1()
	local temp = redis_ffi.RedisFFI:NEW()

	if temp:CONNECT("192.168.100.154", 6380) then
		for i = 1, LOOP do
			temp:SET("dengyong", "KIKI")
			
			print(temp:GET("dengyong"))

			temp:EXPIRE("dengyong", "100")
			temp:EXPIRE("dengyong", tostring(1000))		
		end

		temp:PRINT_CONFIG()		
	end
end	

local function redis_ffi_test_2()
	local temp = redis_ffi.RedisFFI:NEW()

	if temp:CONNECT("192.168.100.167", 4502) then
		for i = 1, 1 do
			temp:SET("dengyong", "KIKI")
			print("do")
			temp:GET("dengyong")

			temp:EXPIRE("dengyong", "100")
			temp:EXPIRE("dengyong", tostring(1000))		
		end

		temp:PRINT_CONFIG()			
	end
end	

redis_ffi_test_1()
redis_ffi_test_2()

-- loop_test()
-- loop_test_2()

-- redis.PRINT_CONFIG()
-- redis_2.PRINT_CONFIG()