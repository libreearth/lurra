defmodule Lurra.Triggers.RulesTests do
  use Lurra.DataCase

  describe "rule grater than" do
    test "greater than works with numbers false case" do
      assert Lurra.Triggers.Rules.GreaterThan.check_rule(%{"limit_value" => "1700"}, 1600) == false
    end

    test "greater than works with text false case" do
      assert Lurra.Triggers.Rules.GreaterThan.check_rule(%{"limit_value" => "1700"}, "1600") == false
    end

    test "greater than works with numbers true case" do
      assert Lurra.Triggers.Rules.GreaterThan.check_rule(%{"limit_value" => "1700"}, 1900) == true
    end

    test "greater than works with text true case" do
      assert Lurra.Triggers.Rules.GreaterThan.check_rule(%{"limit_value" => "1700"}, "1900") == true
    end
  end

  describe "rule lower than" do
    test "lower than works with numbers false case" do
      assert Lurra.Triggers.Rules.LowerThan.check_rule(%{"limit_value" => "1500"}, 1600) == false
    end

    test "lower than works with text false case" do
      assert Lurra.Triggers.Rules.LowerThan.check_rule(%{"limit_value" => "1500"}, "1600") == false
    end

    test "lower than works with numbers true case" do
      assert Lurra.Triggers.Rules.LowerThan.check_rule(%{"limit_value" => "1700"}, 1500) == true
    end

    test "lower than works with text true case" do
      assert Lurra.Triggers.Rules.LowerThan.check_rule(%{"limit_value" => "1700"}, "1500") == true
    end
  end

  describe "rule between than" do
    test "between than works with numbers false case" do
      assert Lurra.Triggers.Rules.InBetween.check_rule(%{"min_value" => "1500", "max_value" => "2000"}, 1200) == false
    end

    test "between than works with text false case" do
      assert Lurra.Triggers.Rules.InBetween.check_rule(%{"min_value" => "1500", "max_value" => "2000"}, "1200") == false
    end

    test "between than works with numbers true case" do
      assert Lurra.Triggers.Rules.InBetween.check_rule(%{"min_value" => "1500", "max_value" => "2000"}, 1700) == true
    end

    test "between than works with text true case" do
      assert Lurra.Triggers.Rules.InBetween.check_rule(%{"min_value" => "1500", "max_value" => "2000"}, "1700") == true
    end
  end

  describe "inactive time rule fails" do
    test "inactive time rule" do
      assert Lurra.Triggers.Rules.InactiveMoreThan.check_time_rule(%{"minutes" => "2"}, 0, 0) == false
    end

    test "inactive time rule complains" do
      assert Lurra.Triggers.Rules.InactiveMoreThan.check_time_rule(%{"minutes" => "2"}, 2*60*1000+1, 0) == true
    end
  end
end
