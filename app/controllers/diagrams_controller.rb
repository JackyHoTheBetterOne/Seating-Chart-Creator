class DiagramsController < ApplicationController
  def index
    @diagrams = Diagram.all
  end

  def going_down_for_real
    @diagram = Diagram.new(name: params[:name], makeup: params[:makeup])
    @diagram.save
    render text: "Fuck yeah?"
  end
end
