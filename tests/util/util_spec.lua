--{{{> Qeuroal
---@module "luassert"

local PithyVim = require("pithyvim.util")

describe("util", function()
  it("memoizes by argument", function()
    local calls = 0
    local memoized = PithyVim.memoize(function(value)
      calls = calls + 1
      return value
    end)

    assert.are.equal(1, memoized(1))
    assert.are.equal(1, memoized(1))
    assert.are.equal(2, memoized(2))
    assert.are.equal(2, calls)
  end)

  it("keeps memoized functions independent", function()
    local first = PithyVim.memoize(function()
      return 1
    end)
    local second = PithyVim.memoize(function()
      return 2
    end)

    assert.are.equal(1, first())
    assert.are.equal(2, second())
  end)
end)
--<}}}
