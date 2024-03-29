import serial_connector from "../fast_serial_connector";
import bt_connector from "../bt_connector"

const MTU = 20;

let BuoyBt = {
  downloadedBytes: -1,
  size: -1,
  extracted_data_size: 0,
  connector: bt_connector,
  mounted(){
    this.handleEvent("show_message", (message) => alert(message.message))
    this.handleEvent("set_frequency", (message) => this.updateFrequency(message.freq))
    this.handleEvent("set_power", (message) => this.updatePowerAndReboot(message.power))
    if ("bluetooth" in navigator) {
      this.el.querySelector("#connect_button").addEventListener("click", () => this.connect())
      this.el.querySelector("#set_time_button").addEventListener("click", () => this.updateTime())
      this.el.querySelector("#clear_button").addEventListener("click", () => this.clearData())
      this.el.querySelector("#extract_button").addEventListener("click", () => this.extractData())
      this.el.querySelector("#clear_extracted").addEventListener("click", () => this.clearExtractedData())
      this.el.querySelector("#download_button").addEventListener("click", () => this.sendDownloadDataEvent())
      this.el.querySelector("#upload_button").addEventListener("click", () => this.sendUploadDataEvent())
      this.el.querySelector("#disconnect_and_log_button").addEventListener("click", () => this.disconnectAndLog())
      this.handleEvent("change-connection-method", (event) => this.changeConnectionMethod(event))
    } else {
      alert("Bluetooth api is not suported.")
    }
  },
  connect(){
    this.connector.connect(this)
  },
  changeConnectionMethod(event){
    if (event.method == "Bluetooth"){
      this.connector = bt_connector
    } else {
      this.connector = serial_connector
    }
  },
  async updateBuoyData(){
    let date = await this.getTime()
    let uid = await this.getUid()
    let battery = await this.getBattery()
    this.size = await this.getSize()
    this.sensors = await this.getSensors()
    this.version = await this.getVersion()
    this.data_freq = await this.getDataFreq()
    this.tx_power = await this.getTxPower()
    this.pushEvent("connected", {date: date, uid: uid, version: this.version, sensors: this.sensors, tx_power: this.tx_power, data_freq: this.data_freq, battery: battery, size: this.size}, (data, ref) => this.extracted_data_size = data.extracted_data_size)
  },
  async updateFrequency(sec){
    if (sec && sec > 0) {
      this.connector.sendString(`set_freq ${sec}\r`)
      let response = await this.connector.readLine()
      this.updateBuoyData()
      return response
    } else {
      return ""
    }
  },
  async updatePowerAndReboot(power){
    this.connector.sendString(`set_pow ${power}\r`)
    let response = await this.connector.readLine()
    let answer = confirm("The buoy needs to reboot to make the changes make effect. Do you want to proceed?");

    if (answer) {
      this.connector.sendString("reboot\r")
    }
    return response
  },
  async updateTime(){
    await this.setTime()
    this.updateBuoyData()
  },
  async clearData(){
    await this.doClearData()
    this.updateBuoyData()
  },
  async getSensors(){
    this.connector.sendString("sensors\r")
    let sensors = await this.connector.readLine()
    return sensors.split(",")
  },
  async getTime(){
    this.connector.sendString("get_time\r") 
    let date = await this.connector.readLine()
    return date
  },
  async getUid(){
    await this.connector.sendString("uid\r")
    let uid = await this.connector.readLine()
    return uid
  },
  async getBattery(){
    await this.connector.sendString("battery\r")
    let bat = await this.connector.readLine()
    return bat
  },
  async getSize(){
    await this.connector.sendString("size\r")
    let s = await this.connector.readLine()
    return s
  },
  async getVersion(){
    await this.connector.sendString("version\r")
    let s = await this.connector.readLine()
    return s
  },
  async getDataFreq(){
    await this.connector.sendString("get_freq\r")
    let s = await this.connector.readLine()
    return s
  },
  async getTxPower(){
    await this.connector.sendString("get_pow\r")
    let s = await this.connector.readLine()
    return s
  },
  async setTime(){
    let epoch = Math.floor(new Date().getTime()/1000)
    this.connector.sendString("set_epoch " + epoch + "\r")
    let response = await this.connector.readLine()
    return response
  },
  async doClearData(){
    if (confirm("This action will delete all the data in the buoy. Are you sure?")){
      this.connector.sendString("clear\r")
      let response = await this.connector.readLine()
      return response
    } 
    return ""
  },
  async log(){
    await this.connector.sendString("log\r")
  },
  async extractData(){
    this.downloadMessage = document.querySelector("#download_text")
    this.downloadedBytes = this.extracted_data_size
    let readBytes = this.extracted_data_size
    this.connector.sendString("list "+this.extracted_data_size+"\r")
    let line = await this.connector.readLine(this)
    readBytes += line.length+2
    while (line != "Ok"){
      dataline = line.split(";")
      let epoch = new Date(dataline[0]+" UTC").getTime()
      if (epoch!=null && !isNaN(epoch)){
        let datam = {epoch: epoch, read: readBytes, timestamp: dataline[0]}
        this.sensors.forEach((sensor, index) => datam[sensor] = dataline[index+1])
        this.pushEvent("extract_data", datam)
      }
      line = await this.connector.readLine(this)
      readBytes += line.length+2
    }
    this.pushEvent("recalculate_extracted_data", {}, (data, ref) => this.extracted_data_size = data.extracted_data_size)
    this.downloadedBytes = -1
  },
  async uploadData(){
    this.connector.sendString("list\r")
    let line = await this.connector.readLine()
    let data = []
    while (line != "Ok"){
      dataline = line.split(";")
      let datam = {epoch: new Date(dataline[0]+" UTC").getTime()}
      this.sensors.forEach((sensor, index) => datam[sensor] = dataline[index+1])
      data.push(datam)
      line = await this.connector.readLine()
    }
    this.pushEvent("save_data", data)
  },
  sendUploadDataEvent(){
    this.pushEvent("upload_data")
  },
  sendDownloadDataEvent(){
    this.pushEvent("download_data", {}, (data, ref) => this.download("buoy_data.csv", data.csv))
  },
  clearExtractedData(){
    if (confirm("This action will remove all extracted data in the computer. Are you sure?")){
      this.pushEvent("clear_extracted_data", {})
      this.pushEvent("recalculate_extracted_data", {}, (data, ref) => this.extracted_data_size = data.extracted_data_size)
    }
  },
  async disconnectAndLog(){
    await this.log()
    this.disconnected()
  },
  disconnected(){
    this.pushEvent("disconnected")
  },
  download(filename, text) {
    var element = document.createElement('a')
    element.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(text))
    element.setAttribute('download', filename)
  
    element.style.display = 'none'
    document.body.appendChild(element)
  
    element.click()
  
    document.body.removeChild(element)
  },
  updateDownloadMessage(str){
    if (this.downloadedBytes>=0){
      this.downloadedBytes += str.length
      if (!this.startingCount){
        this.startingCount = new Date().getTime()
        this.startingBytes = this.downloadedBytes
      } else {
        let time = new Date().getTime() - this.startingCount
        if (time > 10000){
          let amount = this.downloadedBytes - this.startingBytes
          this.speed = Math.ceil(amount/(time/1000))
          this.startingCount = 0
        }
      }
      let porc = Math.ceil((this.downloadedBytes/this.size)*100)
      if (this.speed) {
        let eta = Math.ceil((this.size-this.downloadedBytes)/this.speed)
        this.downloadMessage.innerHTML = "Extracting progress: <progress max=100 value="+porc+"></progress> "+this.downloadedBytes+" bytes at "+this.speed+" bytes/sec ETA: "+eta+" secs"
      } else 
        this.downloadMessage.innerHTML = "Extracting progress: <progress max=100 value="+porc+"></progress> "+this.downloadedBytes+" bytes"
    }
  }
}

export {BuoyBt}
