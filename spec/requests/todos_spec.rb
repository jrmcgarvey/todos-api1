# spec/requests/todos_spec.rb
require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Todos API', type: :request do
  # initialize test data
  let!(:todos) { create_list(:todo, 10) }
  let(:todo_id) { todos.first.id }

  # Test suite for GET /todos
  describe 'GET /todos' do
    # make HTTP get request before each example
    before { get '/todos' }

    it 'returns todos' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /todos/:id
  describe 'GET /todos/:id' do
    before { get "/todos/#{todo_id}" }

    context 'when the record exists' do
      it 'returns the todo' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(todo_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:todo_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Todo/)
      end
    end
  end

  # Test suite for POST /todos
  describe 'POST /todos' do
    # valid payload
    let(:valid_attributes) { { title: 'Learn Elm', created_by: '1' } }

    context 'when the request is valid' do
      before { post '/todos', params: valid_attributes }

      it 'creates a todo' do
        expect(json['title']).to eq('Learn Elm')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/todos', params: { title: 'Foobar' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Created by can't be blank/)
      end
    end
  end

  # Test suite for PUT /todos/:id
  describe 'PUT /todos/:id' do
    let(:valid_attributes) { { title: 'Shopping' } }

    context 'when the record exists' do
      before { put "/todos/#{todo_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  # Test suite for DELETE /todos/:id
  describe 'DELETE /todos/:id' do
    before { delete "/todos/#{todo_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end

  path '/todos' do
    get('list todos') do
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end
        run_test!
      end
    end
    post('create todo') do
      #requestBody {
      #  content {
          # 'application/json' => {
          #   schema: {
          #     type: :object,
          #     properties: {
          #       title: { type: :string},
          #       created_by: { type: :string}
          #     }
          #   }
          # }
      #  }
      #}
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'title', type: :string, in: :todo
      parameter name: 'created_by', type: :string, in: :todo
      # parameter name: "todo[title]", type: :string, in: :formData, required: true
      # parameter name: "todo[created_by]", type: :string, in: :formData, required: true
      parameter name: :todo, in: :body, required: true, schema: {
        # '$ref' => '#/definitions/createTodo'
        type: :object,
        required: %i[title created_by],
        properties: {
          title: { type: :string },
          created_by: { type: :string }
        }
      }
      # parameter name: :blog, in: :body, schema: {
      #   type: :object,
      #   properties: {
      #     title: { type: :string },
      #     content: { type: :string }
      #   },
      #   required: [ 'title', 'content' ]
      # }
      response(201, 'successful') do
        let(:todo) { { title: 'Learn Elm', created_by: '1' } }
        # after do |example|
        #   example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        # end
        run_test!
      end
    end
  end

  path '/todos/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :integer, description: 'id'

    get('show todo') do
      response(200, 'successful') do
        let(:id) { 5 }
        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end
        run_test!
      end
    end

    put('update todo') do
      parameter name: :todo, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string }
        },
        required: ['title','content']
      }
    end

    delete('delete todo') do
    end
  end
end
