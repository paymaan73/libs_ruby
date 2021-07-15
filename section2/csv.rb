# frozen_stirng_literal: true

require 'minitest/autorun'
require 'pry-byebug'
require 'csv'

class Product
  attr_reader :id, :name, :price, :category
  attr_writer :id

  def initialize name, price, category, id = nil
    @id               = id
    @name             = name
    @price            = price
    @category         = category
  end
  
  def to_a
    [ @id, @name, @price, @category ]
  end
end

class ProductRepository
  FILE = "/tmp/products.csv"

  class << self

    def file_location; FILE; end

    def all
      csv = CSV.read(file_location, col_sep: "|")
      csv.to_a.map { |row| Product.new(*row) }
    end


    def find id
      csv = CSV.read(file_location, col_sep: "|")
      record = csv.to_a.find { |row| row[0].to_i == id.to_i } 
      record ? Product.new(*record) : nil
    end

    def create product
      CSV.open file_location, "a+", col_sep: "|" do |csv|
        product.id = csv.count + 1
        csv << product.to_a
      end
    end
  end
end

class ProductRepositoryTest < MiniTest::Test
  def setup
    FileUtils.rm ProductRepository::FILE rescue nil
    ProductRepository.create Product.new("Microphone", 200, "Audio")
    ProductRepository.create Product.new("Book", 120, "Books")
  end

  def test_retriveves_a_list_of_products
    assert_kind_of Product, ProductRepository.all.first
  end

  def test_creatas_based_off_a_product
    assert_equal 2, ProductRepository.all.length
  end

  def test_finds_a_record_by_key
    assert_kind_of Product, ProductRepository.find(1) 
  end
end


