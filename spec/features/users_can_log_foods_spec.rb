require 'rails_helper'

RSpec.feature "UsersCanLogFoods", type: :feature do
  feature "user can add a food log" do
    scenario "when signed in" do
      user = create(:user)
      recipe = create(:recipe)
      food = create(:food)
      recipe.foods << food
      recipe.save

      login_as(user, :scope => :user)

      visit new_log_path

      expect(page).to have_current_path(new_log_path)

      select "apple", from: "Recipe"
      fill_in "Quantity", with: "1"
      select "snack", from: "Category"

      click_button "Create Log"

      expect(page).to have_current_path(user_path(user))
      expect(page).to have_content("apple")
      expect(page).to have_content("snack")
      # expect(page).to have_content(Date.now)
    end

    scenario "when not signed in" do
      visit new_food_log_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end

