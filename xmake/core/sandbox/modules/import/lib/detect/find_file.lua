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
-- @file        find_file.lua
--

-- define module
local sandbox_lib_detect_find_file = sandbox_lib_detect_find_file or {}

-- load modules
local os        = require("base/os")
local path      = require("base/path")
local utils     = require("base/utils")
local table     = require("base/table")
local raise     = require("sandbox/modules/raise")
local vformat   = require("sandbox/modules/vformat")

-- find the given file path or directory
function sandbox_lib_detect_find_file._find(filedir, name)

    -- get file path 
    local filepath = nil
    if os.isfile(filedir) then
        filepath = filedir
    else
        filepath = path.join(filedir, name)
    end

    -- file exists?
    for _, file in ipairs(os.files(filepath)) do
        return file
    end
end

-- find file
--
-- @param name      the file name
-- @param pathes    the search pathes (.e.g dirs, pathes, winreg pathes)
-- @param opt       the options, .e.g {suffixes = {"/aa", "/bb"}}
--
-- @return          the file path
--
-- @code
--
-- local file = find_file("ccache", { "/usr/bin", "/usr/local/bin"})
-- local file = find_file("test.h", { "/usr/include", "/usr/local/include/**"})
-- local file = find_file("xxx.h", { "$(env PATH)", "$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name)"})
-- local file = find_file("xxx.h", { "$(env PATH)", function () return val("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name"):match("\"(.-)\"") end})
--
-- @endcode
--
function sandbox_lib_detect_find_file.main(name, pathes, opt)

    -- init options
    opt = opt or {}

    -- find file
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
                local results = sandbox_lib_detect_find_file._find(filedir, name)
                if results then
                    return results
                end
            end
        else
            -- find file in the given path
            local results = sandbox_lib_detect_find_file._find(_path, name)
            if results then
                return results
            end
        end
    end
end

-- return module
return sandbox_lib_detect_find_file
