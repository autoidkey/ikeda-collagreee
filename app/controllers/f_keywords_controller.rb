class FKeywordsController < InheritedResources::Base

  private

    def f_keyword_params
      params.require(:f_keyword).permit(:word, :score)
    end
end

