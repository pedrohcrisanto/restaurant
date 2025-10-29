# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity

  private

  def render_not_found(exception)
    render json: { error: { message: exception.message } }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    render json: { error: { message: exception.message } }, status: :unprocessable_entity
  end
end
