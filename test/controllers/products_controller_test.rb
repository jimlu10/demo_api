require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
    @category = categories(:one)
    @product.update!(category: @category)
  end

  test "should get index" do
    get products_url, as: :json
    assert_response :success
    product = response.parsed_body.find { |item| item["id"] == @product.id }
    assert_not product.key?("category_id")
    assert_equal({ "id" => @category.id, "name" => @category.name }, product["category"])
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { name: @product.name, price: @product.price, stock: @product.stock, category_id: @category.id } }, as: :json
    end

    assert_response :created
    assert_equal Product.order(:id).last.id, response.parsed_body["id"]
    assert_not response.parsed_body.key?("category_id")
    assert_equal({ "id" => @category.id, "name" => @category.name }, response.parsed_body["category"])
  end

  test "should show product" do
    get product_url(@product), as: :json
    assert_response :success
    assert_not response.parsed_body.key?("category_id")
    assert_equal @product.id, response.parsed_body["id"]
    assert_equal({ "id" => @category.id, "name" => @category.name }, response.parsed_body["category"])
  end

  test "should update product" do
    category = categories(:two)
    patch product_url(@product), params: { product: { name: @product.name, price: @product.price, stock: @product.stock, category_id: category.id } }, as: :json
    assert_response :success
    assert_equal @product.id, response.parsed_body["id"]
    assert_equal category.id, @product.reload.category_id
    assert_not response.parsed_body.key?("category_id")
    assert_equal({ "id" => category.id, "name" => category.name }, response.parsed_body["category"])
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product), as: :json
    end

    assert_response :no_content
    assert_empty response.body
  end
end
