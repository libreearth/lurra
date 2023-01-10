const MTU = 20;

let BuoyBt = {
  bleNusServiceUUID: '6e400001-b5a3-f393-e0a9-e50e24dcca9e',
  bleNusCharRXUUID: '6e400002-b5a3-f393-e0a9-e50e24dcca9e',
  bleNusCharTXUUID: '6e400003-b5a3-f393-e0a9-e50e24dcca9e',
  device: null,
  service: null,
  rxCharacteristic: null,
  txCharacteristic: null,
  buffer: "",
  downloadedBytes: -1,
  size: -1,
  extracted_data_size: 0,
  mounted(){
    this.handleEvent("show_message", (message) => alert(message.message))
    if ("bluetooth" in navigator) {
      this.el.querySelector("#connect_button").addEventListener("click", () => this.connect())
      this.el.querySelector("#set_time_button").addEventListener("click", () => this.updateTime())
      this.el.querySelector("#clear_button").addEventListener("click", () => this.clearData())
      this.el.querySelector("#extract_button").addEventListener("click", () => this.extractData())
      this.el.querySelector("#clear_extracted").addEventListener("click", () => this.clearExtractedData())
      this.el.querySelector("#download_button").addEventListener("click", () => this.sendDownloadDataEvent())
      this.el.querySelector("#upload_button").addEventListener("click", () => this.sendUploadDataEvent())
      this.el.querySelector("#disconnect_and_log_button").addEventListener("click", () => this.disconnectAndLog())
    } else {
      alert("Bluetooth api is not suported.")
    }
  },
  connect(){
    navigator.bluetooth.requestDevice({filters:[{namePrefix: 'Gotita'}], optionalServices: [this.bleNusServiceUUID]}).then(async (device) => {
      this.device = device
      this.device.addEventListener('gattserverdisconnected', () => this.disconnected());
      this.server = await this.device.gatt.connect() 
      this.service = await this.server.getPrimaryService(this.bleNusServiceUUID)
      this.rxCharacteristic = await this.service.getCharacteristic(this.bleNusCharRXUUID)
      this.txCharacteristic = await this.service.getCharacteristic(this.bleNusCharTXUUID)
      await this.txCharacteristic.startNotifications();
      this.txCharacteristic.addEventListener('characteristicvaluechanged',(event) => this.dataRecieved(event));
      this.updateBuoyData()
    })
  },
  async updateBuoyData(){
    let date = await this.getTime()
    let uid = await this.getUid()
    let battery = await this.getBattery()
    this.size = await this.getSize()
    this.sensors = await this.getSensors()
    this.pushEvent("connected", {date: date, uid: uid, sensors: this.sensors, battery: battery, size: this.size}, (data, ref) => this.extracted_data_size = data.extracted_data_size)
  },
  async updateTime(){
    await this.setTime()
    this.updateBuoyData()
  },
  async getSensors(){
    this.sendString("sensors\r")
    let sensors = await this.readLine()
    return sensors.split(",")
  },
  async getTime(){
    this.sendString("get_time\r") 
    let date = await this.readLine()
    return date
  },
  async getUid(){
    await this.sendString("uid\r")
    let uid = await this.readLine()
    return uid
  },
  async getBattery(){
    await this.sendString("battery\r")
    let bat = await this.readLine()
    return bat
  },
  async getSize(){
    await this.sendString("size\r")
    let s = await this.readLine()
    return s
  },
  async setTime(){
    let epoch = Math.floor(new Date().getTime()/1000)
    this.sendString("set_epoch " + epoch + "\r")
    let response = await this.readLine()
    return response
  },
  async clearData(){
    if (confirm("This action will delete all the data in the buoy. Are you sure?")){
      this.sendString("clear\r")
      let response = await this.readLine()
      return response
    } 
    return ""
  },
  async log(){
    await this.sendString("log\r")
  },
  async extractData(){
    this.downloadMessage = document.querySelector("#download_text")
    this.downloadedBytes = this.extracted_data_size
    let readBytes = this.extracted_data_size
    this.sendString("list "+this.extracted_data_size+"\r")
    let line = await this.readLine()
    readBytes += line.length+2
    while (line != "Ok"){
      dataline = line.split(";")
      let epoch = new Date(dataline[0]+" UTC").getTime()
      if (epoch!=null && !isNaN(epoch)){
        let datam = {epoch: epoch, read: readBytes, timestamp: dataline[0]}
        this.sensors.forEach((sensor, index) => datam[sensor] = dataline[index+1])
        this.pushEvent("extract_data", datam)
      }
      line = await this.readLine()
      readBytes += line.length+2
    }
    this.pushEvent("recalculate_extracted_data", {}, (data, ref) => this.extracted_data_size = data.extracted_data_size)
    this.downloadedBytes = -1
  },
  async uploadData(){
    this.sendString("list\r")
    let line = await this.readLine()
    let data = []
    while (line != "Ok"){
      dataline = line.split(";")
      let datam = {epoch: new Date(dataline[0]+" UTC").getTime()}
      this.sensors.forEach((sensor, index) => datam[sensor] = dataline[index+1])
      data.push(datam)
      line = await this.readLine()
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
  async readLine(){
    return new Promise((resolve, reject) => {
      this.rl(resolve)
    })
  },
  rl(resolve){
    let index = this.buffer.indexOf("\n\r")
    if (index!=-1){
      let line = this.buffer.substring(0, index)
      this.buffer = this.buffer.substring(index + 2)
      resolve(line)
    } else {
      setTimeout(() => this.rl(resolve), 100)
    }
  },
  async disconnectAndLog(){
    await this.log()
    this.disconnected()
  },
  disconnected(){
    this.device = null
    this.buffer = ""
    this.service = null
    this.rxCharacteristic = null
    this.txCharacteristic = null
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
  dataRecieved(event) {
    let value = event.target.value
    // Convert raw data bytes to character values and use these to 
    // construct a string.
    let str = ""
    for (let i = 0; i < value.byteLength; i++) {
        str += String.fromCharCode(value.getUint8(i))
    }
    this.updateDownloadMessage(str)
    this.buffer = this.buffer + str
  },
  updateDownloadMessage(str){
    if (this.downloadedBytes>=0){
      this.downloadedBytes += str.length
      let porc = Math.ceil((this.downloadedBytes/this.size)*100)
      this.downloadMessage.innerHTML = "Extracting progress: <progress max=100 value="+porc+"></progress> "+this.downloadedBytes+" bytes"
    }
  },
  sendString(s) {
    if(this.device && this.device.gatt.connected) {
      let val_arr = new Uint8Array(s.length)
      for (let i = 0; i < s.length; i++) {
          let val = s[i].charCodeAt(0)
          val_arr[i] = val
      }
      this.sendNextChunk(val_arr);
    }
  },
  sendNextChunk(a) {
    let chunk = a.slice(0, MTU)
    this.rxCharacteristic.writeValue(chunk)
      .then(() => {
        if (a.length > MTU) {
          this.sendNextChunk(a.slice(MTU))
        }
    })
  }
}

export {BuoyBt}
