I18n.locale = 'pt-BR'

LOCALE_OPTIONS = []
Dir["#{File.dirname __FILE__}/../locales/active_scaffold/*.*"].each {|file|
  LOCALE_OPTIONS << File.split(file)[1].split(".")[0]
  I18n.load_path << file
}
=begin
<% form_tag(:action => "change_language") do %>
<%= select_tag(nil, options_for_select([as_(:_select_)] + LOCALE_OPTIONS.collect {|locale| [I18n.backend.translate(locale, :locale_name), locale]}, I18n.locale.to_s), {:name => :lang_code, :onchange => "javascript:submit();"}) %>
<% end %>
=end
