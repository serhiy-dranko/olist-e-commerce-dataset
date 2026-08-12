1. What did the daily-grain version of the revenue trend chart look like before you adjusted the granularity, and why was the adjusted version the more honest one to present?

    The daily version showed revenue swinging sharply day to day, mostly due to weekday/weekend patterns and random order-level variance rather than any real trend. At a yearly zoom level it looked like noise, not signal. 
    Aggregating to monthly removes that noise without altering the underlying totals, making the actual trend visible instead of buried under daily fluctuation. 
    That's the more honest choice for a yearly report: it matches the question being asked ("is the business growing?") without implying false precision or inviting readers to over read one off spikes.


2. Which of today's three charts needed the most cardinality management, and what would the chart have looked like if you'd skipped that step? 

    The pie chart needed the most cardinality management. Olist has a lot categories/states, and without the Top 10 + "Other" grouping, a pie chart would have a lot thin slivers, most too small to read or label, with legend colors running out and repeating. 
    It'd technically show "all the data" but communicate almost nothing, since the eye can only meaningfully compare 10 categories at once.
    
    Given the time constraint, skipping the adjustable Top N (parameter-driven) and hardcoding Top 10 in SQL is a reasonable trade off . We still get the readable, honest chart, we just lose the ability for a viewer to toggle N interactively. Worth flagging that as a known limitation rather than presenting it as flexible when it isn't.

3. Block 5 asked you to trace any mismatch back to its source rather than patching the visual. Did you find one today, and if so, where did it actually originate?

   No, all looks good. The November 24, 2017  Total Revenue 178 K, was indeed a Friday and marked the eighth edition of Black Friday in Brazil. The nationwide shopping event generated massive crowds and intense competition in brick-and-mortar stores, alongside billions of Reais in e-commerce sales.

5. Tomorrow adds slicers, cross-filtering, and a delivery-time-vs-review-score visual. Based on today's measures and table structure, what do you expect to be straightforward, and what do you expect to need real thought?

      Slicers, cross-filtering, and the basic delivery-vs-review chart should be quick — everything's already flat in one table with grouped columns ready to drop in. The real thought goes into the delivery-time/review-score story itself:
     checking for confounders (state, category) before implying delivery speed causes low ratings and deciding how to handle NULLs (cancelled/unreviewed orders) so they don't silently skew the averages.

