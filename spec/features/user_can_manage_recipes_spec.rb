require 'rails_helper'

RSpec.feature "UserCanManageRecipes", type: :feature do
  let(:user) { create(:user) }

  feature "RecipesController#index" do
    scenario "user can view their recipes and public recipes" do
      login_as(user, scope: :user)

      recipe = create(:recipe, user: user)
      public_recipe = create(:recipe, public: true)
      private_recipe = create(:recipe)

      visit recipes_path

      expect(page).to have_content(recipe.title)
      expect(page).to have_content(public_recipe.title)
      expect(page).not_to have_content(private_recipe.title)
    end
  end

  feature "RecipesController#show" do
    scenario "user can view their own recipes" do
      recipe = create(:recipe, user: user)

      login_as(user, scope: :user)
      visit recipe_path(recipe)

      expect(page).to have_content(recipe.title)
      expect(page).to have_content("Edit Recipe")
      expect(page).to have_content("Destroy Recipe")
    end

    scenario "user can view, but can't manage public recipes" do
      recipe = create(:recipe, public: true)

      login_as(user, scope: :user)
      visit recipe_path(recipe)

      expect(page).to have_content(recipe.title)
      expect(page).not_to have_content("Edit Recipe")
      expect(page).not_to have_content("Destroy Recipe")
    end
  end

  feature "RecipesController#new" do
    scenario "Users can create recipes by searching for foods", :vcr do
      login_as(user, scrope: :user)

      visit new_recipe_path

      fill_in "Recipe Name", with: "New Recipe"
      fill_in "Search", with: "1 Apple"
      click_button "Search"

      expect(page).to have_content("New Recipe")
      expect(page).to have_content("Apple - 1.0 - Medium")

      expect{
        click_button "Create Recipe"
      }.to change { Recipe.count }.by(1)
    end

    scenario "Users can create recipes with existing foods", :vcr, js: true do
      login_as(user, scope: :user)
      food = create(:api_food)

      visit new_recipe_path

      fill_in "Recipe Name", with: "New Recipe"

      click_button "Add Ingredient"
      select food.unique_name, from: "Food"

      expect{
        click_button "Create Recipe"
      }.to change { Recipe.count }.by(1)
    end

    scenario "blank search field will shows proper errors to user", :vcr do
      login_as(user, scrope: :user)

      visit new_recipe_path

      fill_in "Recipe Name", with: "New Recipe"
      fill_in "Search", with: ""
      click_button "Search"

      expect(page).to have_content("New Recipe")
      expect(page).to have_content("Please provide a search term")
    end

    scenario "search with no results shows proper errors to user", :vcr do
      login_as(user, scrope: :user)

      visit new_recipe_path

      fill_in "Recipe Name", with: "New Recipe"
      fill_in "Search", with: "hammer"
      click_button "Search"

      expect(page).to have_content("New Recipe")
      expect(page).to have_content("We couldn't match any of your foods")
    end

    scenario "with an invalid recipe entry" do
      login_as(user, scrope: :user)

      visit new_recipe_path

      click_button "Create Recipe"

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Ingredients can't be blank")
    end
  end

  feature "RecipesController#edit" do
    scenario "users can edit existing recipes" do
      login_as(user, scope: :user)
      recipe = create(:recipe, user: user)

      visit edit_recipe_path(recipe)

      fill_in "Recipe Name", with: "Updated Name"

      click_button "Update Recipe"

      expect(page).to have_content("Updated Name")
    end

    scenario "users can remove ingredients from recipes", :vcr, js: true do
      login_as(user, scope: :user)
      recipe = create(:recipe, user: user)

      visit edit_recipe_path(recipe)

      click_button "Remove Ingredient", match: :first

      expect{
        click_button "Update Recipe"
      }.to change { recipe.foods.count }.by(-1)
    end

    scenario "users can search recipe foods", :vcr, js: true do
      login_as(user, scrope: user)
      recipe = create(:recipe, user: user)

      visit edit_recipe_path(recipe)

      fill_in "Search", with: "1 Banana"

      expect {
        click_button "Search"
      }.to change { recipe.foods.count }.by(1)
    end
  end

  feature "RecipesController#destroy" do
    scenario "users can destroy their recipes" do
      login_as(user, scope: :user)
      recipe = create(:recipe, user: user)

      visit recipe_path(recipe)

      expect {
      click_link "Destroy Recipe"
      }.to change { Recipe.count }.by(-1)

      expect(page).to have_current_path(recipes_path)
    end
  end
end
