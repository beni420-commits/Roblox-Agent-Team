--!strict
-- Server-Einstiegspunkt. Sprint 0: absichtlich leer (nur Bootstrap).
-- Systeme werden ab Sprint 1 hier in fester Reihenfolge initialisiert (siehe docs/tech_notes.md).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local _BuildInfo = require(ReplicatedStorage.Shared.BuildInfo)
