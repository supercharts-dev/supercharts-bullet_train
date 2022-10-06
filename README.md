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

Let's you already have a ClickThrough model, storing click-throughs from campaigns. For now we'll just say it click_throughs have a `team_id` (in Bullet Train apps, your account is associated with a team).

You'd like a chart to appear in your Dashboard, showing how many click-throughs per day (so we'll group by), associated with your Team.

```bash
bin/super-scaffold supercharts:chart ClickThrough Team
```

### Generate some test data

We'll use a FactoryBot `trait` to randomize the `created_at` property for the test data we'll create.

```ruby
# test/factories/click_throughs.rb
FactoryBot.define do
  factory :click_through do
    association :team
    # add the following lines if the file was already created
    trait :created_last_2_months do
      created_at { Time.at(2.months.ago + rand * (Time.now.to_f - 2.months.ago.to_f)) }
    end
  end
end
```

Then from the `rails console`:

```ruby
FactoryBot.create_list(:click_through, 450, :created_last_2_months, team_id: 1)
```

Visit your app in `localhost:3000` and you should see your new chart.

## Modifying the chart

Coming soon...

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[bullet-train]: https://bullettrain.co