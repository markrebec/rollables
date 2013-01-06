module Rollables
  class DieFace
    def self.new(face)
      face = face.to_i if face.is_a?(String) && face.to_i.to_s == face

      face.instance_eval do
        # shared methods go here
        if self.is_a?(Integer)
          # integer methods go here
        elsif self.is_a?(String)
          # string methods go here
        #elsif self.is_a?(Symbol)
          # symbol methods go here
        else
          raise "Unsupported DieFace type `#{face.class.name}`"
        end
      end
      
      face
    end
  end
end
