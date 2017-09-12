class MomentRepository < Hanami::Repository
  relations :people

  associations do
    belongs_to :person
    has_many :locations
  end

  def all_with_influencers
    aggregate(:person)
      .map_to(Moment)
      .call.collection
  end

  def find_with_locations(id)
    aggregate(:locations)
      .where(moments__id: id)
      .map_to(Moment)
      .one
  end

  def add_location(moment, data)
    assoc(:locations, moment).add(data)
  end

  def search_by_date(params)
    conditional = Sequel.lit('year_begin <= ? AND (year_end >= ? OR year_end IS NULL)',
                             params[:year], params[:year])

    aggregate(:locations, :person)
      .where(conditional)
      .map_to(Moment)
      .call.collection
  end

  def all_available_years
    return [] if moments.count == 0

    min_year = moments.min(:year_begin)
    max_year = if all_still_ocurring.count > 0
                 Time.now.year
               else
                 moments.max(:year_end)
               end
    (min_year..max_year).to_a
  end

  def search_by_influencer(influencer)
    aggregate(:person, :locations)
      .where("#{influencer.type}_id": influencer.id)
      .map_to(Moment)
      .call.collection
  end

  private

  def all_still_ocurring
    moments.where(year_end: nil)
  end
end
