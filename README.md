# DEPRECATED: Supercharts for Bullet Train

Add charts to a [Bullet Train Rails app][bullet-train] the same way you super-scaffold a resource.

## Removing This Dependency, Run it Locally

This package is no longer maintained, but you can still continue to drive the charts you currently have locally.

To run everything locally and remove the dependency, eject the view partials and JavaScript components with this command:

    bin/rails supercharts:eject_all

## CHANGELOG

### v1.3.1

**Deprecate the package.**

### v1.3.0

**Support for Bullet Train's new theme colors, removes `darkPrimary` color**

Impact on your previously charts: the files within `views/shared` (skeleton, filters) will look different after upgrade and might generate Tailwind errors.

Recommendation: Upgrade to this version at the same time you upgrade to the latest version of Bullet Train's light theme. Otherwise, your charts will look off or you might have Tailwind build errors. See the [PR in `bullet_train-core` for the changes and rationale](https://github.com/bullet-train-co/bullet_train-core/pull/106).

Alternative: make local copies of the partials in `views/shared/` before you upgrade.

Look for:

* Replacing of `darkPrimary` with `slate`
* A darker background color in dark mode. That's because Bullet Train uses `bg-opacity-50` to get a half-way background Tailwind color increment, which doesn't work with the point border color.

Also included:

* New recommended approach for seeding test data using a `db/seeds/` file. See the "Generate some test data" above.

### v1.2.0

**Locale strings**

No impact to your previously-scaffolded charts by applying this update, but the next charts you scaffold will have the changes.

Recommendation: Re-run the scaffold command or compare the diff against your chart to apply the changes.

Look for:

* new strings added to your resource's `en.yml` file. A new one is created if not already present.
* the scaffolded ERB now references all those new locale strings for a cleaner code.

### v1.1.0

**Fixes to time ranges and code optimizations.**

No impact to your previously-scaffolded charts by applying this update, but the next charts you scaffold will have the new changes.

Recommendation: Re-run the scaffold command or compare the diff against your chart to apply the changes.

Look for:

* changes in the time ranges
* the variable no longer called `data`, but instead called `series`. There's a couple places where that's changed.

### v1.0.3

**Bug fixes and small visual tweaks.**

No impact to your previously-scaffolded charts by applying this update, but the next charts you scaffold will have the bug fixes.

Recommendation: Re-run the scaffold command or compare the diff against your chart to apply the bug fixes.

Look for:

* there's now a nowrap on the date when the daily summary is shown
* `first: true` being removed from the second filter
* `var(--chart-height)""` (I mean)
* correctly use `value_formatted` instead of `value` for the formatted value column
* look for "Week of" in the formatted date when the weekly view is shown

### v1.0.0

**Initial launch**

## License
The gem and npm package are available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[bullet-train]: https://bullettrain.co
