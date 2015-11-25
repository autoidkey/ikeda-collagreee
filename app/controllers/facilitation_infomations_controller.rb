class FacilitationInfomationsController < InheritedResources::Base

	def create
		create! { theme_path @facilitation_infomation.theme_id }
	end

  private

    def facilitation_infomation_params
      params.require(:facilitation_infomation).permit(:body, :theme_id)
    end
end

