--!strict
-- Gemeinsamer Testrunner des Repos (tests/TestRunner.luau), hier nur weitergereicht.
local TestRunner = require("../../../tests/TestRunner")

export type Expectation = TestRunner.Expectation
export type Suite = TestRunner.Suite

return TestRunner
