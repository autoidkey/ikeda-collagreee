class FacilitationInfomationsController < InheritedResources::Base

  private

    def facilitation_infomation_params
      params.require(:facilitation_infomation).permit(:body, :theme_id)
    end
end

