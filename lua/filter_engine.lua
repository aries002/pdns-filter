-- System requiretment
-- - Lua version 5.2
-- - - apt install lua5.2
-- - lua-sql-mysql library
-- - - apt install lua-sql-mysql

-- note : print just for debuging

pdnslog("pdns-recursor Lua script starting!", pdns.loglevels.Warning)
driver = require "luasql.mysql"
local config = require "config"
env = assert( driver.mysql() )


function preresolve ( dq )
    -- create connection to database
    koneksi = assert(env:connect(config.database.host, config.database.username, config.database.password, config.database.host))
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
    if sth:fetch() == '1'
    then
        -- print('2')
        -- check if it A record
        if dq.qtype == pdns.A
        then
            -- rewrite the query
            -- print('3')
            pdnslog("Query ",domain," Blocked", pdns.loglevels.Info)
            dq:addAnswer(pdns.A, "192.168.10.22")
            -- message for domain dig
            dq:addAnswer(pdns.TXT, "\"Domain ini diblokir\"", 3601)
            -- return tru if script rewite the answer
            return true
        else
            return false
        end
    else
        return false
    end
end
