class Spaces::FavoritesController < Spaces::BaseController
  def create
    Current.user.favorites.find_or_create_by!(space: @space)
    respond_with_streams
  end

  def destroy
    Current.user.favorites.where(space: @space).destroy_all
    respond_with_streams
  end

  private
    def respond_with_streams
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("favorite-#{@space.id}", partial: "spaces/favorite_button", locals: { space: @space }),
            turbo_stream.replace("sidebar-favorites",     partial: "shared/sidebar_favorites")
          ]
        end
        format.html { redirect_back fallback_location: spaces_path }
      end
    end
end
