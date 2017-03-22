class RecipesController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized, except: [:index, :new, :create]
  after_action :verify_policy_scoped, only: :index

  def index
    @recipes = policy_scope(Recipe)
  end

  def show
    @recipe = Recipe.includes(ingredients: :food).find(params[:id])
    authorize @recipe
  end

  def new
    @recipe = Recipe.new
    @foods_for_select = policy_scope(Food)
  end

  def create
    @recipe = Recipe.new(recipe_params)

    if params[:commit] == 'Search'
      api = NutritionIx.new(params[:recipe][:search])

      @recipe.foods << Food.find_or_create_from_api(api.foods)
      @foods_for_select = policy_scope(Food)

      flash.now[:alert] = api.messages if api.errors?
      flash[:notice] = t '.search.success' unless api.errors?
      render :new

    elsif params[:commit] == 'Create Recipe'
      @recipe.save

      if @recipe.invalid?
        @foods_for_select = policy_scope(Food)
        render :new
        return
      end

      redirect_to recipe_path(@recipe)
    end
  end

  def edit
    @recipe = Recipe.includes(:ingredients).find(params[:id])
    authorize @recipe

    @foods_for_select = policy_scope(Food)
  end

  def update
    @recipe = Recipe.includes(ingredients: [:food]).find(params[:id])
    authorize @recipe

    @recipe.update(recipe_params)

    if params[:commit] == 'Search'
      api = NutritionIx.new(params[:recipe][:search])

      @recipe.foods << Food.find_or_create_from_api(api.foods)
      @foods_for_select = policy_scope(Food)

      flash.now[:alert] = api.messages if api.errors?
      flash[:notice] = t '.search.success' unless api.errors?
      render :edit

    elsif params[:commit] == 'Update Recipe'
      if @recipe.invalid?
        @foods_for_select = policy_scope(Food)
        render :edit
        return
      end

      redirect_to recipe_path(@recipe)
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    authorize @recipe

    if @recipe.destroy
      redirect_to recipes_path, notice: "#{@recipe.title} was deleted."
    else
      redirect_to recipe_path(@recipe),
                  alert: "#{@recipe.title} could not be deleted."
    end
  end

  private

  def recipe_params
    filter_empty_attributes(params[:recipe][:ingredients_attributes], :food_id)

    params.require(:recipe).permit(
      :name,
      :public,
      :serving_size,
      :user_id,
      ingredients_attributes: [
        :id,
        :quantity,
        :food_id,
        :_destroy
      ],
      foods_attributes: [
        :food_name,
        :serving_qty,
        :serving_unit,
        :calories,
        :total_fat,
        :total_carbohydrate,
        :protein
      ]
    ).merge(user_id: current_user.id)
  end

  def filter_empty_attributes(attributes_to_filter, attribute_to_test)
    return unless attributes_to_filter

    attributes_to_filter.delete_if do |_key, value|
      value[attribute_to_test].empty?
    end
  end
end
