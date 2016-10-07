-- This example is meant to be runnable using standalone Lua interpreter

local EXAMPLE = { type = "form",
	size = { 8, 9 },
	elements = {
		{ type = "inventory",
			pos = { 2, 3 },
			size = { 1, 1 },
			list = { "context", "fuel" },
		},
		{ type = "inventory",
			pos = { 2, 1 },
			size = { 1, 1 },
			list = { "context", "src" },
		},
		{ type = "inventory",
			pos = { 5, 1 },
			size = { 2, 2 },
			list = { "context", "dest" },
		},
		{ type = "inventory",
			pos = { 0, 5 },
			size = { 8, 4 },
			list = { "current_player", "main" },
		},
	},
}

-- Stubs
minetest = {
	get_modpath = function() return "." end,
	formspec_escape = function(str) return str end,
}
dofile("./init.lua")

-- Test
print((libform.build(EXAMPLE):gsub("]", "]\n")))
