let BuoySerial = {
  mounted(){
    if ("serial" in navigator) {
      this.pushEvent("serial_supported", true)
    } else {
      alert("serial api is not suported")
    }
  }
}

export {BuoySerial}
