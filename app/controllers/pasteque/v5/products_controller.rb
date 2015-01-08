class Pasteque::V5::ProductsController < Pasteque::V5::BaseController
  manage_restfully only: [:index, :show], model: :product_nature_variant, scope: :saleables, partial_path: 'products/product', record: :product
end