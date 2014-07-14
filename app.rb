require 'csv'
require 'sinatra'
require 'securerandom'

enable :sessions
set :session_secret, SecureRandom.hex

get '/' do
  redirect '/index'
end

# shows all the product details
get '/index' do
  session[:headers] = products.headers
  @rows = []
  # iterates over products and assigns index as 'id'
  products.each_with_index do |row, index|
    row[:id] = index
    @rows << row 
  end
  erb :index
end

# view to edit a product
get '/:id/edit' do
  # grabs the row based on the params[:id]
  @row = products[params[:id].to_i]
  erb :edit
end

# view to add new product
get '/new' do 
  erb :new
end

# updates the csv when a product has been edited
post '/:id/update' do
  @rows = products
  # finds row based on params[:id]
  @row = @rows[params[:id].to_i]
  # updates the row with params
  @rows[params[:id].to_i] = update_row(@row)
  # rewrites the csv with new row data
  write_csv(@rows)
  redirect '/index'
end

# adds a new row to the csv
post '/create' do
  @row = []
  CSV.open('data/file.csv', 'ab') do |csv|
    session[:headers].each do |header|
      @row << params[header]
    end
    csv << @row
  end
  redirect '/index'
end

private

def write_csv(rows)
  CSV.open('data/file.csv', 'w') do |csv|
    csv << rows.headers
    rows.each do |row|
      csv << row
    end
  end
end 

def products
  CSV.read('data/file.csv', headers: true, header_converters: :symbol)
end

def update_row(row)
  session[:headers].each do |header|
    row[header] = params[header]
  end
  row
end