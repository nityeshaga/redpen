class User < ApplicationRecord
  has_many :redpen_notes, class_name: "Redpen::Note", as: :author, dependent: :destroy
end
