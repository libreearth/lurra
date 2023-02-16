import * as d3 from "d3"

let Chart = {
  svg: null,
  width: 600,
  height: 400,
  maxValue: 26,
  minValue: 0,
  units: "C",
  timeWidth: 60*60000,
  fromTime: new Date().getTime() - 60*60000,
  toTime: new Date().getTime(),
  margin: {top: 32, right: 32, bottom: 32, left: 32},
  currentXScale: null,
  data: [],
  secData: [],
  lablogs: [],
  mode: "play",
  inited: false,
  secondaryObserver: null,
  
  getGrWidth(){
    return this.width - this.margin.right - this.margin.left  
  },

  getGrTop(){
    return this.margin.top
  },

  getGrBottom() {
    return this.height - this.margin.bottom
  },

  getGrLeft() {
    return this.margin.left
  },

  getGrRight() {
    return this.width - this.margin.right
  },

  getSvgXCenter() {
    return this.width/2
  },

  getSvgYCenter() {
    return this.height/2
  },

  getYScale(){
    return d3.scaleLinear().domain([this.maxValue, this.minValue]).range([this.getGrTop(), this.getGrBottom()])
  },

  getYAxis(){
    return d3.axisRight(this.getYScale()).ticks(10).tickSize(this.getGrWidth())
  },

  getXScale() {
    return d3.scaleLinear().domain([this.fromTime, this.toTime]).range([this.getGrLeft(), this.getGrRight()])
  },

  getXAxis() {
    return d3.axisBottom(this.currentXScale).ticks(5).tickFormat(d3.timeFormat("%H:%M:%S"))
  },

  mounted(){
    this.minValue = this.el.dataset.minval
    this.maxValue = this.el.dataset.maxval
    this.units = this.el.dataset.unit
    this.handleEvent("window-changed", (data) => this.timeWindowChanged(data.time))
    this.handleEvent("new-point", (point) => this.newPointArrived(point))
    this.handleEvent("activate-mode-play", () => this.setPlayMode())
    this.handleEvent("activate-mode-explore", () => this.setExploreMode())
    this.handleEvent("arrow-left", () => this.timeWindowMovedLeft())
    this.handleEvent("arrow-right", () => this.timeWindowMovedRight())
    this.handleEvent("update-chart", () => this.updateYAxis())
    this.handleEvent("add-secondary-data", (observer) => this.addSecondaryData(observer))
    this.createChart()
    this.updateData()
  },

  addSecondaryData(observer){
    this.secondaryObserver = observer
    this.updateData()
  },

  setPlayMode(){
    this.mode = "play"
    from = new Date().getTime() - this.timeWidth,
    to = new Date().getTime()
    this.timeWindowMoved(from, to)
  },

  setExploreMode(){
    this.mode = "explore"
    this.updateDayRects()
  },

  destroyed(){
    console.log("destroyed!!!!")
  },

  updated() {
    this.createChart()
    this.updateData()
  },

  timeWindowChanged(milliseconds){
    this.timeWidth = milliseconds
    this.toTime = new Date().getTime()
    this.fromTime = this.toTime - this.timeWidth
    this.currentXScale = this.getXScale()
    this.updateDayRects()
    this.svg.select(".x-axis").call(this.getXAxis())
    this.updateData()
  },

  updateData() {
    let bin = Math.floor((this.toTime - this.fromTime)/this.getGrWidth())
    if (this.secondaryObserver != null){
      this.pushEvent("map-created", {sec_device_id: this.secondaryObserver.device_id, sec_sensor_type: this.secondaryObserver.sensor_type, from_time: this.fromTime, to_time: this.toTime, bin: bin, }, (data, ref) => {
        this.data = data.events
        this.secData = data.sec_events
        this.lablogs = data.lablogs
        this.drawData()
      })
    } else {
      this.pushEvent("map-created", {from_time: this.fromTime, to_time: this.toTime, bin: bin}, (data, ref) => {
        this.data = data.events
        this.lablogs = data.lablogs
        this.drawData()
      })
    }
  },

  timeWindowMovedLeft(){
    width = this.toTime - this.fromTime
    fromTime = this.fromTime - Math.round( width/2 )
    toTime = fromTime + width
    this.timeWindowMoved(fromTime, toTime)
  },

  timeWindowMovedRight(){
    width = this.toTime - this.fromTime
    fromTime = this.fromTime + Math.round( width/2 )
    toTime = fromTime + width
    this.timeWindowMoved(fromTime, toTime)
  },

  timeWindowMoved(from, to){
    this.toTime = to
    this.fromTime = from
    this.currentXScale = this.getXScale()
    this.svg.select(".x-axis").call(this.getXAxis())
    this.updateDayRects()
    this.updateData()
  },

  newPointArrived(point){
    if (this.mode == "play"){
      this.toTime = new Date().getTime()
      this.fromTime = this.toTime - this.timeWidth
      this.currentXScale = this.getXScale()
      this.svg.select(".x-axis").call(this.getXAxis())
      this.data.push(point)
      this.data = this.data.filter((point) => point.time >= this.fromTime)
      this.drawData()
    }
  },

  updateYAxis(){
    this.minValue = this.el.dataset.minval
    this.maxValue = this.el.dataset.maxval
    this.currentYScale = this.getYScale()
    this.updateDayRects()
    this.svg
      .select("#y-axis")
      .join()
      .call(this.getYAxis())
      .call((g) => g.selectAll(".tick:not(:first-of-type) line").attr("stroke-opacity", 0.5).attr("stroke-dasharray", "2,2"))
      .call((g) => g.selectAll(".tick text").attr("x", 15).attr("dy", -4))

    this.drawData()
  },

  updateDayRects(){
    dayTickValues = this.dayTickValues(this.currentXScale)
  
    this.svg
      .select(".day-rects")
      .selectAll("rect")
      .data(dayTickValues)
      .join("rect")
      .attr("x", (tick) => this.currentXScale(tick))
      .attr("y", this.getGrTop())
      .attr("width", (tick, i) => this.currentXScale(dayTickValues[i+1])-this.currentXScale(tick) || 0)
      .attr("height", this.getGrBottom() - this.getGrTop())
  },

  createChart(){
    this.currentXScale = this.getXScale()
    this.currentYScale = this.getYScale()
    this.svg = d3
      .select(this.el)
      .attr("width", this.width)
      .attr("height", this.height)

    let ticks = this.dayTickValues(this.currentXScale)
    this.svg
      .append("g")
      .attr("class", "day-rects")
      .selectAll("rect")
      .data(ticks)
      .join("rect")
    
    this.svg
      .append("g")
      .attr("class", "axis-text")
      .append("text")
      .attr("transform", "translate("+this.getSvgXCenter()+" "+(this.height-3)+")")
      .text("Time")

    this.svg
      .append("g")
      .attr("class", "axis-text")
      .append("text")
      .attr("transform", "translate("+(this.getGrLeft()-25)+" "+(this.getSvgYCenter())+")")
      .text(this.units)

    this.svg
      .append("g")
      .attr("class", "gr-data")

    this.svg
      .append("g")
      .attr("class", "gr-sec-data")

    this.svg
      .append("g")
      .attr("class", "gr-lablog")

    this.svg
      .append("g")
      .attr("class", "gr-ruler")

    this.svg
      .append("g")
      .attr("id", "y-axis")
      .attr("class", "y-axis")
      .attr("transform", "translate("+this.getGrLeft()+" 0)")
      .call(this.getYAxis())
      .call((g) => g.selectAll(".tick:not(:first-of-type) line").attr("stroke-opacity", 0.5).attr("stroke-dasharray", "2,2"))
      .call((g) => g.selectAll(".tick text").attr("x", 15).attr("dy", -4))

    this.svg
      .append("g")
      .attr("class", "x-axis")
      .attr("transform", "translate(0 "+this.getGrBottom()+")")
      .call(this.getXAxis())
    
  },

  line(){
    let dis = this
    return d3.line().x((d) => dis.currentXScale(d.time)).y((d) => dis.currentYScale(d.value))
  },

  drawData(){
    let dis = this
    this.svg
      .select(".gr-data")
      .selectAll("path")
      .data([this.data])
      .join("path")
      .attr("d", (d) => this.line()(d))

    this.svg
      .select(".gr-sec-data")
      .selectAll("path")
      .data([this.secData])
      .join("path")
      .attr("d", (d) => this.line()(d))

    let k = this.svg
      .select(".gr-lablog")
      .selectAll("circle")
      .data(this.lablogs)
      .join("circle")
      .attr("cx", (d) => dis.currentXScale(d.time))
      .attr("cy", this.getGrBottom())
      .attr("r", 5)

    k.selectAll("*").remove()

    k.append("title")
      .text((d) => d.user+" - "+d.payload)

    this.drawRuler()
  },

  drawRuler(){
    if (this.el.dataset.rulerval != null) {
      this.svg
        .select(".gr-ruler")
        .selectAll("line")
        .data([this.el.dataset.rulerval])
        .join("line")
        .attr("x1", this.getGrLeft())
        .attr("y1", (d) => this.currentYScale(d))
        .attr("x2", this.getGrRight())
        .attr("y2", (d) => this.currentYScale(d))
    }
  },

  dayTickValues(scale){
      let domain = scale.domain()
      let start = domain[0]
      let stop = domain[1]
      return d3.timeDays(start, stop+1, 1)
  }

};
  
export {Chart};