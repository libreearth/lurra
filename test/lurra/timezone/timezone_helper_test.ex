defmodule Lurra.TimezoneHelperTest do
  use ExUnit.Case

  describe "format_date/2" do
    test "formats date in the specified timezone" do
      unix_time = 1624368000000
      timezone = "America/New_York"
      expected_result = "22/06/2021 09:20:00"

      result = Lurra.TimezoneHelper.format_date(unix_time, timezone)
      assert result == expected_result
    end
  end

  describe "local_text_to_unix/2" do
    test "converts local text date to UNIX timestamp" do
      text_date = "2023-01-22T00:30"
      timezone = "America/New_York"
      expected_result = 1674365400000  # UNIX timestamp for Jan 22 2023 00:30:00 NY time

      result = Lurra.TimezoneHelper.local_text_to_unix(text_date, timezone)
      assert result == expected_result
    end
  end

end
