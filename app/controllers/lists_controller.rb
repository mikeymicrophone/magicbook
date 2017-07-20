class ListsController < ApplicationController
  def new
    @list = List.new
  end
  
  def create
    @list = List.new list_params
    @list.magician = current_magician
    @list.save
    redirect_to @list
  end
  
  def show
    @list = List.find params[:id]
  end
  
  def index
    @lists = List.all
  end
  
  def list_params
    params.require(:list).permit(:name, :mode, :privacy)
  end
end
