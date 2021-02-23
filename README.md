# pdns-filter
Lua Script for powerdns-recursor black list filtering
Syatem requiretment :
- fully configured powerdns-recursor version 4.x
- Lua version 5.2
  -> sudo apt install lua5.2
- lua mysql library
  -> sudo apt install lua-sql-mysql
- mysql server

Installation 
- clone the repository
- create database for thr script
- import database template to your database
- place lua folder or the filter_engine.lua to powerdns configuration folder or wherever folder that accessable from pwerdns
- edit the script change database configuration
- edit powerdns-configuration
- find "lua-dns-script"
- uncomment the config and add path to the script
- restart powerdns-ecursor
