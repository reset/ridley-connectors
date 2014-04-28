class WaitWritableError < StandardError
  include ::IO::WaitWritable
end
