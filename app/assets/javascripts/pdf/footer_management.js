/**
 * Page numbers = Handle the footer and numbering of pdf pages
 *
 * Example usage:
 * var new_footer_management = new footerManagement();
 * new_footer_management.initialize({});
 */
 
 
 /**
  * footerManagement constructor
  *
  * @constructor
  * @this {footerManagement}
  */
window.footerManagement = function() {
    this.options = {};
};


window.footerManagement.prototype = {


    /**
     * Initialize the footer
     *
     * @param {hash} options Options to override the defaults.
     */
    initialize: function(options) {
        this.options = $.extend(this.options, options);

        this._add_page_numbers();
    },
    
    
    /**
     * Add the pages numbers to the footer
     */
    _add_page_numbers: function() {
        var vars = {};
        var x = document.location.search.substring(1).split('&');
        for (var i in x) {var z=x[i].split('=',2);vars[z[0]] = encodeURIComponent(z[1]);}
        var xp = ['topage','page'];
        for (var ip in xp) {
            var y = document.getElementsByClassName(xp[ip]);
            for (var j=0; j<y.length; j++) {
                if (vars[xp[ip]]) {
                    y[j].textContent = vars[xp[ip]] - 1;
                }
            }
        }
    }
    
};