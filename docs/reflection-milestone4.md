## Features implemented in dashboard so far
* Implemented feedback, which includes:
  1. Changing `Count of Records` to `Number of trees` in tree density map
  2. Changing tree diameter plot limit to 150cm
  3. Change color of spinner to fit the theme of the dashboard
  4. Allow multi-selections in drop-down filters
  5. Better GIF and writeup in README to showcase full functionalities of dashboard
  6. Enable compression of Flask responses to speed up dashboard
* Various filters below navbar to filter selections of trees
* Street map which plots the location of trees, and also allow `Box Select` and `Lasso Select` for selecting specific areas on the map
* Bar chart showing number of trees for each cherry blossom type (cultivars)
* Bloom Gantt chart which showcases bloom timing for each cultivar
* Tree diameter density plot which shows the distribution of tree diameter
* Density map plot which shows the distribution of trees in each neighbourhood

## Features not yet implemented
* Make data dynamic (e.g. using REST api) instead of manually downloading and saving `.csv` file
* Make date picker dynamic. Currently, it is manually set to 2022
* Impute NaN values so that we do not drop as much data
* Caching to improve dashboard performance

## Thoughts on the feedback received
Some feedbacks were surprising but insightful. For example, one feedback was about showcasing more features in the GIF. Originally, our GIF was quite short (around 10 seconds), as we just wanted to show the look-and-feel of the app. However, a GIF is very useful to convey a large amount of information in a short time. It is much easier to show how the dropdown selection works, as opposed to writing a paragraph on how it works.

Some feedbacks also mentioned having additional charts that allow comparison between neighbourhood, tree diameters, and cultivars. It was quite tricky to implement that, because there are a lot of 'levels' for the neighbourhood and cultivars variable. Showing all of them on a single chart will cause it to become too cluttered and hard to interpret. One way is to only show the top n of each categorical variable (e.g. top 3), but it might be tricky to do it dynamically. In the end, we implemented one of the feedback (multi-selection for filters) to allow users to indirectly compare between neighbourhoods.

There were also comments about how it is better to see all the charts on a single page without scrolling. After some internal discussions, we decided to not implement this feature for now. We do agree that being able to see a dashboard without scrolling will offer a better user experience. However, we felt that the map is the 'centrepiece' of the dashboard, and it is hard to squeeze other charts into a single page while maintaining the visual importance of the map. One way to overcome this is to 'overlay' other charts on top of the map, just like in https://exploretrees.sg/. 
