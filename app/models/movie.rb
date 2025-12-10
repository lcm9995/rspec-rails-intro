class Movie < ActiveRecord::Base
  TMDB_API_BASE = "https://api.themoviedb.org/3/search/movie"
  API_KEY = "YOUR_API_KEY_HERE"
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
  def self.find_in_tmdb(search_terms, api_key="YOUR_API_KEY")
    params = input.is_a?(Hash) ? input : { title: input }

    title = params[:title]
    year = params[:release_year]
    language = params[:language]

    raise ArgumentError, "Please fill in all required fields!" if title.blank?

    query = URI.encode(title)
    url = "#{TMDB_API_BASE}?api_key=#{api_key}&query=#{query}"
    url += "&year=#{year}" unless year.blank?
    url += "&language=#{language}" if language && language != 'all'

    response = Faraday.get(url)
    parsed = JSON.parse(response.body)

    results = parsed["results"] || []
    return [] if results.empty?

    results.map do |movie|
      {
        id: movie["id"],
        title: movie["title"],
        release_date: movie["release_date"],
        overview: movie["overview"],
        rating: "R"
      }
    end
  end
  
end
