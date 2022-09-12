import { SuperchartChartjsController } from '@supercharts/stimulus-base'
import * as d3 from "d3"

export default class extends SuperchartChartjsController {
  static targets = [ "chartjsOptions", "chartjsData", "chartjsCanvas", "csvData" ]
  static values = {
    type: { 
      type: String,
      default: "line"
    },
    label: {
      type: String,
      default: "Value"
    }
  }
  
  static defaultCssProperties = {
    '--animation-duration': 200, // milliseconds
  }
  
  connect() {
    super.connect()
  }
  
  updateChart() {
    super.updateChart()
  }
  
  get chartjsData() {
    if (this.hasChartJsDataTarget) {
      return super.chartjsData()
    }
    if (!this.hasCsvDataTarget) {
      console.warn(`The chart needs data in a in a csv target or in a chartjsData target (in chart.js JSON)`)
      return []
    }
    
    const csv = d3.csvParse(this.csvDataTarget.innerHTML.trim(), d3.autoType)
    return {
      labels: csv.map(d => d[csv.columns[0]]),
      datasets: [{
        type: this.typeValue,
        label: this.labelValue,
        data: csv.map(d => d[csv.columns[1]])
      }]
    }
  }
  
  get chartjsOptions() {
    let options = {
      ...this.defaultOptions
    }
    
    if (this.hasChartjsOptionsTarget) {
      options = {
        ...options,
        ...JSON.parse(this.chartjsOptionsTarget.innerHTML.trim())
      }
    }
    
    return options
  }

  // You can set default options in this getter for all your charts.
  get defaultOptions() {
    const transparentWhite = '#ffffff66'
    return {
      maintainAspectRatio: false,
      animation: {
        x: {
          type: 'number',
          easing: 'linear',
          duration: this.delayBetweenPoints,
          from: NaN, // the point is initially skipped
          delay: (ctx) => {
            if (ctx.type !== 'data' || ctx.xStarted) {
              return 0;
            }
            ctx.xStarted = true;
            return ctx.index * this.delayBetweenPoints;
          }
        },
        y: {
          type: 'number',
          easing: 'linear',
          duration: this.delayBetweenPoints,
          from: previousY,
          delay: (ctx) => {
            if (ctx.type !== 'data' || ctx.yStarted) {
              return 0;
            }
            ctx.yStarted = true;
            return ctx.index * this.delayBetweenPoints;
          }
        }
      },
      plugins: {
        legend: {
          display: false,
        }
      },
      color: transparentWhite,
      borderColor: 'rgb(4, 123, 248)',
      fill: false,
      lineTension: 0.3,
      backgroundColor: "#fff",
      borderColor: "#047bf8",
      borderCapStyle: "butt",
      borderDash: [],
      borderDashOffset: 0,
      borderJoinStyle: "miter",
      pointBorderColor: "rgb(50, 60, 88)",
      pointBackgroundColor: "#fff",
      pointBorderWidth: 4,
      pointHoverRadius: 10,
      pointHoverBackgroundColor: "#fff",
      pointHoverBorderColor: "rgb(50, 60, 88)",
      pointHoverBorderWidth: 3,
      pointRadius: 6,
      pointHitRadius: 10,
      spanGaps: false,
      scales: {
        x: {
          grid: {
            borderColor: transparentWhite
          },
          ticks: {
            color: transparentWhite,
            tickColor: transparentWhite
          }
        },
        y: {
          grid: {
            borderColor: transparentWhite,
            tickColor: transparentWhite
          },
          ticks: {
            color: transparentWhite
          }
        }
      }
    }
  }
  
  get delayBetweenPoints() {
    return this.cssPropertyValue('--animation-duration') / this.chartjsData?.datasets[0]?.data?.length
  }
}

function previousY (ctx) {
  return ctx.index === 0 ? ctx.chart.scales.y.getPixelForValue(100) : ctx.chart.getDatasetMeta(ctx.datasetIndex).data[ctx.index - 1].getProps(['y'], true).y;
}