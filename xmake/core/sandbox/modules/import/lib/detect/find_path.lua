--!A cross-platform build utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2018, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        find_path.lua
--

-- define module
local sandbox_lib_detect_find_path = sandbox_lib_detect_find_path or {}

-- load modules
local os        = require("base/os")
local path      = require("base/path")
local table     = require("base/table")
local raise     = require("sandbox/modules/raise")
local vformat   = require("sandbox/modules/vformat")

-- find the given file path or directory
function sandbox_lib_detect_find_path._find(filedir, name)

    -- path exists?
    for _, p in ipairs(os.filedirs(path.join(filedir, name))) do
        return filedir
    end
end

-- find path
--
-- @param name      the path name
-- @param pathes    the search pathes (.e.g dirs, pathes, winreg pathes)
-- @param opt       the options, .e.g {suffixes = {"/aa", "/bb"}}
--
-- @return          the path
--
-- @code
--
-- local p = find_path("include/test.h", { "/usr", "/usr/local"})
--  -> /usr/local ("/usr/local/include/test.h")
--
-- local p = find_path("include/*.h", { "/usr", "/usr/local/**"})
-- local p = find_path("lib/xxx", { "$(env PATH)", "$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name)"})
-- local p = find_path("lib/xxx", { "$(env PATH)", function () return val("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name"):match("\"(.-)\"") end})
--
-- @endcode
--
function sandbox_lib_detect_find_path.main(name, pathes, opt)

    -- init options
    opt = opt or {}

    -- find path
    local suffixes = table.wrap(opt.suffixes)
    for _, _path in ipairs(table.wrap(pathes)) do

        -- format path for builtin variables
        if type(_path) == "function" then
            local ok, results = sandbox.load(_path) 
            if ok then
                _path = results or ""
            else 
                raise(results)
            end
        else
            _path = vformat(_path)
        end

        -- find file with suffixes
        if #suffixes > 0 then
            for _, suffix in ipairs(table.wrap(opt.suffixes)) do
                local filedir = path.join(_path, suffix)
                local results = sandbox_lib_detect_find_path._find(filedir, name)
                if results then
                    return results
                end
            end
        else
            -- find file in the given path
            local results = sandbox_lib_detect_find_path._find(_path, name)
            if results then
                return results
            end
        end
    end
end

-- return module
return sandbox_lib_detect_find_path
