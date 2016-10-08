-- This example is meant to be runnable using standalone Lua interpreter

local EXAMPLE = { type = "form",
	size = { 8, 9 },
	elements = {
		{ type = "inventory",
			pos = { 2, 3 },
			size = { 1, 1 },
			name = "fuel",
			list = { "context", "fuel" },
		},
		{ type = "inventory",
			pos = { 2, 1 },
			size = { 1, 1 },
			name = "source",
			list = { "context", "src" },
		},
		{ type = "inventory",
			pos = { 5, 1 },
			size = { 2, 2 },
			name = "dest",
			list = { "context", "dst" },
		},
		{ type = "inventory",
			pos = { 0, 5 },
			size = { 8, 4 },
			list = { "current_player", "main" },
		},
		{ type = "label",
			pos = { 1.8, 0 },
			vertical = true,
			text = "Furnace inactive",
		},
		{ type = "label",
			pos = { 0, 0 },
			name = "player",
		},
		{ type = "field",
			pos = { 2, 4 },
			size = { 4, 1 },
			name = "name",
-- 			label = "Furnace name",
		},
		{ type = "button",
			pos = { 6, 4 },
			size = { 2, 1 },
			label = "To inventory",
		},
	},
}

if not minetest then
	-- Stubs
	minetest = {
		get_modpath = function() return "." end,
		formspec_escape = function(str) return str end,
		override_item = function() end,
	}
	dofile("./init.lua")
end

print((libform.build(EXAMPLE):gsub("]", "]\n")))

return EXAMPLE
