# frozen_string_literal: true

describe "Admin Customize Themes", type: :system do
  fab!(:color_scheme)
  fab!(:theme) { Fabricate(:theme, name: "Cool theme 1") }
  fab!(:admin) { Fabricate(:admin, locale: "en") }

  let(:theme_page) { PageObjects::Pages::AdminCustomizeThemes.new }

  before { sign_in(admin) }

  describe "when visiting the page to customize a single theme" do
    it "should allow admin to update the color scheme of the theme" do
      visit("/admin/customize/themes/#{theme.id}")

      color_scheme_settings = find(".theme-settings__color-scheme")

      expect(color_scheme_settings).not_to have_css(".submit-edit")
      expect(color_scheme_settings).not_to have_css(".cancel-edit")

      color_scheme_settings.find(".color-palettes").click
      color_scheme_settings.find(".color-palettes-row[data-value='#{color_scheme.id}']").click
      color_scheme_settings.find(".submit-edit").click

      expect(color_scheme_settings.find(".setting-value")).to have_content(color_scheme.name)
      expect(color_scheme_settings).not_to have_css(".submit-edit")
      expect(color_scheme_settings).not_to have_css(".cancel-edit")
    end
  end

  describe "when editing a local theme" do
    it "The saved value is present in the editor" do
      theme.set_field(target: "common", name: "head_tag", value: "console.log('test')", type_id: 0)
      theme.save!

      visit("/admin/customize/themes/#{theme.id}/common/head_tag/edit")

      expect(find(".ace_content")).to have_content("console.log('test')")
    end

    it "can edit the js field" do
      visit("/admin/customize/themes/#{theme.id}/common/js/edit")

      expect(find(".ace_content")).to have_content("// Your code here")
      find(".ace_text-input", visible: false).fill_in(with: "console.log('test')\n")
      find(".save-theme").click

      try_until_success do
        expect(
          theme.theme_fields.find_by(target_id: Theme.targets[:extra_js])&.value,
        ).to start_with("console.log('test')\n")
      end

      # Check content is loaded from db correctly
      theme
        .theme_fields
        .find_by(target_id: Theme.targets[:extra_js])
        .update!(value: "console.log('second test')")
      visit("/admin/customize/themes/#{theme.id}/common/js/edit")

      expect(find(".ace_content")).to have_content("console.log('second test')")
    end
  end

  describe "when editing theme translations" do
    it "should allow admin to edit and save the theme translations" do
      theme.set_field(
        target: :translations,
        name: "en",
        value: { en: { group: { hello: "Hello there!" } } }.deep_stringify_keys.to_yaml,
      )

      theme.save!

      visit("/admin/customize/themes/#{theme.id}")

      theme_translations_settings_editor =
        PageObjects::Components::AdminThemeTranslationsSettingsEditor.new

      theme_translations_settings_editor.fill_in("Hello World")
      theme_translations_settings_editor.save

      visit("/admin/customize/themes/#{theme.id}")

      expect(theme_translations_settings_editor.get_input_value).to have_content("Hello World")
    end

    it "should allow admin to edit and save the theme translations from other languages" do
      theme.set_field(
        target: :translations,
        name: "en",
        value: { en: { group: { hello: "Hello there!" } } }.deep_stringify_keys.to_yaml,
      )
      theme.set_field(
        target: :translations,
        name: "fr",
        value: { fr: { group: { hello: "Bonjour!" } } }.deep_stringify_keys.to_yaml,
      )
      theme.save!

      visit("/admin/customize/themes/#{theme.id}")

      theme_translations_settings_editor =
        PageObjects::Components::AdminThemeTranslationsSettingsEditor.new
      expect(theme_translations_settings_editor.get_input_value).to have_content("Hello there!")

      theme_translations_picker = PageObjects::Components::SelectKit.new(".translation-selector")
      theme_translations_picker.select_row_by_value("fr")

      expect(page).to have_css(".translations")

      expect(theme_translations_settings_editor.get_input_value).to have_content("Bonjour!")

      theme_translations_settings_editor.fill_in("Hello World in French")
      theme_translations_settings_editor.save
    end

    it "should match the current user locale translation" do
      SiteSetting.allow_user_locale = true
      SiteSetting.set_locale_from_accept_language_header = true
      SiteSetting.default_locale = "fr"

      theme.set_field(
        target: :translations,
        name: "en",
        value: { en: { group: { hello: "Hello there!" } } }.deep_stringify_keys.to_yaml,
      )
      theme.set_field(
        target: :translations,
        name: "fr",
        value: { fr: { group: { hello: "Bonjour!" } } }.deep_stringify_keys.to_yaml,
      )
      theme.save!

      visit("/admin/customize/themes/#{theme.id}")

      theme_translations_settings_editor =
        PageObjects::Components::AdminThemeTranslationsSettingsEditor.new

      expect(theme_translations_settings_editor.get_input_value).to have_content("Hello there!")

      theme_translations_picker = PageObjects::Components::SelectKit.new(".translation-selector")

      expect(theme_translations_picker.component).to have_content("English (US)")
    end
  end

  context "when visting a theme's page" do
    it "has a link to the themes page" do
      visit("/admin/customize/themes/#{theme.id}")
      expect(theme_page).to have_back_button_to_themes_page
    end
  end

  context "when visting a component's page" do
    fab!(:component) { Fabricate(:theme, component: true, name: "Cool component 493") }

    it "has a link to the components page" do
      visit("/admin/customize/themes/#{component.id}")
      expect(theme_page).to have_back_button_to_components_page
    end
  end

  describe "theme color palette editor" do
    before { SiteSetting.use_overhauled_theme_color_palette = true }

    it "shows color palette editor when feature is enabled" do
      theme_page.visit(theme.id)

      expect(theme_page).to have_color_palette_editor
      expect(theme_page).to have_no_color_scheme_selector
    end

    it "doesn't show color palette editor when feature is disabled" do
      SiteSetting.use_overhauled_theme_color_palette = false
      theme_page.visit(theme.id)

      expect(theme_page).to have_no_color_palette_editor
      expect(theme_page).to have_color_scheme_selector
    end

    it "allows editing colors without affecting other themes" do
      theme_page.visit(theme.id)

      original_hex = theme_page.color_palette_editor.get_color_value("primary")
      theme_page.color_palette_editor.change_color("primary", "#ff000e")

      expect(theme_page).to have_palette_editor_save_button
      expect(theme_page).to have_palette_editor_discard_button

      theme_page.palette_editor_save_button.click

      page.refresh

      updated_color = theme_page.color_palette_editor.get_color_value("primary")
      expect(updated_color).to eq("#ff000e")

      other_theme = Fabricate(:theme)
      theme_page.visit(other_theme.id)
      expect(theme_page.color_palette_editor.get_color_value("primary")).to eq("#222222")
    end

    it "allows discarding unsaved color changes" do
      theme_page.visit(theme.id)

      original_hex = theme_page.color_palette_editor.get_color_value("primary")

      theme_page.color_palette_editor.change_color("primary", "#10ff00")

      theme_page.palette_editor_discard_button.click

      expect(theme_page).to have_no_palette_editor_save_button
      expect(theme_page).to have_no_palette_editor_discard_button

      updated_color = theme_page.color_palette_editor.get_color_value("primary")
      expect(updated_color).to eq(original_hex)
    end

    it "allows editing dark mode colors" do
      theme_page.visit(theme.id)

      theme_page.color_palette_editor.switch_to_dark_tab

      original_dark_hex = theme_page.color_palette_editor.get_color_value("primary")
      theme_page.color_palette_editor.change_color("primary", "#000fff")

      theme_page.palette_editor_save_button.click

      page.refresh
      theme_page.color_palette_editor.switch_to_dark_tab

      updated_dark_color = theme_page.color_palette_editor.get_color_value("primary")
      expect(updated_dark_color).to eq("#000fff")
    end

    it "doesn't show color palette editor for component themes" do
      component = Fabricate(:theme, component: true)
      theme_page.visit(component.id)

      expect(theme_page).to have_no_color_palette_editor
      expect(theme_page).to have_no_color_scheme_selector
    end
  end
end
