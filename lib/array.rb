Array.instance_eval do
  define_method :sum do
    begin
      total = 0
      each do |val|
        raise Exception unless val.is_a?(Integer)
        total += val
      end
      total
    rescue
      nil
    end
  end unless instance_methods.include?(:sum)
end
