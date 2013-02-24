class MainController < ApplicationController
  def index
    @recipes = recipes
  end

  private
  def recipes
    [
      [:malachite, [:chipped_opal, :chipped_emerald, :chipped_aquamarine]],
      [:silver, [:chipped_topaz, :chipped_diamond, :chipped_sapphire]],
      [:star_ruby, [:flawed_ruby, :chipped_ruby, :chipped_amethyst]],
      [:jade, [:flawless_emerald, :opal, :flawed_sapphire]],
      [:black_opal, [:perfect_opal, :flawless_diamond, :aquamarine]],
      [:perfect_opal, [:perfect_opal]],
      [:blood_stone, [:perfect_ruby, :flawless_aquamarine, :amethyst]],
      [:dark_emerald, [:perfect_emerald, :flawless_sapphire, :flawed_topaz]],
      [:gold, [:perfect_amethyst, :flawless_amethyst, :flawed_diamond]],
      [:paraiba_tourmaline, [:perfect_aquamarine, :flawless_opal, :flawed_emerald, :flawed_aquamarine]],
      [:pink_diamond, [:perfect_diamond, :topaz, :diamond]],
      [:red_crystal, [:ruby, :emerald, :flawed_amethyst]],
      [:uranium_238, [:perfect_topaz, :sapphire, :flawed_opal]],
      [:yellow_sapphire, [:perfect_sapphire, :flawless_topaz, :flawless_ruby]]
    ]
  end
end
