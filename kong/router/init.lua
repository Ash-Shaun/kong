local _M = {
  MATCH_LRUCACHE_SIZE = 5e3,
}

local kong = kong

local traditional = require("kong.router.traditional")
local atc_compat = require("kong.router.atc_compat")
local is_http = ngx.config.subsystem == "http"


local _MT = { __index = _M, }


function _M:exec(ctx)
  return self.trad.exec(ctx)
end


function _M:select(req_method, req_uri, req_host, req_scheme,
                   src_ip, src_port,
                   dst_ip, dst_port,
                   sni, req_headers)
  return self.trad.select(req_method, req_uri, req_host, req_scheme,
                          src_ip, src_port,
                          dst_ip, dst_port,
                          sni, req_headers)
end


function _M.new(routes, cache, cache_neg)
  if not is_http or
     not kong or
     not kong.configuration or
     kong.configuration.router_flavor == "traditional"
  then
    local trad, err = traditional.new(routes, cache, cache_neg)
    if not trad then
      return nil, err
    end

    return setmetatable({
      trad = trad,
    }, _MT)
  end

  return atc_compat.new(routes)
end


_M._set_ngx = traditional._set_ngx
_M.split_port = traditional.split_port


return _M
