
let DropableDome = {
  mounted(){
    this.el.addEventListener("drop", ev => this.drop(ev))
    this.el.addEventListener("dragover", ev => this.allowDrop(ev))
    this.el.addEventListener("dragstart", ev => this.drag(ev))
  },
  allowDrop(ev) {
    ev.preventDefault()
  },
  drag(ev) {
    ev.dataTransfer.setData("text", ev.target.id)
  },
  drop(ev) {
    ev.preventDefault();
    var origin = ev.dataTransfer.getData("text")
    var source = ev.target.closest(".dropable")
    console.log(source)
    this.pushEvent("dropped-over", {origin: origin, destiny: source.id})
  }
}

export {DropableDome}
