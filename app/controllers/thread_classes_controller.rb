class ThreadClassesController < InheritedResources::Base

  private

    def thread_class_params
      params.require(:thread_class).permit(:title, :parent_class)
    end
end

