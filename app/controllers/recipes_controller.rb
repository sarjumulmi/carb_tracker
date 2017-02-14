class RecipesController < ApplicationController
  def index
    @recipes = Recipe.includes(:foods).all
  end

  def show
    @recipe = Recipe.includes(:foods).find(params[:id])
  end

  def new
    @recipe = Recipe.new
    @search_foods = []
  end

  def create
    @recipe = Recipe.new(recipe_params)

    if params[:commit] == "Search"
      klass, @search_foods = Food.search_form(params[:recipe][:search])

      if klass.errors?
        flash[:error] = klass.errors
      else
        @recipe.foods << @search_foods
        flash[:success] = "Your food search was successful!  Please choose the foods to include with this recipe."
      end

      render :new
    elsif params[:commit] == "Create Recipe"
      @recipe = Recipe.create(recipe_params)

      redirect_to recipe_path(@recipe)
    end
  end

  private
  def recipe_params
    params.require(:recipe).permit(:name, :public, food_ids: [])
  end
end
