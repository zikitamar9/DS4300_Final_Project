# DS4300_Final_Project
Final_Project for DS4300

To install the bloomfilter library, run the following command in your terminal:
gem install bloomfilter-rb

__________________________________________________________________________________________

The purpose of this program is to show the trending hashtags on twitter in real time.


To run our program, execute the Main.rb from a command line window file and the (optionally bloomstats.rb in a different window). If you would like to see a dynamic histogram representing the distribution of hashtags then do the following:

- go to the "processing" folder
- click on the folder with your operating system specs (does not support mac)
- run the viz11.exe file 
- wait about a minute or two for the bloom filter to start showing trends, it should look like this:

<img width="562" alt="Screen Shot 2021-04-18 at 6 22 39 PM" src="https://user-images.githubusercontent.com/35809264/115162768-51439980-a073-11eb-96d7-e38bae7caa68.png">
__________________________________________________________________________________________

Our program is designed as follows, with four main classes:

TweetGenerator:

- this class is to connect to the API and publish all hashtags to a Redis stream. We do this 			by using the .sample method from our Twitter client. Our twitter API token is passed in by default, but a user can change to their own key if they so choose. The .sample method (per the API docs) Returns a small random sample of all public statuses. As we read through a random tweet, we match it with a regex (regular expression) pattern to filter out any non latin characters, such as (こんにちは, مرحبا). We then publish the hashtags to a redis channel that our bloom filter listens on.


Filter
- This is a base class method that contains the metrics of our bloom filters


Counting Redis
- This inherits from filter class to count the number of occurrences


TrendingFilter
- Takes in a counting redis instance to update the bloom filter


SecondOrderFilter
- This contains metadata for the bloom filter - counting how long a key has been set.





