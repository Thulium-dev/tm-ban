if (Config.log == true and Config.webhook == "") then
    print("You have logging on, but no webhook to send logs to. Add webhook to config.lua")
end

if (string.lower(Config.action) == "warn" and Config.webhook == "") then
    print("You have action to warn, but no webhook to send warnnings to. Add webhook to config.lua")
end

if GetResourceState("tm-report") == "missing" then 
    print("tm-report is not installed, please install it. https://github.com/Thulium-dev/tm-report", 3)
end

local function send(embed)
    PerformHttpRequest(Config.webhook, function(status, response, headers) end, 'POST', json.encode({ embeds = {embed} }), { ['Content-Type'] = 'application/json' })
end

AddEventHandler("playerConnecting", function(name, setReason, deferrals)
    deferrals.defer()
    deferrals.update("Checking Thulium.dev's modder database...")
    local src = source
    local xPlayer = GetPlayerIdentifiers(src)
    local license
    for k,value in ipairs(xPlayer) do
        if (string.match(value, 'license:')) then
            license = value
        end
    end
    local reportted = false
    local rateLimit = false
    local error = false
    for k,v in ipairs(xPlayer) do
        if (reportted or rateLimit) then
            break
        elseif (string.match(v, 'ip:')) then 
        
        else
            PerformHttpRequest("https://api.thulium.dev/v1/citizenban/check/"..v, function(status,response,headers)
                if (status == 200) then
                    local res = json.decode(response)
                    if (res.banned) then
                        if (string.lower(Config.action) == "kick") then
                            deferrals.done("You have been kicked because you are a modder. You are in CitizenBan's modder database.")
                            if (reportted == false) then
                                send({
                                    title = "Kicked",
                                    description = name.." have been kicked. Found in CitizenBan's modder database.\n\n**ID found:** "..v.."\n**License:** "..license,
                                    image = {
                                        url = res.image,
                                    },
                                })

                                reportted = true
                            end
                        elseif (string.lower(Config.action) == "warn") then
                            if (reportted == false) then
                                send({
                                    title = "Warning",
                                    description = name.." is a modder. Found in CitizenBan's modder database.\n\n**ID found:** "..v.."\n**License:** "..license,
                                    image = {
                                        url = res.image,
                                    },
                                })

                                reportted = true
                            end
                            deferrals.done()
                        end
                    else 
                        deferrals.done()
                    end
                elseif (status == 429) then
                    deferrals.done()
                    print("Http request fail because your are rate limited.\nIf you want to rise your limit contact CitizenBan.\nCould't check player ("..v..")")
                    rateLimit = true
                else
                    if (error == false) then
                        deferrals.done()
                        print("Http request fail. Could't check player ("..v..")")
                        error = true
                    end
                end
            end, "GET")
        end
    end
end)