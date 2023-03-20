let fastSerialConnector = {
    port: null,
    buffer: "",
    connect(hook){
        navigator.serial.requestPort().then(async (port) => {
        this.port = port
        port.addEventListener("disconnect", () => this.disconnected(hook))
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
    disconnected(hook){
        this.buffer=""
        this.writer = null
        hook.disconnected()
    },
    async sendString(message){
        this.writer.write(message)
    },
    async readLine(hook){
        return new Promise((resolve, reject) => {
            this.rl(resolve, hook)
        })
    },
    async rl(resolve, hook){
        let index = this.buffer.indexOf("\n\r")
        if (index!=-1){
            let line = this.buffer.substring(0, index)
            this.buffer = this.buffer.substring(index + 2)
            resolve(line)
        } else {
            this.reader.read().then((nread) => {
                this.buffer = this.buffer + nread.value
                if (hook)
                    hook.updateDownloadMessage(nread.value)
                this.rl(resolve, hook)
            })   
        }
    }
}

export default fastSerialConnector
