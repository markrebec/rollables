module Rollables
  class DieFace
    attr_reader :face

    def self.new(face)
      super
    end

    def to_s
      @face.to_s
    end

    protected

    def initialize(face)
      @face = (face.is_a?(String) && face.to_i.to_s == face) ? face.to_i : face
    end
  end
end
