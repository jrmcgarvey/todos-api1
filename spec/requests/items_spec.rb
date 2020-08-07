# spec/requests/items_spec.rb
require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Items API' do
  # Initialize the test data
  let!(:todo) { create(:todo) }
  let!(:items) { create_list(:item, 20, todo_id: todo.id) }
  let(:todo_id) { todo.id }
  let(:id) { items.first.id }

  # Test suite for GET /todos/:todo_id/items
  describe 'GET /todos/:todo_id/items' do
    before { get "/todos/#{todo_id}/items" }

    context 'when todo exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all todo items' do
        expect(json.size).to eq(20)
      end
    end

    context 'when todo does not exist' do
      let(:todo_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Todo/)
      end
    end
  end

  # Test suite for GET /todos/:todo_id/items/:id
  describe 'GET /todos/:todo_id/items/:id' do
    before { get "/todos/#{todo_id}/items/#{id}" }

    context 'when todo item exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the item' do
        expect(json['id']).to eq(id)
      end
    end

    context 'when todo item does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Item/)
      end
    end
  end

  # Test suite for PUT /todos/:todo_id/items
  describe 'POST /todos/:todo_id/items' do
    let(:valid_attributes) { { name: 'Visit Narnia', done: false } }

    context 'when request attributes are valid' do
      before { post "/todos/#{todo_id}/items", params: valid_attributes }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when an invalid request' do
      before { post "/todos/#{todo_id}/items", params: {} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to match(/Validation failed: Name can't be blank/)
      end
    end
  end

  # Test suite for PUT /todos/:todo_id/items/:id
  describe 'PUT /todos/:todo_id/items/:id' do
    let(:valid_attributes) { { name: 'Mozart' } }

    before { put "/todos/#{todo_id}/items/#{id}", params: valid_attributes }

    context 'when item exists' do
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'updates the item' do
        updated_item = Item.find(id)
        expect(updated_item.name).to match(/Mozart/)
      end
    end

    context 'when the item does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Item/)
      end
    end
  end

  # Test suite for DELETE /todos/:id
  describe 'DELETE /todos/:id' do
    before { delete "/todos/#{todo_id}/items/#{id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end

  path '/todos/{todo_id}/items' do

    parameter name: 'todo_id', in: :path, type: :integer, description: 'todo_id'

    get('list items') do
      tags 'Items'
      response(200, 'success') do
        run_test!
      end
    end

    post('create item') do
      tags 'Items'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :item, in: :body, required: true, schema: {
        type: :object,
        required: %i[name],
        properties: {
          name: {type: :string},
          done: {type: :boolean}
        }
      }
      response(201, 'success') do
        let(:item) { { name: 'thisitem', done: false } }
        run_test!
      end
    end
  end

  path '/todos/{todo_id}/items/{id}' do
    parameter name: 'todo_id', in: :path, type: :integer, description: 'todo_id'
    parameter name: 'id', in: :path, type: :integer, description: 'id'

    get('show item') do
      tags 'Items'
      response(200,'success') do
        run_test!
      end
    end

    put('update item') do
      tags 'Items'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :item, in: :body, required: true, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          done: {type: :boolean}
        }
      }
      response(204,'success') do
        let(:item) { { name: 'changedName'} }
        run_test!
      end
    end

    delete('delete item') do
      tags 'Items'
      response(204,'success') do
        run_test!
      end
    end

  end
end
