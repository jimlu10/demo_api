class ProductsController < ApplicationController
  # Common HTTP status codes in Rails:
  #
  # 200 :ok
  # 400 :bad_request
  # 404 :not_found
  # 500 :internal_server_error

  # Callbacks
  before_action :set_product, only: %i[ show update destroy ]


  # GET /products
  def index
    @products = Product.includes(:category).all

    render json: @products, except: :category_id, include: { category: { only: %i[ id name ] } }
  end

  # GET /products/1
  def show
    render json: @product, except: :category_id, include: { category: { only: %i[ id name ] } }
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, except: :category_id, include: { category: { only: %i[ id name ] } }, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: @product, except: :category_id, include: { category: { only: %i[ id name ] } }
    else
      render json: @product.errors, status: :unprocessable_content
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.expect(product: [ :name, :price, :stock, :category_id ])
    end
end
