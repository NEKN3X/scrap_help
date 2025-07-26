import gleam/dynamic/decode.{bool, list, string, subfield, success}

pub type Metadata {
  Metadata(
    id: String,
    name: String,
    author: String,
    version: String,
    language: String,
    description: String,
    website: String,
    disabled: Bool,
    home_disabled: Bool,
    execute_file_path: String,
    execute_file_name: String,
    plugin_directory: String,
    action_keyword: String,
    action_keywords: List(String),
    hide_action_keyword_panel: Bool,
    ico_path: String,
    plugin_settings_directory_path: String,
    plugin_cache_directory_path: String,
  )
}

pub type Context {
  Context(metadata: Metadata)
}

pub fn decode(data) {
  let decoder = {
    let meta = "currentPluginMetadata"
    use id <- subfield([meta, "id"], string)
    use name <- subfield([meta, "name"], string)
    use author <- subfield([meta, "author"], string)
    use version <- subfield([meta, "version"], string)
    use language <- subfield([meta, "language"], string)
    use description <- subfield([meta, "description"], string)
    use website <- subfield([meta, "website"], string)
    use disabled <- subfield([meta, "disabled"], bool)
    use home_disabled <- subfield([meta, "homeDisabled"], bool)
    use execute_file_path <- subfield([meta, "executeFilePath"], string)
    use execute_file_name <- subfield([meta, "executeFileName"], string)
    use plugin_directory <- subfield([meta, "pluginDirectory"], string)
    use action_keyword <- subfield([meta, "actionKeyword"], string)
    use action_keywords <- subfield([meta, "actionKeywords"], list(string))
    use hide_action_keyword_panel <- subfield(
      [meta, "hideActionKeywordPanel"],
      bool,
    )
    use ico_path <- subfield([meta, "icoPath"], string)
    use plugin_settings_directory_path <- subfield(
      [meta, "pluginSettingsDirectoryPath"],
      string,
    )
    use plugin_cache_directory_path <- subfield(
      [meta, "pluginCacheDirectoryPath"],
      string,
    )
    success(
      Context(Metadata(
        id,
        name,
        author,
        version,
        language,
        description,
        website,
        disabled,
        home_disabled,
        execute_file_path,
        execute_file_name,
        plugin_directory,
        action_keyword,
        action_keywords,
        hide_action_keyword_panel,
        ico_path,
        plugin_settings_directory_path,
        plugin_cache_directory_path,
      )),
    )
  }
  decode.run(data, decoder)
}
