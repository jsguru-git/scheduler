$(function() {

    // Show / hide elements if JS is turned on
    $('.js_show').show();
    $('.js_hide').hide();

    var main_pricing = $('.pricing_inner').PricingSelect();
    main_pricing.init();

	
	
	// If homepage
	if ($("#pages_index").length > 0){
		
		// Pre load images
		$(['assets/front/pages/home/slide/schedule/ipad.png',
		'assets/front/pages/home/slide/quote/ipad.png',
	    'assets/front/pages/home/slide/track/mac.png',
	    'assets/front/pages/home/slide/invoice/ipad.png',
	    'assets/front/pages/home/slide/slide1.jpg',
		'assets/front/pages/home/slide/slide2.jpg',
		'assets/front/pages/home/slide/slide3.jpg',
		'assets/front/pages/home/slide/slide4.jpg']).preload();
		
		/**
		 * Before cycle callback
		 */
		$( '#slide_container' ).on( 'cycle-before', function( event, opts ) {
		    $('.animate').each(function(){
				$(this).removeClass("animate");
			});

			$(".slide_" + opts.nextSlide).addClass('animate');
		});
	}
	
});

