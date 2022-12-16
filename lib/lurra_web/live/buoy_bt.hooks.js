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
  mounted(){
    this.handleEvent("show_message", (message) => alert(message.message))
    if ("bluetooth" in navigator) {
      this.el.querySelector("#connect_button").addEventListener("click", () => this.connect())
      this.el.querySelector("#set_time_button").addEventListener("click", () => this.updateTime())
      this.el.querySelector("#clear_button").addEventListener("click", () => this.clearData())
      this.el.querySelector("#download_button").addEventListener("click", () => this.downloadData())
      this.el.querySelector("#upload_button").addEventListener("click", () => this.uploadData())
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
    this.sensors = await this.getSensors()
    this.pushEvent("connected", {date: date, uid: uid, sensors: this.sensors})
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
  async setTime(){
    let epoch = Math.floor(new Date().getTime()/1000)
    this.sendString("set_epoch " + epoch + "\r")
    let response = await this.readLine()
    return response
  },
  async clearData(){
    if (confirm("This action will delte all the data in the buoy. Are you sure?")){
      this.sendString("clear\r")
      let response = await this.readLine()
      return response
    } 
    return ""
  },
  async log(){
    await this.sendString("log\r")
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
  async downloadData(){
    this.sendString("list\r")
    let line = await this.readLine()
    let text = ""
    while (line != "Ok"){
      text = text + line + "\n"
      line = await this.readLine()
    }
    this.download("buoy_data.csv", text)
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
      setTimeout(() => this.rl(resolve), 500)
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
    this.buffer = this.buffer + str
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
