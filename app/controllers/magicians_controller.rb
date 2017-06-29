class MagiciansController < ApplicationController
  def index
    @magicians = Magician.all
  end
end
