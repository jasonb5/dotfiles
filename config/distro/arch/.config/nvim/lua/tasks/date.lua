local M = {}

local alphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

local function encode_base32(value, width)
  local out = {}

  repeat
    local remainder = value % 32
    out[#out + 1] = alphabet:sub(remainder + 1, remainder + 1)
    value = math.floor(value / 32)
  until value == 0

  while #out < width do
    out[#out + 1] = "0"
  end

  local encoded = table.concat(out):reverse()
  if #encoded > width then
    return encoded:sub(#encoded - width + 1)
  end

  return encoded
end

local function local_time(year, month, day)
  return os.time({ year = year, month = month, day = day, hour = 12, min = 0, sec = 0 })
end

function M.today()
  return os.date("%Y-%m-%d")
end

function M.parse(date)
  local year, month, day = date:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
  if not year then
    error("invalid date: " .. tostring(date))
  end

  return {
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
  }
end

function M.timestamp(date)
  local parts = M.parse(date)
  return local_time(parts.year, parts.month, parts.day)
end

function M.format(timestamp)
  return os.date("%Y-%m-%d", timestamp)
end

function M.add_days(date, delta)
  return M.format(M.timestamp(date) + (delta * 24 * 60 * 60))
end

function M.is_monday(date)
  return os.date("%u", M.timestamp(date)) == "1"
end

function M.week_key(date)
  return os.date("%G-W%V", M.timestamp(date))
end

function M.week_title(date)
  return string.format("Week %s, %s", os.date("%V", M.timestamp(date)), os.date("%G", M.timestamp(date)))
end

function M.week_range_for(date)
  local timestamp = M.timestamp(date)
  local weekday = tonumber(os.date("%u", timestamp))
  local start_date = M.format(timestamp - ((weekday - 1) * 24 * 60 * 60))
  local end_date = M.add_days(start_date, 6)

  return start_date, end_date
end

function M.previous_week_range(date)
  local current_start = M.week_range_for(date)
  local previous_start = M.add_days(current_start, -7)
  return previous_start, M.add_days(previous_start, 6)
end

function M.current_week_so_far(date)
  local start_date = M.week_range_for(date)
  return start_date, date
end

function M.range(start_date, end_date)
  local out = {}
  local current = start_date

  while current <= end_date do
    out[#out + 1] = current
    current = M.add_days(current, 1)
  end

  return out
end

function M.daily_path(root, date)
  local parts = M.parse(date)
  return string.format("%s/%04d/%02d-%02d.md", root, parts.year, parts.month, parts.day)
end

function M.weekly_path(root, date)
  local week_key = M.week_key(date)
  local year, week = week_key:match("^(%d%d%d%d)%-W(%d%d)$")
  return string.format("%s/weekly/%s/week-%s.md", root, year, week)
end

function M.iso_timestamp()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

function M.new_task_id()
  local timestamp = math.floor((vim.uv.hrtime() / 1000000) % 1099511627776)
  local hash = vim.fn.sha256(table.concat({
    tostring(vim.uv.hrtime()),
    tostring(os.time()),
    tostring(math.random()),
    vim.loop.os_gethostname(),
  }, ":"))

  local random_part = {}
  for index = 1, 16 do
    local value = tonumber(hash:sub(index * 2 - 1, index * 2), 16) or 0
    random_part[#random_part + 1] = alphabet:sub((value % 32) + 1, (value % 32) + 1)
  end

  return "tsk_" .. encode_base32(timestamp, 10) .. table.concat(random_part)
end

return M
