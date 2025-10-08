-- start: default value is 1, must be a number, in [0,8]
-- end_: default value is 3, must be a number, in [2,9]
-- depth: default value is 3, must be a number, in [1,9]
-- skip_consecutive: can be nil, eg. gen_labels(1,3,4) so it won't effect previous customization
function gen_labels(start, end_, depth, skip_consecutive)
  local start_num = type(start) == "number" and start or 1
  local end_num = type(end_) == "number" and end_ or 3
  local max_depth = type(depth) == "number" and depth or 3
  local skip_num = type(skip_consecutive) == "number" and skip_consecutive or nil

  if start_num < 0 then
    error "Error: start number must >= 0"
  end
  if end_num < start_num then
    error "Error: end number must > start number"
  end
  if max_depth < 1 or max_depth > 9 then
    error "Error: depth must >= 1 and <= 9"
  end
  if skip_num ~= nil then
    if skip_num < 0 or skip_num > 9 then
      error "Error: skip_consecutive must be in [0,9] if provided"
    end
  end

  local labels = {}
  local digits = {}
  -- NOTE: convert into str for the convenience of comparision
  local skip_str = skip_num ~= nil and tostring(skip_num) or nil

  -- gen basic number set
  for i = start_num, end_num do
    table.insert(digits, tostring(i))
  end

  local function build(current, length)
    if length == 0 then
      table.insert(labels, current)
      return
    end
    for _, d in ipairs(digits) do
      if skip_str and current ~= "" and current:sub(-1) == d and d == skip_str then
        goto continue
      end
      build(current .. d, length - 1)
      ::continue::
    end
  end

  for len = 1, max_depth do
    build("", len)
  end

  return labels
end

-- util func
local function arrays_equal(a, b)
  if #a ~= #b then
    return false
  end
  for i = 1, #a do
    if a[i] ~= b[i] then
      return false
    end
  end
  return true
end

local function run_test(name, test_func)
  local success, result = pcall(test_func)
  if success and result then
    print(string.format("[PASS] %s", name))
  else
    print(string.format("[FAIL] %s (reason: %s)", name, result or "unkown err"))
  end
end

-- test 1:
run_test("default params test(no skip)", function()
  local expected = {
    "1",
    "2",
    "3",
    "11",
    "12",
    "13",
    "21",
    "22",
    "23",
    "31",
    "32",
    "33",
    "111",
    "112",
    "113",
    "121",
    "122",
    "123",
    "131",
    "132",
    "133",
    "211",
    "212",
    "213",
    "221",
    "222",
    "223",
    "231",
    "232",
    "233",
    "311",
    "312",
    "313",
    "321",
    "322",
    "323",
    "331",
    "332",
    "333",
  }
  local actual = gen_labels()
  return arrays_equal(actual, expected)
end)

-- test 2:skip_consecutive=1
run_test("no consecutive 1 test", function()
  local expected = {
    "1",
    "2",
    "3",
    "12",
    "13",
    "21",
    "22",
    "23",
    "31",
    "32",
    "33",
    "121",
    "122",
    "123",
    "131",
    "132",
    "133",
    "212",
    "213",
    "221",
    "222",
    "223",
    "231",
    "232",
    "233",
    "312",
    "313",
    "321",
    "322",
    "323",
    "331",
    "332",
    "333",
  }
  local actual = gen_labels(1, 3, 3, 1)
  return arrays_equal(actual, expected)
end)

-- test 3:skip_consecutive=2
run_test("no consecutive 2 test", function()
  local expected = {
    "1",
    "2",
    "3",
    "11",
    "12",
    "13",
    "21",
    "23",
    "31",
    "32",
    "33",
    "111",
    "112",
    "113",
    "121",
    "123",
    "131",
    "132",
    "133",
    "211",
    "212",
    "213",
    "231",
    "232",
    "233",
    "311",
    "312",
    "313",
    "321",
    "323",
    "331",
    "332",
    "333",
  }
  local actual = gen_labels(1, 3, 3, 2)
  return arrays_equal(actual, expected)
end)

-- test 4：boundary params
run_test("boundary params (start=0, end=9, depth=1) test", function()
  local expected = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }
  local actual = gen_labels(0, 9, 1)
  return arrays_equal(actual, expected)
end)

-- test 5: depth=1
run_test("depth=1 no skip test", function()
  local expected = { "1", "2", "3" }
  local actual1 = gen_labels(1, 3, 1, 1)
  local actual2 = gen_labels(1, 3, 1, 2)
  return arrays_equal(actual1, expected) and arrays_equal(actual2, expected)
end)

-- test 6
run_test("skip_consecutive=10 (out of range)）", function()
  local success, err = pcall(gen_labels, 1, 3, 3, 10)
  assert(not success, "Failed")
  return true
end)
return { gen_labels = gen_labels }
