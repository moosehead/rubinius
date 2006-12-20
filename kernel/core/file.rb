class File < IO
  class FileError < Exception; end
  class NoFileError < FileError; end
  class UnableToStat < FileError; end
  class PermissionError < FileError; end
  
  def self.new(path, mode)
    return open_with_mode(path, mode)
  end
  
  def self.open_with_mode(path, mode)
    Ruby.primitive :io_open
  end
  
  def self.raw_stat(path)
    Ruby.primitive :stat_file
  end
  
  def self.exists?(path)
    out = raw_stat(path)
    if Tuple === out
      return true
    else
      return false
    end
  end
  
  def self.file?(path)
    stat(path).kind == :file
  end
  
  def self.directory?(path)
    stat(path).kind == :dir
  end
  
  def self.link?(path)
    stat(path).kind == :link
  end

  # TODO - needs work for Win32
  def self.dirname(path)
    raise TypeError.new("can't convert nil into a pathname") if path.nil?

    slash = -1
    nonslash = 0
    before_slash = 0
    0.upto(path.length-1) do |i|
      if path[i].chr == "/" 
        slash = i
        before_slash = nonslash + 1
      else
        nonslash = i
      end
    end
    return "/" if slash > 0  and nonslash == 0
    return "." if slash == -1
    return path.slice(0, before_slash)
  end
  
  class Stat
    
    define_fields :inode, :mode, :kind, :owner, :group, :size, :block, :path
        
    def self.from_tuple(tup, path)
      obj = allocate
      obj.copy_from tup, 0
      obj.put 7, path
      return obj
    end
    
    
    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} path=#{self.path} kind=#{self.kind}>"
    end
  end
  
  def self.stat(path)
    out = raw_stat(path)
    if !out
      raise UnableToStat.new("Unable to perform stat on '#{path}'")
    elsif out == 1
      raise NoFileError.new("'#{path}' does not exist")
    elsif out == 2
      raise PermissionError.new("Unable to access '#{path}'")
    else
      return Stat.from_tuple(out, path)
    end
  end
  
  def self.to_sexp(path, newlines)
    Ruby.primitive :file_to_sexp
  end
end
