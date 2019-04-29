$.fn.preload = function() {
    this.each(function(){
        $('<img/>')[0].src = this;
    });
};