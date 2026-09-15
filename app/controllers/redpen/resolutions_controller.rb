module Redpen
  # Resolving a note is a noun with a lifecycle, not a verb on the note: create resolves,
  # destroy reopens. A host's agent calls the same model verb.
  class ResolutionsController < ApplicationController
    def create
      note.resolve(params[:resolution])
      redirect_to notes_path(path: path), status: :see_other
    end

    def destroy
      note.reopen
      redirect_to notes_path(path: path), status: :see_other
    end

    private
      def note
        @note ||= Note.find(params[:note_id])
      end

      def path
        note.path
      end
  end
end
