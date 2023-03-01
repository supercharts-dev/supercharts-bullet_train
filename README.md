# Supercharts for Bullet Train

Add charts to a [Bullet Train Rails app][bullet-train] the same way you super-scaffold a resource.

## Installation

### Start a Bullet Train app

First, you'll need to use the [Bullet Train Starter Kit][bullet-train], which is free, to build your app. It makes for a great sidecar analytics app with OAuth logins to another app of yours, easy configuration of roles and permissions, and a really quick way to build apps. You'll love it.

#### Using it in a non-Bullet Train Rails app

If you have a non-Bullet Train app, you can still use Bullet Train to scaffold the chart to display information on the right model, and use that as inspiration on how to include that into your own app.

#### Using it in an older version of Bullet Train

Supercharts only supports the [Bullet Train Starter Kit][bullet-train] split up into multiple gems and which uses Tailwind CSS. It's also optimized for the Light theme.

If you use an older version of Bullet Train for your app, you'll be pretty close. Your best bet is to still create a Bullet Train app using the [newer starter kit][bullet-train] (a prototype), re-create some of your real app's models and re-scaffold some of its controllers, and use Supercharts to scaffold a chart for you. It will be close to everything you need, and with some tweaks you'll be able to copy over the modified files into your older Bullet Train app.

### Add the gem

Add this line to your application's `Gemfile`:

```ruby
gem "supercharts-bullet_train"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install supercharts-bullet_train
```

### Add the `groupdate` gem

You'll also need the `groupdate` gem.

Add this line to your application's `Gemfile`:

```ruby
gem "groupdate"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install groupdate
```

### Add the npm package

The gem gives you all the Ruby- and Rails-specific parts, but you'll also need some JavaScript (Stimulus) components to display the chart. That's done by adding an npm package.

```bash
yarn add @supercharts/supercharts-bullet-train
```

In your `app/javascript/controllers/index.js`, add the following lines:

```js
// near the top
import { controllerDefinitions as superchartsControllers } from "@supercharts/supercharts-bullet-train"

// after application = Application.start()
application.load(superchartsControllers)
```

You're all set.

## Usage

Let's say you already have a ClickThrough model, storing click-throughs from campaigns. For now we'll just say it click_throughs have a `team_id` (in Bullet Train apps, your account is associated with a team).

You'd like a chart to appear in your Dashboard, showing how many click-throughs per day (so we'll group by day), associated with your Team.

```bash
bin/super-scaffold supercharts:chart ClickThrough Team
```

This will generated some new files and modify some files like inserting a `turbo_frame` in your `team#show` file, modifying your `roles.yml` file, etc. Look over the changes and commit when satisfied.

### Generate some test data

We'll use a new seed file create `click_throughs` with random-looking `created_at` properties (in this case creating a log normal spike and long-tail curve typical of a launch).

```ruby
# db/seeds/click_throughs.rb
team = Team.first

if team.present?
  ClickThrough.delete_all # start fresh
  
  # Rubystats::LognormalDistribution.new(1, 4.0)
  sample_logn_days_since_launch = [0.374752478249304,2.573715367349214,8.205364533794372,0.018758139772852223,0.007503724554433451,9.795277947976652,8.920746829981699,0.10551189188869997,1.764721845714895,0.16013475895174034,0.09656162234229956,1.051545673721908,3.4605465909422444,0.5284662248320162,12.552059342378902,0.802742590175781,0.02109366834525422,0.02664778128443366,4.390318514353362,0.09774971155444112,1.2046433918447472,6.842861969154294,0.011979372791258703,0.064030764714403,0.254580889613002,0.8375254371675241,6.645595256049555,0.004578324225909655,7.645897327323974,3.8198662350854358,2.5433159804484093,12.23258356052949,8.590508575839966,0.36652090412334615,0.11151312341555021,0.17233489061676868,0.2146532779238352,0.14245752689762017,0.19342953572076568,0.1529907988439447,0.00750514011797885,0.4518938917044475,2.824609604776437,0.9950891711469877,1.0656326056125578,0.1261305417548888,0.009966388079746133,11.001041702449946,0.0013675811570916427,0.02367451456093704,0.01894224395588477,4.440315660471336,0.09493622122995193,0.07657312652331208,1.4874835063144172,0.13842079252030612,2.1017802510726815,4.196227775076141,0.054093691138304485,0.0051252791552137186,3.0245345093639773,0.00032997376067659843,0.006931535931463956,1.78040031800141,1.2156342429038396,1.7978965235819222,0.818322573101528,0.08369936871534746,0.16412718021762976,9.844260419603875,5.14537997872604,10.644277259959916,2.516432067417657,0.02670462498452867,0.009043612354757327,2.481241138462057,1.9882680498827123,0.11922535105626798,0.20284489863820995,0.1274031773301022,0.35779282006366203,1.0571276594384351,1.0249771657735456,0.6552185634235514,0.7524783523736271,0.2539575382334551,0.5439132099545871]
  
  sample_logn_days_since_launch.each do |days_offset|
    created_at = 2.weeks.ago + days_offset.days
    
    team.click_throughs.create!(created_at: created_at)
  end
end
```

Then run:

```sh
bin/rails r db/seeds/click_throughs.rb
```

Visit your app in `localhost:3000` and you should see your new chart.

![Example chart inside a Bullet Train app showing Click Throughs in the last 30 days](https://user-images.githubusercontent.com/104179/222187945-1ff4a8c5-96d1-40e8-b421-d48c6cc4425d.gif)

## Modifying the chart

### The smallest change: switching to a bar chart

Changing to a bar chart is super easy: just change the following line in your `show.html.erb`

From:

```html
data-superchart-type-value="line"
```

To:

```html
data-superchart-type-value="bar"
```

### Other chart types: new Stimulus controller

Under the hood, the default Superchart is built using a chart.js instance wrapped inside a Stimulus controller.

For the following types of changes, you'll need to create your own Stimulus controller, duplicating the main `superchart_controller.js` found in this repo.

* Changing to a multi-line, stacked area or stacked bar chart
* Changing to a radial chart, a scattered plot, a box plot or any other chart

### Any other change: it depends

If you just want to make aesthetic changes, you can change the following css variables found at the top of your scaffolded `show.html.erb`. In this case, these are all TailwindCSS classes that set the appropriate custom CSS properties scoped to just that chart.

```html
[--axis-color:theme('colors.gray.300')] dark:[--axis-color:theme('colors.slate.500')]
[--grid-color:theme('colors.gray.100')] dark:[--grid-color:theme('colors.slate.800')]
[--line-color:#a86fe7]
[--point-color:theme('colors.gray.800')] dark:[--point-color:theme('colors.white')]
[--point-stroke-color:theme('colors.white')] dark:[--point-stroke-color:theme('colors.slate.700')]
[--point-stroke-color-hover:theme('colors.gray.100')] dark:[--point-stroke-color-hover:theme('colors.slate.800')]
[--bar-fill-color:var(--line-color)]
[--bar-hover-fill-color:var(--point-color)]
[--point-radius:4] md:[--point-radius:6]
[--point-hover-radius:6] md:[--point-hover-radius:10]
[--point-border-width:3] md:[--point-border-width:4]
[--point-hover-border-width:2] md:[--point-hover-border-width:3]
``` 

If you'd like to override some chart.js options, you can do so in the `chartjsOptions` element:

```html
<!-- This can only include valid JSON, but no functions. This is not code that will be evaluated -->
<template data-superchart-target="chartjsOptions">
  {
    "borderColor": "#000"
  }
</template>
```

Note that to make this work with both light and dark mode, you might as well use a custom CSS property, which Supercharts lets you do (but chart.js does not support by default):

```html
<!-- cssVar is a special sub-property which Supercharts will properly interpret as the value of the custom CSS property you set it to -->
<template data-superchart-target="chartjsOptions">
  {
    "borderColor": {
      "cssVar": "--my-custom-accent-color"
    }
  }
</template>
```

But if the changes you'd like to make is in the list below, you'll need to make your own custom Stimulus controller:

* The chart.js options you'd like to override includes JavaScript code (e.g. callback functions on properties)
* Including more than one series (multi-line chart, etc)
* Including annotations
* Including a custom hover overlay
* You need to change a chart.js option that's deeply nested (e.g. `scales.x.grid: false`) because it'll override all options in the top option

## Contributing

### Local development

* Create a Bullet Train app
* Use the instructions above to include the required gems and the npm package
* Create a `local/` directory into which you'll clone a copy of this repo:

```bash
mkdir local
cd local/
git clone <this REPO URL>
```

* In your Gemfile, change the gem to use the local path:

```ruby
gem "supercharts-bullet_train", path: "local/supercharts-bullet_train"
```

Then do

```bash
bundle install
```

* For modifying the JavaScript, Stimulus Controllers, you'll need to install `yalc` and use it to point to your local copy of the npm package:

```bash
yarn global add yalc
cd local/supercharts-bullet_train
yarn build # build the local changes
yalc push # publish the npm package locally on your own computer
cd ../../ # go back to the bullet-train project
yalc link @supercharts/supercharts-bullet-train
cd local/supercharts-bullet_train
yarn watch # continually watch for JavaScript changes, re-build the npm package and push to the Bullet Train app
```

## License
The gem and npm package are available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[bullet-train]: https://bullettrain.co
