module(..., package.seeall)

local ffi = require("ffi")

ffi.cdef[[
	typedef struct redisReply {
		int type; /* REDIS_REPLY_* */
		long long integer; /* The integer when type is REDIS_REPLY_INTEGER */
		int len; /* Length of string */
		char *str; /* Used for both REDIS_REPLY_ERROR and REDIS_REPLY_STRING */
		size_t elements; /* number of elements, for REDIS_REPLY_ARRAY */
		struct redisReply **element; /* elements vector for REDIS_REPLY_ARRAY */
	} redisReply;

	typedef struct redisReadTask {
		int type;
		int elements; /* number of elements in multibulk container */
		int idx; /* index in parent (array) object */
		void *obj; /* holds user-generated value for a read task */
		struct redisReadTask *parent; /* parent task */
		void *privdata; /* user-settable arbitrary field */
	} redisReadTask;

	typedef struct redisReplyObjectFunctions {
		void *(*createString)(const redisReadTask*, char*, size_t);
		void *(*createArray)(const redisReadTask*, int);
		void *(*createInteger)(const redisReadTask*, long long);
		void *(*createNil)(const redisReadTask*);
		void (*freeObject)(void*);
	} redisReplyObjectFunctions;
	
	typedef struct redisReader {
		int err; /* Error flags, 0 when there is no error */
		char errstr[128]; /* String representation of error when applicable */

		char *buf; /* Read buffer */
		size_t pos; /* Buffer cursor */
		size_t len; /* Buffer length */

		redisReadTask rstack[4];
		int ridx; /* Index of current read task */
		void *reply; /* Temporary reply pointer */

		redisReplyObjectFunctions *fn;
		void *privdata;
	} redisReader;

	typedef struct redisContext {
	    int err; 
		char errstr[128]; 
		int fd;
		int flags;
		char *obuf; 
		redisReader *reader; 
	} redisContext;

	void *redisCommand(redisContext *c, const char *format, ...);
	redisContext *redisConnect(const char *ip, int port);
	redisContext *redisConnectWithTimeout(const char *ip, int port, struct timeval tv);

	int printf(const char *format, ...);

	size_t strlen(const char *s);
]]

local hiredis = ffi.load("hiredis")
local C = ffi.C

local print = print
local setmetatable = setmetatable
local Command = hiredis.redisCommand
local Cast = ffi.cast

local NULL = ffi.cast("void*", 0)

RedisFFI = {
	m_s_host = "",
	m_n_port = 0,
	m_t_redis = nil,
}

function RedisFFI:new(o)
	o = o or {}

	setmetatable(o, self)

	self.__index = self

	return o
end

function RedisFFI:CONNECT(in_s_host, in_n_port)
	self.m_s_host = in_s_host
	self.m_n_port = in_n_port

	m_t_redis = hiredis.redisConnect("192.168.100.154", 6380)
	
	if not m_t_redis then
		print("redis is not online.")
		return false
	else
		print("redis is online.")
		return true
	end
end

function RedisFFI:PRINT_CONFIG( ... )
	print("HOST: "..self.m_s_host)
	print("PORT: "..self.m_n_port)
end

function RedisFFI:SET(in_s_key, in_s_value)
	local reply = Cast("redisReply*", Command(m_t_redis, "SET %s %s", in_s_key, in_s_value))
	
	if reply.type == 1 then
		return reply.integer
	else
		return reply.type
	end
end

function RedisFFI:GET(in_s_key)
	local reply = Cast("redisReply*", Command(m_t_redis, "GET %s", in_s_key))

	if NULL ~= reply then
		if reply.type == 1 then
			return ffi.string(reply.str, C.strlen(reply.str))
		end
	end

	return nil
end

function RedisFFI:LPOP(in_s_key)
	local reply = Cast("redisReply*", Command(m_t_redis, "LPOP %s", in_s_key))

	if NULL ~= reply then
		if reply.type == 1 then
			return ffi.string(reply.str, C.strlen(reply.str))
		end
	end

	return nil
end

function RedisFFI:RPUSH(in_s_key, in_s_value)
	local reply = Cast("redisReply*", Command(m_t_redis, "RPUSH %s %s", in_s_key, in_s_value))

	if NULL ~= reply then
		if reply.type == 1 then
			return ffi.string(reply.str, C.strlen(reply.str))
		end
	end

	return nil
end

function RedisFFI:EXPIRE(in_s_key, in_s_sec)
	local reply = Cast("redisReply*", Command(m_t_redis, "EXPIRE %s %s", in_s_key, in_s_sec))

	if not reply then
		return reply.integer
	end

	return 0
end

function RedisFFI:DEL(in_s_key)
	local reply = Cast("redisReply*", Command(m_t_redis, "DEL %s", in_s_key))

	if not reply then
		return reply.integer
	end

	return 0
end

function RedisFFI:IsAlived() 
	local reply = Cast("redisReply*", Command(m_t_redis, "PING"))

	if not reply then
		if reply.type == 1 then
			if reply.type == "PONG" then
				return true
			end
		end
	end

	return false 
end
	
function RedisFFI:EXISTS(in_s_key)
	local reply = Cast("redisReply*", Command(n_t_redis, "EXISTS %s", in_s_key))

	if not reply then
		if reply.type == 4 then
			return reply.integer
		end
	end

	return 0
end