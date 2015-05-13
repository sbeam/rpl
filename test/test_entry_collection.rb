require 'test_helper'
require 'entry_collection'


describe EntryCollection do
    before do
      @lines = [
                [""],
                ["<strong>Tuesday, March 31</strong>"],
                ["4:48 p.m. &#x2013; At a Dunkin Donuts bathroom, odd folks pop out and in, two are fat (or heavy set), two skinny (tall and thin.)"],
                ["6:35 p.m. &#x2013; A motorcycle won&#x2019;t stop for an officer on Wakefield Street and vanishes behind the high school."],
                ["6:48 p.m. &#x2013; Tanya M. Breton, 34, of 7 Glenwood Ave., is charged with operating without a valid license."],
                ["9:39 p.m. &#x2013; A teen girl, who lives off Milton Road, was followed earlier by a car with two men inside."],
                ["<strong>Wednesday, April 1</strong>"],
                ["12:26 a.m. &#x2013; An officer&#x2019;s suspicions are aroused near Subway when he spots a running man wearing shorts."],
                ["12:40 a.m. &#x2013; A bunch of kids yell on a lane called Loredo, they could have partying most of the night, a cruiser heads out to the Salmon Falls Road, but when it arrives there is no one in sight."],
                ["1:23 a.m. &#x2013; Criminal mischief is suspected at the fairground grandstands."]
               ]
    end

    it "lets entries be added" do
      collection = EntryCollection.new @lines
      collection.cleaned.length.must_equal 6
    end

    it "pulls out the correct dates" do
      collection = EntryCollection.new @lines
      collection.cleaned.first.date.to_s.must_equal '2015-03-31T16:48:00+00:00'
      collection.cleaned.last.date.to_s.must_equal  '2015-04-01T01:23:00+00:00'
    end

    it "eliminates personal entries" do
      collection = EntryCollection.new @lines
      collection.cleaned.select { |e| e.entry =~ /Tanya/ }.first.must_be_nil
    end

end

