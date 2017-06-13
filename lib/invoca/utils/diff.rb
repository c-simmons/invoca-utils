# adapted from http://users.cybercity.dk/~dsl8950/ruby/diff-0.3.tar.gz

module Invoca
  module Utils
    class Diff

      VERSION = 0.3

      def self.lcs(a, b)
        astart = 0
        bstart = 0
        afinish = a.length-1
        bfinish = b.length-1
        lcs = []

        # First we prune off any common elements at the beginning
        while (astart <= afinish && bstart <= afinish && a[astart] == b[bstart])
          lcs[astart] = bstart
          astart += 1
          bstart += 1
        end

        # now the end
        while (astart <= afinish && bstart <= bfinish && a[afinish] == b[bfinish])
          lcs[afinish] = bfinish
          afinish -= 1
          bfinish -= 1
        end

        bmatches = reverse_hash(b, bstart..bfinish)
        thresh = []
        links = []

        (astart..afinish).each { |aindex|
          aelem = a[aindex]
          next unless bmatches.has_key? aelem
          k = nil
          bmatches[aelem].reverse.each { |bindex|
            if k && (thresh[k] > bindex) && (thresh[k-1] < bindex)
              thresh[k] = bindex
            else
              k = replacenextlarger(thresh, bindex, k)
            end
            links[k] = [ (k==0) ? nil : links[k-1], aindex, bindex ] if k
          }
        }

        if !thresh.empty?
          link = links[thresh.length-1]
          while link
            lcs[link[1]] = link[2]
            link = link[0]
          end
        end

        return lcs
      end

      def self.nested_compare( subtractions, additions, index )
        subtraction = subtractions[index]
        addition    = additions[index]
        if subtraction.is_a?( Array ) && addition.is_a?( Array )
          return "Nested array diff:\n#{ compare( subtraction, addition ) }\n"
        elsif subtraction.is_a?( Hash ) && addition.is_a?( Hash )
          return "Nested hash diff:\n#{ compare( subtraction, addition ) }\n"
        else
          ""
        end
      end

      def self.format(value)
        value.is_a?(Numeric) || value.is_a?(String) ? value : value.inspect
      end

      def self.compare arg1, arg2, options={}
        result = ''
        if arg1 != arg2
          if arg1.class == arg2.class || (arg1.is_a?(Hash) && arg2.is_a?(Hash)) || (arg1.is_a?(Array) && arg2.is_a?(Array)) # Hash and Array are equivalent when specialized
            case arg1
            when Array
              diff_obj = Diff.new(arg1, arg2)
              summary = diff_obj.summary
              curr_diff = nil
              (arg1 + [nil]).each_with_index do |arg, index|
                if curr_diff.nil? || index > curr_diff[1].last
                  curr_diff = summary.shift
                end
                unless curr_diff && (curr_diff[1].first..curr_diff[1].last) === index
                  result << "  #{format arg}\n" unless arg.nil? || options[:short_description]
                end
                if curr_diff && curr_diff[1].first == index
                  verb, _a_range, _b_range, del, add = curr_diff
                  result <<
                    case verb
                    when 'd'
                      del.map { |t| "- #{format t}\n"}.join
                    when 'a'
                      add.map { |t| "+ #{format t}\n"}.join +
                      (arg.nil? ? '' : "  #{format arg}\n")
                    when 'c'
                      del.map_with_index { |t, i| "- #{format t}\n#{ nested_compare( del, add, i ) }"}.join +
                      add.map_with_index { |t, i| "+ #{format t}\n"}.join
                    end
                end
              end
              summary.empty? or raise "Summary left: #{summary.inspect}"
            when Hash
              arg1.each do |key, value|
                if arg2.has_key? key
                  result += "[#{key.inspect}] #{compare value, arg2[key]};\n" if value != arg2[key]
                else
                  result += "[#{key.inspect}] expected #{value.inspect}, was missing;\n"
                end
              end
              (arg2.keys - arg1.keys).each do |key|
                result += "[#{key.inspect}] not expected, was #{arg2[key].inspect};\n"
              end
            else
              result = "expected #{arg1.inspect}, was #{arg2.inspect} "
            end
          elsif arg1.class.in?([Float,BigDecimal]) && arg2.class.in?([Float,BigDecimal])
            result = "expected #{arg1.class}: #{arg1.to_s}, was #{arg2.class}: #{arg2.to_s} "
          else
            result = "expected #{arg1.class}:#{arg1.inspect}, was #{arg2.class}:#{arg2.inspect} "
          end
        end
        result
      end


      def makediff(a, b)
        lcs = self.class.lcs(a, b)
        ai = bi = 0
        while ai < lcs.length
          if lcs[ai]
            while bi < lcs[ai]
              discardb(bi, b[bi])
              bi += 1
            end
            match
            bi += 1
          else
            discarda(ai, a[ai])
          end
          ai += 1
        end
        while ai < a.length
          discarda(ai, a[ai])
          ai += 1
        end
        while bi < b.length
          discardb(bi, b[bi])
          bi += 1
        end
        match
      end

      def compact!
        diffs = []
        @diffs.each do |diff|
          puts "compacting #{diff.inspect}"
          i = 0
          curdiff = []
          while i < diff.length
            action = diff[i][0]
            s = @difftype.is_a?(String) ? diff[i][2,1] : [diff[i][2]]
            offset = diff[i][1]
            last = offset
            i += 1
            while diff[i] && diff[i][0] == action && diff[i][1] == last+1
              s << diff[i][2]
              last = diff[i][1]
              i += 1
            end
            curdiff.push [action, offset, s]
          end
          diffs.push curdiff
        end
        @diffs = diffs
        self
      end

      def compact
        result = self.dup
        result.compact!
        result
      end

      def summary
        result = []
        b_offset = 0
        @diffs.each do |block|
          del = []
          add = []
          block.each do |diff|
            case diff[0]
            when "-"
              del << diff[2]
            when "+"
              add << diff[2]
            end
          end
          first = block[0][1]
          verb, a_range, b_range =
            if del.empty?
              [ 'a', [first-b_offset,first-b_offset], [first, first+add.size-1] ]
            elsif add.empty?
              [ 'd', [first, first+del.size-1],       [first+b_offset, first+b_offset] ]
            else
              [ 'c', [first, first+del.size-1],       [first+b_offset, first+b_offset+add.size-1] ]
            end
            b_offset = b_offset + add.size - del.size
          result << [verb, a_range, b_range, del, add]
        end
        result
      end

      attr_reader :diffs, :difftype

      def initialize(a, b)
        @difftype = a.class
        @diffs = []
        @curdiffs = []
        makediff(a, b)
      end

      def match
        @diffs << @curdiffs unless @curdiffs.empty?
        @curdiffs = []
      end

      def discarda(i, elem)
        @curdiffs.push ['-', i, elem]
      end

      def discardb(i, elem)
        @curdiffs.push ['+', i, elem]
      end

      def inspect
        @diffs.inspect
      end

      # Create a hash that maps elements of the array to arrays of indices
      # where the elements are found.

      def self.reverse_hash(lhs, range = nil)
        range ||= (0...lhs.length)
        revmap = {}
        range.each { |i|
          elem = lhs[i]
          if revmap.has_key? elem
            revmap[elem].push i
          else
            revmap[elem] = [i]
          end
        }
        return revmap
      end

      def self.replacenextlarger(lhs, value, high = nil)
        high ||= lhs.length
        if lhs.empty? || value > lhs[-1]
          lhs.push value
          return high
        end
        # binary search for replacement point
        low = 0
        while low < high
          index = (high+low)/2
          found = lhs[index]
          return nil if value == found
          if value > found
            low = index + 1
          else
            high = index
          end
        end

        lhs[low] = value
        # $stderr << "replace #{value} : 0/#{low}/#{init_high} (#{steps} steps) (#{init_high-low} off )\n"
        # $stderr.puts lhs.inspect
        #gets
        #p length - low
        return low
      end

      def self.patch(lhs, diff)
        newary = nil
        if diff.difftype == String
          newary = diff.difftype.new('')
        else
          newary = diff.difftype.new
        end
        ai = 0
        bi = 0
        diff.diffs.each { |d|
          d.each { |mod|
            case mod[0]
            when '-'
              while ai < mod[1]
                newary << lhs[ai]
                ai += 1
                bi += 1
              end
              ai += 1
            when '+'
              while bi < mod[1]
                newary << lhs[ai]
                ai += 1
                bi += 1
              end
              newary << mod[2]
              bi += 1
            else
              raise "Unknown diff action"
            end
          }
        }
        while ai < lhs.length
          newary << lhs[ai]
          ai += 1
          bi += 1
        end
        return newary
      end
    end

    module Diffable
      def diff(b)
        Diff.new(self, b)
      end
    end

    #
    #class Array
    #  include Diffable
    #end
    #
    #class String
    #  include Diffable
    #end

=begin
= Diff
(({diff.rb})) - computes the differences between two arrays or
strings. Copyright (C) 2001 Lars Christensen

== Synopsis

    diff = Diff.new(a, b)
    b = a.patch(diff)

== Class Diff
=== Class Methods
--- Diff.new(a, b)
--- a.diff(b)
      Creates a Diff object which represent the differences between
      ((|a|)) and ((|b|)). ((|a|)) and ((|b|)) can be either be arrays
      of any objects, strings, or object of any class that include
      module ((|Diffable|))

== Module Diffable
The module ((|Diffable|)) is intended to be included in any class for
which differences are to be computed. Diffable is included into String
and Array when (({diff.rb})) is (({require}))'d.

Classes including Diffable should implement (({[]})) to get element at
integer indices, (({<<})) to append elements to the object and
(({ClassName#new})) should accept 0 arguments to create a new empty
object.

=== Instance Methods
--- Diffable#patch(diff)
      Applies the differences from ((|diff|)) to the object ((|obj|))
      and return the result. ((|obj|)) is not changed. ((|obj|)) and
      can be either an array or a string, but must match the object
      from which the ((|diff|)) was created.
=end
  end
end
