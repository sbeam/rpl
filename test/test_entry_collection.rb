require 'test_helper'
require 'entry_collection'


describe EntryCollection do
    before do
      @lines = [
                [""],
                ["<strong>Tuesday, March 31</strong>"],
                ["4:48 p.m. &#x2013; At a Dunkin Donuts bathroom, odd folks pop out and in, two are fat (or heavy set), two skinny (tall and thin.)"],
                ["5:32 p.m. &#x2013; At Walmart, Johnathan Wright, 25, a transient, is charged with five counts of contempt and two counts of theft by deception."],
                ["6:35 p.m. &#x2013; A motorcycle won&#x2019;t stop for an officer on Wakefield Street and vanishes behind the high school."],
                ["6:48 p.m. &#x2013; Tanya M. Breton, 34, of 7 Glenwood Ave., is charged with operating without a valid license."],
                ["9:39 p.m. &#x2013; A teen girl, who lives off Milton Road, was followed earlier by a car with two men inside."],
                ["<strong>Wednesday, April 1</strong>"],
                ["12:26 a.m. &#x2013; An officer&#x2019;s suspicions are aroused near Subway when he spots a running man wearing shorts."],
                ["12:40 a.m. &#x2013; A bunch of kids yell on a lane called Loredo, they could have partying most of the night, a cruiser heads out to the Salmon Falls Road, but when it arrives there is no one in sight."],
                ["1:23 a.m. &#x2013; Criminal mischief is suspected at the fairground grandstands."],
                ["7:44 p.m. &#x2013; Tammy Ewing, 21, of 14 Pineland Park, Milton, is charged with abandoning a vehicle."]
               ]
    end

    it "lets entries be added" do
      collection = EntryCollection.new @lines
      collection.cleaned.length.must_equal 6
    end

    it "pulls out the correct dates" do
      collection = EntryCollection.new @lines
      year = Time.new.year
      collection.cleaned.first.date.to_s.must_equal "#{year}-03-31T16:48:00+00:00"
      collection.cleaned.last.date.to_s.must_equal  "#{year}-04-01T01:23:00+00:00"
    end

    it "eliminates personal entries" do
      collection = EntryCollection.new @lines
      collection.cleaned.select { |e| e.to_s =~ /(Johnathan|Tanya|Tammy)/ }.first.must_be_nil
    end

    it "breaks up entries over 140 chars into tweetstorms with page numbers" do
       long_one = "X"*137 + "Y"*137 + "Z"*50
       @lines << [long_one]
       collection = EntryCollection.new @lines
       collection.cleaned[-1].to_tweets.must_equal [
           "X"*137 + " /1",
           "Y"*137 + " /2",
           "Z"*50 + " /3",
       ]
    end

end

