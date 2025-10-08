-- start: default value is 1, must be a number, in [0,8]
-- end_: default value is 3, must be a number, in [2,9]
-- depth: default value is 3, must be a number, in [1,9]
function gen_labels(start, end_, depth)
  local start_num = type(start) == "number" and start or 1
  local end_num = type(end_) == "number" and end_ or 3
  local max_depth = type(depth) == "number" and depth or 3

  if start_num < 0 then
    error "Error: start number must >= 0"
  end
  if end_num < start_num then
    error "Error: end number must < start number"
  end
  if max_depth < 1 or max_depth > 9 then
    error "Error: depth must >= 1 and <= 9"
  end

  local labels = {}
  local digits = {}

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
      build(current .. d, length - 1)
    end
  end

  for len = 1, max_depth do
    build("", len)
  end

  return labels
end

-- local function assert_tables_equal(actual, expected)
--   assert(#actual == #expected, "Tables length is not equal")
--   local actual_set = {}
--   for _, v in ipairs(actual) do
--     actual_set[v] = true
--   end
--   for _, v in ipairs(expected) do
--     assert(actual_set[v], "Matching value failed: " .. v)
--   end
-- end
--
-- -- test1：default params（start=1, end=3, depth=3）
-- local test1 = gen_labels()
-- local expected1 = {
--   -- len 1: 1,2,3
--   "1",
--   "2",
--   "3",
--   -- len 2: 11,12,13,21,22,23,31,32,33
--   "11",
--   "12",
--   "13",
--   "21",
--   "22",
--   "23",
--   "31",
--   "32",
--   "33",
--   -- len 3: 111,112,...333（3^3=27）
--   "111",
--   "112",
--   "113",
--   "121",
--   "122",
--   "123",
--   "131",
--   "132",
--   "133",
--   "211",
--   "212",
--   "213",
--   "221",
--   "222",
--   "223",
--   "231",
--   "232",
--   "233",
--   "311",
--   "312",
--   "313",
--   "321",
--   "322",
--   "323",
--   "331",
--   "332",
--   "333",
-- }
-- assert_tables_equal(test1, expected1)
-- print "Test1 passed"
--
-- -- test2
-- local test2 = gen_labels(0, 1, 2)
-- local expected2 = {
--   -- len 1: 0,1
--   "0",
--   "1",
--   -- len 2: 00,01,10,11
--   "00",
--   "01",
--   "10",
--   "11",
-- }
-- assert_tables_equal(test2, expected2)
-- print "Test2 passed"
--
-- -- test3：depth = 1
-- local test3 = gen_labels(5, 5, 1)
-- local expected3 = { "5" }
-- assert_tables_equal(test3, expected3)
-- print "Test3 passed"
--
-- -- test4
-- local ok, err = pcall(gen_labels, -1, 2, 3)
-- assert(not ok, "Test4 Failed")
-- print "Test4 passed"
--
-- -- test5
-- local ok, err = pcall(gen_labels, 3, 2, 3)
-- assert(not ok, "Test5 Failed")
-- print "Test5 passed"
--
-- -- test6
-- local ok, err = pcall(gen_labels, 1, 2, 10)
-- assert(not ok, "Test6 Failed")
-- print "Test6 passed"
--
-- -- test7
-- local test7 = gen_labels("invalid", "also invalid", "depth")
-- -- equals to gen_labels(1, 3, 4)
-- assert_tables_equal(test7, expected1)
-- print "Test7 passed"
--
-- print "All tests passed"

return { gen_labels = gen_labels }
