module ThemesHelper
	extend ERB::DefMethod

	def_erb_method('render_panel(entry, count_entry, show_entry )', "#{Rails.root}/app/views/themes/_panel.html.erb")

	def_erb_method('render_entry(entry, count_entry, show_entry )', "#{Rails.root}/app/views/themes/_entry.html.erb")

	def_erb_method('render_modal_form(child)', "#{Rails.root}/app/views/themes/_modal_form.html.erb")

end
