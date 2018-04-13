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
-- @file        xmake.lua
--

-- define rule
rule("qt:console")

    -- on load
    on_load(function (target)
        
        -- set kind: binary
        target:set("kind", "binary")

        -- add defines for using core lib
        target:add("defines", "QT_CORE_LIB")

        -- add defines for the compile mode
        if is_mode("debug") then
            target:add("defines", "QT_QML_DEBUG")
        elseif is_mode("release") then
            target:add("defines", "QT_NO_DEBUG")
        elseif is_mode("profile") then
            target:add("defines", "QT_QML_DEBUG", "QT_NO_DEBUG")
        end

        -- The following define makes your compiler emit warnings if you use
        -- any feature of Qt which as been marked deprecated (the exact warnings
        -- depend on your compiler). Please consult the documentation of the
        -- deprecated API in order to know how to port your code away from it.
        target:add("defines", "QT_DEPRECATED_WARNINGS")
    end)

