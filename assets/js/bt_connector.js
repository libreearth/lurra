const MTU = 20;
    
btConnector = {
    bleNusServiceUUID: '6e400001-b5a3-f393-e0a9-e50e24dcca9e',
    bleNusCharRXUUID: '6e400002-b5a3-f393-e0a9-e50e24dcca9e',
    bleNusCharTXUUID: '6e400003-b5a3-f393-e0a9-e50e24dcca9e',
    device: null,
    service: null,
    rxCharacteristic: null,
    txCharacteristic: null,
    buffer: "",
    connect(hook){
        navigator.bluetooth.requestDevice({filters:[{namePrefix: 'Gotita'}], optionalServices: [this.bleNusServiceUUID]}).then(async (device) => {
          this.device = device
          this.device.addEventListener('gattserverdisconnected', () => this.disconnected(hook));
          this.server = await this.device.gatt.connect() 
          this.service = await this.server.getPrimaryService(this.bleNusServiceUUID)
          this.rxCharacteristic = await this.service.getCharacteristic(this.bleNusCharRXUUID)
          this.txCharacteristic = await this.service.getCharacteristic(this.bleNusCharTXUUID)
          await this.txCharacteristic.startNotifications();
          this.txCharacteristic.addEventListener('characteristicvaluechanged',(event) => this.dataRecieved(event, hook));
          hook.updateBuoyData()
        })
    },
    disconnected(hook){
        this.device = null
        this.buffer = ""
        this.service = null
        this.rxCharacteristic = null
        this.txCharacteristic = null
        hook.disconnected()
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
            //console.log(line)
            this.buffer = this.buffer.substring(index + 2)
            resolve(line)
        } else {
            //console.log(".")
            if (this.device!=null)
                setTimeout(() => this.rl(resolve), 1000)
            
        }
    },
    dataRecieved(event, hook) {
        let value = event.target.value
        // Convert raw data bytes to character values and use these to 
        // construct a string.
        let str = ""
        for (let i = 0; i < value.byteLength; i++) {
            str += String.fromCharCode(value.getUint8(i))
        }
        //console.log(str)
        hook.updateDownloadMessage(str)
        this.buffer = this.buffer + str
    }
}

export default btConnector
