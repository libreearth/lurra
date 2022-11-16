let BuoySerial = {
  port: null,
  buffer: "",
  mounted(){
    this.handleEvent("show_message", (message) => alert(message.message))
    if ("serial" in navigator) {
      this.el.querySelector("#connect_button").addEventListener("click", () => this.connect())
      this.el.querySelector("#set_time_button").addEventListener("click", () => this.updateTime())
      this.el.querySelector("#clear_button").addEventListener("click", () => this.clearData())
      this.el.querySelector("#download_button").addEventListener("click", () => this.downloadData())
      this.el.querySelector("#upload_button").addEventListener("click", () => this.uploadData())
      this.el.querySelector("#disconnect_and_log_button").addEventListener("click", () => this.disconnectAndLog())
    } else {
      alert("Serial api is not suported.")
    }
  },
  connect(){
    navigator.serial.requestPort().then(async (port) => {
      this.port = port
      port.addEventListener("disconnect", () => this.disconnected())
      await port.open({ baudRate: 9600 })

      //text writer setup
      this.textEncoder = new TextEncoderStream()
      this.textEncoder.readable.pipeTo(port.writable)
      this.writer = this.textEncoder.writable.getWriter()

      //text reader setup
      this.textDecoder = new TextDecoderStream()
      port.readable.pipeTo(this.textDecoder.writable)
      this.reader = this.textDecoder.readable.getReader()
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
    this.writer.write("sensors\r")
    let sensors = await this.readLine()
    return sensors.split(",")
  },
  async getTime(){
    this.writer.write("get_time\r") 
    let date = await this.readLine()
    return date
  },
  async getUid(){
    await this.writer.write("uid\r")
    let uid = await this.readLine()
    return uid
  },
  async setTime(){
    let epoch = Math.floor(new Date().getTime()/1000)
    this.writer.write("set_epoch " + epoch + "\r")
    let response = await this.readLine()
    return response
  },
  async clearData(){
    if (confirm("This action will delte all the data in the buoy. Are you sure?")){
      this.writer.write("clear\r")
      let response = await this.readLine()
      return response
    } 
    return ""
  },
  async log(){
    await this.writer.write("log\r")
  },
  async uploadData(){
    this.writer.write("list\r")
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
    this.writer.write("list\r")
    let line = await this.readLine()
    let text = ""
    while (line != "Ok"){
      text = text + line + "\n"
      line = await this.readLine()
    }
    this.download("buoy_data.csv", text)
  },
  async readLine(){
    let index = this.buffer.indexOf("\n\r")
    if (index!=-1){
      let line = this.buffer.substring(0, index)
      this.buffer = this.buffer.substring(index + 2)
      return line
    } else {
      let nread = await this.reader.read()
      this.buffer = this.buffer + nread.value
      return await this.readLine()
    }
  },
  async disconnectAndLog(){
    await this.log()
    this.disconnected()
  },
  disconnected(){
    this.port = null
    this.buffer = ""
    this.writer = null
    this.reader = null
    this.pushEvent("disconnected")
  },
  download(filename, text) {
    var element = document.createElement('a');
    element.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(text));
    element.setAttribute('download', filename);
  
    element.style.display = 'none';
    document.body.appendChild(element);
  
    element.click();
  
    document.body.removeChild(element);
  }
}

export {BuoySerial}
