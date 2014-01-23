json.array!(@trailers) do |trailer|
  json.extract! trailer, :id, :record_id, :added_by, :youtube_url, :release_date, :tile, :artist
  json.url trailer_url(trailer, format: :json)
end
