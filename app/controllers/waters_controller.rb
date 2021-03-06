class WatersController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_water, only: [:edit, :show, :update, :destroy]

  def show
    authorize @water
  end

  def new
    authorize @water = Water.new
    @tenant = Tenant.find(params[:tenant_id])
  end

  def create
    authorize @water = Water.new(water_params)
    @tenant = Tenant.find(params[:tenant_id])
    @water.tenant = @tenant
    @water.user_id = current_user.id
    @water.statut = "active"
    if @water.save
      associe = @water.tenant.apartment.building.company.associe.downcase.split(",").map(&:strip)
      if associe.include?(current_user.email) || @water.tenant.apartment.building.company.user == current_user || @water.tenant.apartment.user == current_user || current_user.admin == true
        redirect_to apartment_tenants_path(@water.tenant.apartment)
      else
        redirect_to tenant_path(@water.tenant)
      end
    else
      render :new
    end
  end

  def edit
    authorize @water
  end

  def update
    authorize @water
    if @water.update(water_params)
      associe = @water.tenant.apartment.building.company.associe.downcase.split(",").map(&:strip)
      if associe.include?(current_user.email) || @water.tenant.apartment.building.company.user == current_user || @water.tenant.apartment.user == current_user || current_user.admin == true
        redirect_to apartment_tenants_path(@water.tenant.apartment)
      else
        redirect_to tenant_path(@water.tenant)
      end
      # redirect_to apartment_tenants_path(@water.tenant.apartment)
    else
      render :edit
    end
  end

  def destroy
    authorize @water
    @water.statut = "deleted"
    @water.save
    associe = @water.tenant.apartment.building.company.associe.downcase.split(",").map(&:strip)
    if associe.include?(current_user.email) || @water.tenant.apartment.building.company.user == current_user || @water.tenant.apartment.user == current_user || current_user.admin == true
      redirect_to apartment_tenants_path(@water.tenant.apartment)
    else
      redirect_to tenant_path(@water.tenant)
    end
  end

  private

  def water_params
    params.require(:water).permit(
      :submission_date,
      :quantity,
      :photo
    )
  end

  def set_water
    @water = Water.find(params[:id])
  end
end
