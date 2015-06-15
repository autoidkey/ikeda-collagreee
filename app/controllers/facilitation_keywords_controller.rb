class FacilitationKeywordsController < InheritedResources::Base

  private

    def facilitation_keyword_params
      params.require(:facilitation_keyword).permit(:theme_id, :word, :score)
    end
end

