module Redpen
  # The notes on one page. Every write redirects back to the index, which is the whole
  # rail: pins, popovers, the composer. One renderer, so a note looks the same whether
  # it arrived with the page or a second ago.
  class NotesController < ApplicationController
    def index
      @notes = notes.ordered
    end

    def create
      notes.create!(note_params)
      redirect_to notes_path(path: path), status: :see_other
    end

    def destroy
      note.destroy
      redirect_to notes_path(path: path), status: :see_other
    end

    private
      def notes
        Note.on(path)
      end

      def note
        @note ||= Note.find(params[:id])
      end

      # The page the gate is asked about is the page this request reads or writes: the
      # query's path for the index, the note's own path for create and destroy. Taking it
      # from anywhere else would let a request pass the gate for one page and land on another.
      def path
        @path ||= case action_name
          when "index"  then params[:path]
          when "create" then note_params[:path]
          else note.path
        end
      end

      def note_params
        params.expect(note: %i[ path selector snippet body ])
      end
  end
end
