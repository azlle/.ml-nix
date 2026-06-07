-- lua/urls-cleanup.lua
local M = {}

-- ?foo=1&bar=2&t=30 → { foo="1", bar="2", t="30" }
local function parse_query(query_str)
  local params = {}
  for key, val in (query_str or ""):gmatch("([^&=]+)=([^&]*)") do
    params[key] = val
  end
  return params
end

-- URL を scheme / host / path / query に分解
local function parse_url(url)
  local scheme, host, path, query =
    url:match("^(https?):\/\/([^/?#]+)([^?#]*)%??(.*)")
  return {
    scheme = scheme,
    host   = host   or "",
    path   = path   or "",
    query  = parse_query(query),
  }
end

function M.cleanup_url(str)
  local url = str:match("https?://[^%s%]]+") or str
  local u = parse_url(url)

  -- YouTube
  if u.host:match("youtube%.com$") then
    local id = u.query["v"]
               or u.path:match("^/live/([^/?#]+)")
    if id then
      local t = u.query["t"]
      return t and ("https://youtu.be/" .. id .. "?t=" .. t)
               or  ("https://youtu.be/" .. id)
    end

  -- X / Twitter
  elseif u.host:match("[xt]witter%.com$") or u.host == "x.com" then
    local user, id = u.path:match("^/([^/]+)/status/(%d+)")
    if user and id then
      return string.format("https://x.com/%s/status/%s", user, id)
    end

  -- Twitch
  elseif u.host:match("twitch%.tv$") then
    local id = u.path:match("^/videos/(%d+)")
               or u.path:match("/video/(%d+)")
    if id then
      local t = u.query["t"]
      return t and ("https://www.twitch.tv/videos/" .. id .. "?t=" .. t)
               or  ("https://www.twitch.tv/videos/" .. id)
    end
  end

  return str
end

-- バッファ/選択範囲内の対象 URL を一括置換
function M.cleanup_range(line1, line2)
  local pattern = "https?://[^%s%]]+"
  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
  local changed = false

  for i, line in ipairs(lines) do
    local new_line = line:gsub(pattern, function(url)
      local cleaned = M.cleanup_url(url)
      if cleaned ~= url then
        changed = true
        return cleaned
      end
      return url
    end)
    lines[i] = new_line
  end

  if changed then
    vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
    vim.notify("URLs cleaned!", vim.log.levels.INFO)
  else
    vim.notify("No URLs to clean.", vim.log.levels.INFO)
  end
end

-- :UrlsCleanup コマンド
vim.api.nvim_create_user_command("UrlsCleanup", function(opts)
  M.cleanup_range(opts.line1, opts.line2)
end, {
  range = true,
  desc = "YouTube/X/Twitch の URL を整形する",
})

-- vim.paste をオーバーライドしてペースト時に自動整形
local original_paste = vim.paste
vim.paste = function(lines, phase)
  local cleaned = vim.tbl_map(function(line)
    return line:gsub("https?://[^%s%]]+", M.cleanup_url)
  end, lines)
  return original_paste(cleaned, phase)
end

return M
