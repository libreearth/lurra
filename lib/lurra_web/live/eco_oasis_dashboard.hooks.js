
let Stored = {
    mounted() {
        this.handleEvent("store", (obj) => {this.store(obj)})
    },

    store(obj) {
        localStorage.setItem(obj.key, obj.data)
    }
}

export {Stored}