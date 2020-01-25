require "defines"

data:extend(
  {
    {
      type = "bool-setting",
      name = defs.settings.show_table,
      setting_type = "runtime-per-user",
      default_value = false,
      order = "a-a"
    },
    {
      type = "string-setting",
      name = defs.settings.table_label,
      setting_type = "runtime-per-user",
      default_value = "TVC API",
      order = "a-b"
    },
    {
      type = "int-setting",
      name = defs.settings.min_raid_host,
      setting_type = "runtime-per-user",
      default_value = 10,
      order = "a-c"
    }
  }
)
