class BookmarksController < ApplicationController
  def index
    @bookmarks = Current.user.bookmarks
                            .includes(entry: [ :space, :author, :entryable, { latest_comment: :user } ])
                            .order(created_at: :desc)
  end
end
