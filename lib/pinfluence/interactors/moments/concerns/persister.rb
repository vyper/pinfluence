module Moments
  module Concerns
    module Persister
      attr_reader :moment_params, :locations_params, :influencer_params, :repository, :person_repository,
                  :errors, :location_service, :opts

      def check_locations!
        locations_params.map do |location_param|
          location_info = location_service.by_address(location_param[:address])

          if location_info.latlng
            location_param[:latlng] = location_info.latlng
          else
            errors.push("'#{location_param[:address]}' address not found")
          end
        end
      end

      def persist_locations(moment)
        Moments::PersistLocations.call(moment: moment, locations: locations_params, opts: opts)
      end

      def update_influencer_earliest_moment(influencer)
        Influencers::UpdateEarliestMoment.call influencer: influencer, opts: opts
      end

      def find_influencer
        return if influencer_params[:id].to_s.empty?
        Influencers::Find.call(id: influencer_params[:id], type: influencer_params[:type])
      end

      def create_influencer
        Influencers::PersistInfluencer.call(
          influencer: influencer_params,
          opts: opts
        )
      end

      def normalized_year_end
        moment_params[:year_end].to_s.empty? ? nil : moment_params[:year_end]
      end
    end
  end
end
