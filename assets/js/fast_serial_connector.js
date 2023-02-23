let fastSerialConnector = {
    port: null,
    buffer: "",
    connect(hook){
        navigator.serial.requestPort().then(async (port) => {
        this.port = port
        port.addEventListener("disconnect", () => this.disconnected())
            await port.open({ baudRate: 115200 })
        
            //text writer setup
            this.textEncoder = new TextEncoderStream()
            this.textEncoder.readable.pipeTo(port.writable)
            this.writer = this.textEncoder.writable.getWriter()
        
            //text reader setup
            this.textDecoder = new TextDecoderStream()
            port.readable.pipeTo(this.textDecoder.writable)
            this.reader = this.textDecoder.readable.getReader()
            hook.updateBuoyData()
        })
    },
    disconnected(){
        this.buffer=""
        this.writer = null
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
    async write(message){
        this.writer.write(message)
    }
}

export default fastSerialConnector
