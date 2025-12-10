require 'rails_helper'
require 'spec_helper' # <-- ensure this is here for WebMock

if RUBY_VERSION >= '2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  else
    puts "Monkeypatch for ActionController::TestResponse no longer needed"
  end
end

describe MoviesController do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with('hardware')
        .and_return(@fake_results)
      get :search_tmdb, { search_terms: 'hardware' }
    end

    ### 🔥 NEW REQUIRED TEST — Missing Title 🔥
    it 'redirects to search page with error if title is missing' do
      get :search_tmdb, { title: "", release_year: "2000", language: "en" }
      expect(flash[:warning]).to eq("Please fill in all required fields!")
      expect(response).to redirect_to(search_tmdb_path)
    end

    ### 🔥 NEW REQUIRED TEST — No Results 🔥
    it 'shows warning if no results are returned' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])
      get :search_tmdb, { title: "NoMovie", release_year: "2000", language: "en" }
      expect(flash[:warning]).to eq("No movies found with given parameters!")
      expect(response).to redirect_to(search_tmdb_path)
    end

    ### -------------------------
    ### Existing tests continue
    ### -------------------------
    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, { search_terms: 'hardware' }
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end
  end
end
