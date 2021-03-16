-- System requiretment
-- - Lua version 5.2
-- - - apt install lua5.2
-- - lua-sql-mysql library
-- - - apt install lua-sql-mysql

-- note : print just for debuging
--        every new enry on the black list need to reload the script

pdnslog("pdns-recursor Lua script starting!", pdns.loglevels.Warning)
driver = require "luasql.mysql"
env = assert( driver.mysql() )
config = dofile("/etc/powerdns/pdns-filter/lua/config.lua")
blocklist = newDS()
-- get domain blacklist from database
koneksi = assert (env:connect(config.database.database, config.database.username, config.database.password, config.database.host))
cursor =  assert (koneksi:execute(string.format("SELECT name FROM domains")))
row = cursor:fetch ({}, "a")
while row do
    blocklist:add(row.name)
    row = cursor:fetch(row, "a")
end

function preresolve ( dq )
    stat = false
    if blocklist:check(dq.qname)
    then
        -- check if it A record
        if dq.qtype == pdns.AAA
        then
            dq:addAnswer(pdns.AAA, "::1", 3600)
            dq:addRecord(pdns.SOA,"fake."..dq.qname:toString().." fake."..dq.qname:toString().." 1 3600 900 1209600 86400",3600)
            stat = true
        end
        if dq.qtype == pdns.A
        then
            -- rewrite the query
            dq:addAnswer(pdns.A, config.record.ip_address, 3600)
            -- message for domain dig
            dq:addRecord(pdns.TXT, config.record.txt_messege, 3600)
            dq:addRecord(pdns.SOA,"fake."..dq.qname:toString().." fake."..dq.qname:toString().." 1 3600 900 1209600 86400",3600)
            -- return tru if script rewite the answer
            stat = true
        end
    end
    return stat
end
cursor:close()
koneksi:close()
pdnslog("pdns-recursor Lua script done priming!!", pdns.loglevels.Warning)
