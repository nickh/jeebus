require 'rubygems'
require 'benchmark'
require 'ruby-prof'

def with_inject(s)
  segments = s.split('.').reverse
  segments.inject([segments.shift.to_sym]){|a,s| a.unshift "#{s}.#{a.first}".to_sym}
end

def with_block(s)
  a = s.split('.')
  1.upto(a.size).inject([]) {|s,t| s << a.slice(a.size-t,t).join('.').to_sym}.reverse
end

def with_substr(s)
  a = [s.to_sym]
  i = 0
  loop do
    break unless i = s.index('.',i)
    i += 1
    a << s[i..-1].to_sym
  end
  a
end

test_string = 'messages.index.filter.label'
test_methods = [:with_inject, :with_block, :with_substr]
count = 100000

test_methods.each do |method|
  result = RubyProf.profile do
    send(method, test_string)
  end
  RubyProf::GraphPrinter.new(result).print(STDOUT, 0)
end

Benchmark.bm do |b|
  test_methods.each do |method|
    b.report(method.to_s) do
      count.times do
        send(method, test_string)
      end
    end
  end
end
