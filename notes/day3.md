## Block 6: Reflection (45 min)

1. Which slicer, once built, turned out to be more useful for exploring the data than expected — and was there one that turned out not to add much?

    The State slicer turned out more useful than expected it reveals where our weak points sit in the overall distribution, not just totals. The date slicer was helpful too, but with only 1 years and Q3 of data (2017 plus three quarters of 2018).
    It adds less exploratory value than it would with a fuller multiyear history.

2. Block 2 asked you to set interactions deliberately rather than leaving defaults. What's one pair of visuals where the default would have been misleading if left alone?

   Leaving the revenue trend at daily grain instead of switching to monthly would have been misleading next to the order count line. The sharply chart showed November 2017 as a single sharp spike, implying an unusually large batch of high item orders rather than what it actually was.
   Aggregating to monthly grain revealed it was simply Black Friday driven order growth not an anomaly in order composition. So I keep monthly but mark this spike in the notes.  
    
3. How did you land on your delivery-time bucket boundaries, and what would change about the chart's story if you'd picked wider or narrower buckets?

    I used PERCENTILE_CONT at 25% intervals to find the actual quartiles of delivery time. Then set bucket boundaries near those values rather than picking round numbers. Since Power BI's built-in grouping tool only supports equal width bins.
    I've done the custom (unequal width) boundaries with a DAX SWITCH(TRUE(), ...) calculated column instead. Wider buckets would have smoothed over the threshold effect where scores actually drop. 

4. Write the sentence you'd actually say Friday morning when presenting the delivery-time-vs-review-score chart — does it hold up to the correlation-vs-causation caution from today's concepts file?

   The chart holds up to the correlation vs causation caution shows an association but not proof that only delivery time drives ratings. 
   Scores stay flat between the Normal (8-10d) and Slower (11-16d) buckets and only decline sharply beyond that. It suggesting a threshold effect rather than a steady one day at a time decline in satisfaction.
