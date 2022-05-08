return function(path: string): (string?, string?)
    local _, _, current, rest = path:find("([^/.]+)(.*)")
    return current, rest
end