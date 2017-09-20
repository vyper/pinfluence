var searchingInfluencers = false,
    apiUrl = $("#map-container").data("api-endpoint"),
    graph = graphql(apiUrl, {
      method: "POST",
      headers: {},
      fragments: {
        error: "on Error { messages }"
      }
    });

function requestYears(cb){
  graph.query(`query { available_years { year, formatted } }`)()
    .then(function(response){
      cb(response.available_years)
    });
}

function requestMoments(year, cb){
  graph.query(`query { moments(year: `+year+`) { influencer { id name gender } locations { latlng } year_begin } }`)()
    .then(function(response){
      cb(response.moments)
    });
}

function requestYearByInfluenceName(name, cb){
  graph.query(`query { moments(influencer_name: "`+name+`", limit: 1) { influencer { id name gender } locations { latlng } year_begin } }`)()
    .then(function(response){
      cb(response.moments)
    });
}

function requestInfluencers(term, cb){
  if(searchingInfluencers) { return; }

  searchingInfluencers = true;
  graph.query(`query { influencers(name: "`+term+`") { id name gender kind earliest_year_in } }`)()
    .then(function(response){
      searchingInfluencers = false;
      return cb(response.influencers)
    });
}
