@ECHO OFF
rem ----------------------------------------------------------------------------
rem
rem stress_test.bat: SQL - stress testing.
rem
rem Copyright (c) 2012-17 K2 Informatics GmbH.  All Rights Reserved.
rem
rem This file is provided to you under the Apache License,
rem Version 2.0 (the "License"); you may not use this file
rem except in compliance with the License.  You may obtain
rem a copy of the License at
rem
rem   http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing,
rem software distributed under the License is distributed on an
rem "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
rem KIND, either express or implied.  See the License for the
rem specific language governing permissions and limitations
rem under the License.
rem
rem ----------------------------------------------------------------------------

Setlocal EnableDelayedExpansion

SET NO_RUNS=%1
IF "%1" == "" (
   SET NO_RUNS=1
)

> stress_test.log (

    ECHO =======================================================================
    ECHO !TIME! Start run - in total %NO_RUNS%

    IF EXIST _build\test\logs (
        ECHO "Deleting _build\test\logs"
        RD /Q /S _build\test\logs
    )
    MD _build\test\logs
    IF EXIST tmp\backup (
        ECHO "Deleting tmp\backup"
        RD /Q /S tmp\backup
    )
    MD tmp\backup

    REM Setting sqlparse options ...............................................
    REM true: compacted / false: detailed.
    SET GENERATE_COMPACTED=true
    SET GENERATE_CT=true
    SET GENERATE_EUNIT=false
    SET GENERATE_PERFORMANCE=true
    SET GENERATE_RELIABILITY=false
    SET MAX_BASIC=250

    FOR /L %%G IN (1,1,%NO_RUNS%) DO (
       ECHO -----------------------------------------------------------------------
       ECHO !TIME! %%G. Step: gen_tests.bat
       CALL test\gen_tests.bat

       MD tmp\backup\%%G
       COPY test\*_SUITE.erl tmp\backup\%%G

       ECHO !TIME! %%G. Step: rebar3 ct
       CALL rebar3 ct
    )

    ECHO -----------------------------------------------------------------------
    ECHO !TIME! End   run
    ECHO =======================================================================

)
