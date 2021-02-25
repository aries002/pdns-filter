-- System requiretment
-- - Lua version 5.2
-- - - apt install lua5.2
-- - lua-sql-mysql library
-- - - apt install lua-sql-mysql

-- note : print just for debuging

pdnslog("pdns-recursor Lua script starting!", pdns.loglevels.Warning)
driver = require "luasql.mysql"
env = assert( driver.mysql() )
-- database configuration
-- database = {
--     host = "127.0.0.1",
--     username = "alfian",
--     password = "24april1997",
--     database = "tes_filter",
-- }
config = dofile("config.lua")
-- ip addresse for redirection

function preresolve ( dq )
    local stat = false
    -- create connection to database
    koneksi = assert(env:connect(config.database.database, config.database.username, config.database.password, config.database.host))
    -- get query name
    domain = dq.qname:toString()
    -- remove last dot from query name
    domain = domain:gsub("%.$", "")
    -- print(nama)
    -- sql steatment for checking query name retun '1' if exist
    sql = string.format("SELECT '1' FROM domains WHERE name = '%s'", domain)
    -- print (sql)
    -- execute query
    local sth =  assert (koneksi:execute( string.format(sql) ) )
    -- print('1')
    -- print(sth:fetch())
    -- check if true
    if (sth:fetch() == '1' and (dq.qtype == pdns.A or dq.qtype == pdns.A))
    then
        -- print('2')
        -- check if it A record
        if dq.qtype == pdns.A
        then
            -- rewrite the query
            -- print('3')
            -- pdnslog("Query ",domain," Blocked", pdns.loglevels.Info)
            dq:addAnswer(pdns.A, config.record.ip_address, 3600)
            -- message for domain dig
            dq:addRecord(pdns.TXT, config.record.txt_messege, 3600)
            dq:addRecord(pdns.SOA,"fake."..dq.qname:toString().." fake."..dq.qname:toString().." 1 3600 900 1209600 86400",2)
            -- return tru if script rewite the answer
            stat = true
        end
    end
    koneksi:close()
    return stat
end
