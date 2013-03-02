require 'spec_helper'

describe "Available gems", js: true do
  it "let's me add an available gem to the list of 5" do
    visit root_path
    within(".js-gem-selector") do
      click_button "Flawless"
      click_button "Amethyst"
      click_button "Add"

      within(".js-suggestions") do
        page.should have_content("Flawless Amethyst")
      end
    end
  end
end
