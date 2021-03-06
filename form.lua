local function build_element(context, desc, values)
	local builder = libform.elements[desc.type]
	if not builder then
		error("Element not found: " .. desc.type)
	end
	return builder(context, desc, values)
end

local escape = minetest.formspec_escape

local function shift(context, pos)
	local x = pos[1] or pos.x or pos.left
	local y = pos[2] or pos.y or pos.top
	return { context.shift[1] + x, context.shift[2] + y }
end

local function inventory(context, name, default)
	local inv = context.namespace.values[name] or default
	return ("%s;%s"):format(escape(inv[1] or inv.context), escape(inv[2] or inv.name))
end

local function position(context, pos)
	return ("%f,%f"):format(unpack(shift(context, pos)))
end

local function size(context, size)
	return ("%f,%f"):format(size[1] or size.width or size.w, size[2] or size.height or size.h)
end

local function namespace(context, name)
	local base = context.namespace
	if not name then
		return base
	end
	return {
		name = ("%s.%s"):format(base, escape(name)),
		values = base.values[name] or {},
		seq = 0,
	}
end

local function image(context, img)
	if not img then
		return
	end
	if type(img) == "string" then
		return "image", img
	end
	local item = img.item or img.node
	if item then
		return "item", img.item
	end
	local image = img.image or img.texture
	if image then
		return "image", image
	end
	error("Invalid image specification")
end

local function image_strs(context, img)
	local kind, name = image(context, img)
	if kind then
		return kind, name .. ";"
	end
	return "none", ""
end

local function build_context(context, desc)
	return {
		parent = {
			context = context,
			desc = desc,
		},
		namespace = namespace(context, desc.namespace),
		shift = shift(context, desc.pos or { 0, 0 }),
	}
end

local function build_elements(context, list)
	local code = ""
	for _, element in ipairs(list) do
		local line = build_element(context, element)
		code = code .. line
	end
	return code
end

local function element_name(context, name)
	if name then
		return ("%s.%s"):format(context.namespace.name, escape(name))
	end
	context.namespace.seq = context.namespace.seq + 1
	return ("%s.-%d"):format(context.namespace.name, context.namespace.seq)
end

local function element_value(context, name, default)
	if not name then
		return escape(default or "")
	end
	return escape(context.namespace.values[name] or default or "")
end

libform.elements = {}

function libform.elements.form(context, desc)
	if context.parent then
		error("Form can't have a parent element")
	end
	local ctx = build_context(context, desc)
	local code = ("size[%s;]"):format(size(context, desc.size))
	code = code .. build_elements(ctx, desc.elements)
	return code
end

function libform.elements.inventory(context, desc)
	return ("list[%s;%s;%s;%d]"):format(
		inventory(context, desc.name, desc.list or desc.inventory),
		position(context, desc.pos or desc.position),
		size(context, desc.size),
		desc.start_index or 0
	)
end

function libform.elements.field(context, desc)
	return ("field[%s;%s;%s;%s;%s]"):format(
		position(context, desc.pos or desc.position),
		size(context, desc.size),
		element_name(context, desc.name),
		escape(desc.label or ""),
		element_value(context, desc.name, desc.default)
	)
end

function libform.elements.label(context, desc)
	return ("%s[%s;%s]"):format(
		desc.vertical and "vertlabel" or "label",
		position(context, desc.pos or desc.position),
		element_value(context, desc.name, desc.text or desc.value or desc.label)
	)
end

local button_type = {
	none = "button",
	image = "image_button",
	item = "item_image_button",
}

function libform.elements.button(context, desc)
	local image_kind, image_code = image_strs(context, desc.image)
	local key = button_type[image_kind]
	local key2 = ""
	if desc.exit then
		key2 = "_exit"
	end
	return ("%s%s[%s;%s;%s%s;%s]"):format(
		key,
		key2,
		position(context, desc.pos or desc.position),
		size(context, desc.size),
		image_code,
		element_name(context, desc.name),
		element_value(context, desc.name, desc.label or desc.text)
	)
end

function libform.build(desc, values)
	local ctx = {
		namespace = {
			name = "libform:form",
			values = values or {},
			seq = 0,
		},
		shift = {
			0,
			0,
		},
	}
	return build_element(ctx, desc)
end
