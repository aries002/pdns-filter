pdnslog("pdns-recursor Lua script starting!", pdns.loglevels.Warning)
driver = require "luasql.mysql"
env = assert( driver.mysql() )


-- function preresolve ( dq )
--         con = assert(env:connect("tes_filter", 'alfian', '24april1997','127.0.0.1'))
--         print(dq.qname)
--         -- domain = dq.qname

--         domain = dq.qname("%.$", "")

--         while domain ~= "" do
--                 local sth = assert (con:execute( string.format("SELECT 1 FROM domains WHERE name = '%s'", con:escape( domain )) ) )
--                 if sth:fetch() then 
--                          pdnslog("SELECT 1 FROM domains WHERE name = '%s'", pdns.loglevels.Warning)
--                         return 0, { { qtype=pdns.A, content="127.0.0.1" } }
--                 end

--                 domain = domain:gsub("^[^.]*%.?", "")
--         end

--         return -1, {}
-- end

function preresolve ( dq )
    -- create connection to database
    koneksi = assert(env:connect("tes_filter", 'alfian', '24april1997', '127.0.0.1'))
    
    -- while dq ~= "" do
        domain = dq.qname:toString()
        domain = domain:gsub("%.$", "")
        print(nama)
        sql = string.format("SELECT '1' FROM domains WHERE name = '%s'", domain)
        print (sql)
        local sth =  assert (koneksi:execute( string.format(sql) ) )
        print('1')
        -- print(sth:fetch())
        if sth:fetch() == '1'
        then
            print('2')
            if dq.qtype == pdns.A
            then
                print('3')
                print("Query ",domain," Blocked")
                dq:addAnswer(pdns.A, "127.0.0.1")
                dq:addAnswer(pdns.TXT, "\"Domain ini diblokir\"", 3601)
                return true
            else
                return false
            end
        else
            return false
        end
    -- end
    -- return false
end