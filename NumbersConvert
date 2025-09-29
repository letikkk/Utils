local suffixes = {
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc",
	"Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod",
	"Vg", "Uvg", "Dvg", "Tvg"
}

return {
	ToString = function(number, decimalPlaces)
		decimalPlaces = decimalPlaces or 1
		local exponent = math.floor(math.log(math.max(1, math.abs(number)), 1000))
		local suffix = suffixes[exponent + 1] or ("e+" .. exponent)
		local scaled = number / (1000 ^ exponent)
		local rounded = math.floor(scaled * (10 ^ decimalPlaces)) / (10 ^ decimalPlaces)
		local formatted = string.format("%." .. decimalPlaces .. "f", rounded):gsub("%.?0+$", "")
		return formatted .. suffix
	end,

	Comma = function(number)
		local str = tostring(number)
		while true do
			local replaced = str:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
			if replaced == str then break end
			str = replaced
		end
		return str
	end
}
