module("luci.controller.forked-daapd", package.seeall)

function index()
	entry({"admin", "nas"}, firstchild(), _("NAS") , 45).dependent = false
	if not nixio.fs.access("/etc/config/forked-daapd") then
		return
	end

	entry({"admin", "nas", "forked-daapd"}, cbi("forked-daapd"), _("Music Remote Center")).dependent = true
	entry({"admin", "nas", "forked-daapd", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.running = luci.sys.call("pgrep forked-daapd >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
