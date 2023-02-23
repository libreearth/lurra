import connector from "../fast_serial_connector"

let BuoyFastSerial = {
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
  async connect(){
    connector.connect(this)
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
    connector.write("sensors\r")
    let sensors = await connector.readLine()
    return sensors.split(",")
  },
  async getTime(){
    connector.write("get_time\r") 
    let date = await connector.readLine()
    return date
  },
  async getUid(){
    await connector.write("uid\r")
    let uid = await connector.readLine()
    return uid
  },
  async setTime(){
    let epoch = Math.floor(new Date().getTime()/1000)
    connector.write("set_epoch " + epoch + "\r")
    let response = await connector.readLine()
    return response
  },
  async clearData(){
    if (confirm("This action will delte all the data in the buoy. Are you sure?")){
      connector.write("clear\r")
      let response = await connector.readLine()
      return response
    } 
    return ""
  },
  async log(){
    await connector.write("log\r")
  },
  async uploadData(){
    connector.write("list 0\r")
    let line = await connector.readLine()
    let data = []
    while (line != "Ok"){
      dataline = line.split(";")
      let datam = {epoch: new Date(dataline[0]+" UTC").getTime()}
      this.sensors.forEach((sensor, index) => datam[sensor] = dataline[index+1])
      data.push(datam)
      line = await connector.readLine()
    }
    this.pushEvent("save_data", data)
  },
  async downloadData(){
    connector.write("list 0\r")
    let line = await connector.readLine()
    let text = ""
    while (line != "Ok"){
      text = text + line + "\n"
      line = await connector.readLine()
    }
    this.download("buoy_data.csv", text)
  },
  async disconnectAndLog(){
    await this.log()
    this.disconnected()
  },
  disconnected(){
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

export {BuoyFastSerial}
