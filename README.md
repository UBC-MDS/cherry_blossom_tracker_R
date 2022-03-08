# 🌸 Vancouver Cherry blossom tracker

![Dashboard-GIF](https://github.com/UBC-MDS/cherry_blossom_tracker/blob/main/docs/screen-capture.gif?raw=true)

Are you curious about the locations of 🌸 cherry blossoms in Vancouver? How many different cherry cultivars are there? Which neighbourhood contains the most cherry blossoms? 🤔 It can be tricky to find the answers to these questions by yourself. To solve this problem, we combine various data sources together, and vizualize them on a dashboard for easy consumption. 

The [Cherry blossom tracker app](https://yvrcherryblossomtracker.herokuapp.com/) consists of maps and plots that help users locate cherry blossoms in Vancouver depending on the month, neighbourhood, tree size and cultivar. The maps display tree locations using geographic coordinates as well as tree density using a neighbourhood heat map. The plot contains a gantt chart with the blossoming timeline, cultivar bar chart, tree circumference distributions as well as a section with blossom photo examples.

## Useful Links

* 📊 [Dashboard Link](https://yvrcherryblossomtracker.herokuapp.com/)
* 🌸 [Cherry Cultivars list](https://www.vcbf.ca/education/cherry-cultivars)
* 🌳 [City of Vancouver - Street trees dataset](https://opendata.vancouver.ca/explore/dataset/street-trees/information/?disjunctive.species_name&disjunctive.common_name&disjunctive.height_range_id&disjunctive.on_street&disjunctive.neighbourhood_name)
* 📄 Proposal document can be found [here](https://github.com/UBC-MDS/cherry_blossom_tracker/blob/main/docs/proposal.md)

## Dashboard filters

1. **Blossom date picker.** *Cherry blossom tracker* allows users to filter by neighbourhood, tree cultivar and blossoming time. For example, if the user arrives in the spring, they can set the month to March or April to see which tree blossoms are currently in bloom. This change will appear on the map. When applied, this filter will display only those cultivars that are likely to blossom at this time.

2. **Neighbourhood dropdown.** Users can select the desired neighbourhoods from a dropdown list. This selection will zoom the map to the desired neighbourhood and also filter the cultivars, locations, cherry images and blossoming times according to the neighbourhood.

3. **Cultivar dropdown.** Different tree cultivars produce different flowers and colours. Users are able to search for information regarding specific cultivars. Their location, count and blossom time will be updated according to the selected cultivar.

4. **Tree circumference range filter.** Tree circumference is a proxy for the size of the tree and its canopy. Dashboard visitors may look specifically for larger and older trees. They can adjust the tree circumference using a slider.

## App sketch

Please checkout a scrollable interactive sketch on Figma. The dropdown selections and the about link are clickable:

[Figma prototype](https://www.figma.com/proto/wL64Jd85dE2p9KtgRm4SHr/Katia's-mockup?node-id=3%3A86&scaling=scale-down&page-id=0%3A1&starting-point-node-id=3%3A86)

![image](https://raw.githubusercontent.com/UBC-MDS/cherry_blossom_tracker/main/sketch.png)

## Contributing

Interested in contributing? Check out the contributing guidelines. Please note that this project is released with a Code of Conduct. By contributing to this project, you agree to abide by its terms.

For this project, we used `Dash` for dashboarding, `Altair` and `Plotly` for charts, and `Heroku` for deployment. Do check out the following links to learn more about them:

* [Dash Python User Guide](https://dash.plotly.com/)
* [Dash interactive visualization](https://dash.plotly.com/interactive-graphing)
* [Altair documentation](https://altair-viz.github.io/index.html)
* [Plotly Python documentation](https://plotly.com/python/)
* [Deploying Dash (on Heroku)](https://dash.plotly.com/deployment)

## License

`cherry_blossom_tracker` was created by Katia Aristova, Gabriel Fairbrother, Chaoran Wang, TZ Yan. It is licensed under the terms of the GNU General Public License v3.0 license.
