class Hash
  def to_logstash
    hash = { '@fields' => self }
    hash['@tags'] = self[:tags] || []
    hash
  end
end

class Exception
  def to_logstash
    hash = {
      '@fields' => {
        'error' => self.message,
        'backtrace' => self.backtrace
      },
      '@tags' => ['error']
    }
    hash
  end
end

class Object
  def to_logstash
    { '@message' => self.inspect }
  end
end
