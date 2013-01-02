/*
 * 	loopedSlider 0.5.5 - jQuery plugin
 *	written by Nathan Searles	
 *	http://nathansearles.com/loopedslider/
 *
 *	Copyright (c) 2009 Nathan Searles (http://nathansearles.com/)
 *	Dual licensed under the MIT (MIT-LICENSE.txt)
 *	and GPL (GPL-LICENSE.txt) licenses.
 *
 *	Built for jQuery library
 *	http://jquery.com
 *	Compatible with jQuery 1.3+
 *
 */

/*
 *	markup example for $("#loopedSlider").loopedSlider();
 *
 *	<div id="loopedSlider">	
 *		<div class="container">
 *			<div class="slides">
 *				<div><img src="01.jpg" alt="" /></div>
 *				<div><img src="02.jpg" alt="" /></div>
 *				<div><img src="03.jpg" alt="" /></div>
 *				<div><img src="04.jpg" alt="" /></div>
 *			</div>
 *		</div>
 *		<a href="#" class="previous">previous</a>
 *		<a href="#" class="next">next</a>	
 *	</div>
 *
*/

(function($) {
	$.fn.loopedSlider = function(options) {
		
	var defaults = {			
		container: ".container", //Class/id of main container. You can use "#container" for an id.
		slides: ".slides", //Class/id of slide container. You can use "#slides" for an id.
		pagination: "pagination", //Class name of parent ul for numbered links. Don't add a "." here.
		containerClick: false, //Click slider to goto next slide? true/false
		autoStart: 0, //Set to positive number for true. This number will be the time between transitions.
		restart: 0, //Set to positive number for true. Sets time until autoStart is restarted.
		slidespeed: 300, //Speed of slide animation, 1000 = 1second.
		fadespeed: 200, //Speed of fade animation, 1000 = 1second.
		autoHeight: 0, //Set to positive number for true. This number will be the speed of the animation.
		addPagination: false //Add pagination links based on content? true/false 
	};
		
	this.each(function() {
		var obj = $(this);
		var o = $.extend(defaults,options);
		var distance = 0;
		var times = 1;
		var slides = $(o.slides,obj).children().size();
		var width = $(o.slides,obj).children().outerWidth();
		var position = 0;
		var active = false;
		var number = 0;
		var interval = 0;
		var restart = 0;
		var pagination = $("."+o.pagination+" li a",obj);

		if(o.addPagination && !$(pagination).length){
			var buttons = slides;
			$(obj).append("<ul class="+o.pagination+">");
			$(o.slides,obj).children().each(function(){
				if (number<buttons) {
					$("."+o.pagination,obj).append("<li><a rel="+(number+1)+" href=\"#\" >"+(number+1)+"</a></li>");
					number = number+1;
				} else {
					number = 0;
					return false;
				}
				$("."+o.pagination+" li a:eq(0)",obj).parent().addClass("active");
			});
			pagination = $("."+o.pagination+" li a",obj);
		} else {
			$(pagination,obj).each(function(){
				number=number+1;
				$(this).attr("rel",number);
				$(pagination.eq(0),obj).parent().addClass("active");
			});
		}
		
		if (slides===1) {
			$(o.slides,obj).children().css({position:"absolute",left:position,display:"block"});
			return;
		}
		
		$(o.slides,obj).css({width:(slides*width)});
		
		$(o.slides,obj).children().each(function(){
			$(this).css({position:"absolute",left:position,display:"block"});
			position=position+width;
		});

		$(o.slides,obj).children(":eq("+(slides-1)+")").css({position:"absolute",left:-width});
		
		if (slides>3) {
			$(o.slides,obj).children(":eq("+(slides-1)+")").css({position:"absolute",left:-width});
		}
		
		if(o.autoHeight){autoHeight(times);}
		
		$(".next",obj).click(function(){
			if(active===false) {
				animate("next",true);
				if(o.autoStart){
					if (o.restart) {autoStart();}
					else {clearInterval(sliderIntervalID);}
				}
			} return false;
		});
		
		$(".previous",obj).click(function(){
			if(active===false) {	
				animate("prev",true);
				if(o.autoStart){
					if (o.restart) {autoStart();}
					else {clearInterval(sliderIntervalID);}
				}
			} return false;
		});
		
		if (o.containerClick) {
			$(o.container,obj).click(function(){
				if(active===false) {
					animate("next",true);
					if(o.autoStart){
						if (o.restart) {autoStart();}
						else {clearInterval(sliderIntervalID);}
					}
				} return false;
			});
		}
		
		$(pagination,obj).click(function(){
			if ($(this).parent().hasClass("active")) {return false;}
			else {
				times = $(this).attr("rel");
				$(pagination,obj).parent().siblings().removeClass("active");
				$(this).parent().addClass("active");
				animate("fade",times);
				if(o.autoStart){
					if (o.restart) {autoStart();}
					else {clearInterval(sliderIntervalID);}
				}
			} return false;
		});
	
		if (o.autoStart) {
			sliderIntervalID = setInterval(function(){
				if(active===false) {animate("next",true);}
			},o.autoStart);
			function autoStart() {
				if (o.restart) {
				clearInterval(sliderIntervalID,interval);
				clearTimeout(restart);
					restart = setTimeout(function() {
						interval = setInterval(	function(){
							animate("next",true);
						},o.autoStart);
					},o.restart);
				} else {
					sliderIntervalID = setInterval(function(){
						if(active===false) {animate("next",true);}
					},o.autoStart);
				}
			};
		}
		
		function current(times) {
			if(times===slides+1){times = 1;}
			if(times===0){times = slides;}
			$(pagination,obj).parent().siblings().removeClass("active");
			$(pagination+"[rel='" + (times) + "']",obj).parent().addClass("active");
		};
		
		function autoHeight(times) {
			if(times===slides+1){times=1;}
			if(times===0){times=slides;}	
			var getHeight = $(o.slides,obj).children(":eq("+(times-1)+")",obj).outerHeight();
			$(o.container,obj).animate({height: getHeight},o.autoHeight);					
		};		
		
		function animate(dir,clicked){	
			active = true;	
			switch(dir){
				case "next":
					times = times+1;
					distance = (-(times*width-width));
					current(times);
					if(o.autoHeight){autoHeight(times);}
					if(slides<3){
						if (times===3){$(o.slides,obj).children(":eq(0)").css({left:(slides*width)});}
						if (times===2){$(o.slides,obj).children(":eq("+(slides-1)+")").css({position:"absolute",left:width});}
					}
					$(o.slides,obj).animate({left: distance}, o.slidespeed,function(){
						if (times===slides+1) {
							times = 1;
							$(o.slides,obj).css({left:0},function(){$(o.slides,obj).animate({left:distance})});							
							$(o.slides,obj).children(":eq(0)").css({left:0});
							$(o.slides,obj).children(":eq("+(slides-1)+")").css({ position:"absolute",left:-width});				
						}
						if (times===slides) $(o.slides,obj).children(":eq(0)").css({left:(slides*width)});
						if (times===slides-1) $(o.slides,obj).children(":eq("+(slides-1)+")").css({left:(slides*width-width)});
						active = false;
					});					
					break; 
				case "prev":
					times = times-1;
					distance = (-(times*width-width));
					current(times);
					if(o.autoHeight){autoHeight(times);}
					if (slides<3){
						if(times===0){$(o.slides,obj).children(":eq("+(slides-1)+")").css({position:"absolute",left:(-width)});}
						if(times===1){$(o.slides,obj).children(":eq(0)").css({position:"absolute",left:0});}
					}
					$(o.slides,obj).animate({left: distance}, o.slidespeed,function(){
						if (times===0) {
							times = slides;
							$(o.slides,obj).children(":eq("+(slides-1)+")").css({position:"absolute",left:(slides*width-width)});
							$(o.slides,obj).css({left: -(slides*width-width)});
							$(o.slides,obj).children(":eq(0)").css({left:(slides*width)});
						}
						if (times===2 ) $(o.slides,obj).children(":eq(0)").css({position:"absolute",left:0});
						if (times===1) $(o.slides,obj).children(":eq("+ (slides-1) +")").css({position:"absolute",left:-width});
						active = false;
					});
					break;
				case "fade":
					times = [times]*1;
					distance = (-(times*width-width));
					current(times);
					if(o.autoHeight){autoHeight(times);}
					$(o.slides,obj).children().fadeOut(o.fadespeed, function(){
						$(o.slides,obj).css({left: distance});
						$(o.slides,obj).children(":eq("+(slides-1)+")").css({left:slides*width-width});
						$(o.slides,obj).children(":eq(0)").css({left:0});
						if(times===slides){$(o.slides,obj).children(":eq(0)").css({left:(slides*width)});}
						if(times===1){$(o.slides,obj).children(":eq("+(slides-1)+")").css({ position:"absolute",left:-width});}
						$(o.slides,obj).children().fadeIn(o.fadespeed);
						active = false;
					});
					break; 
				default:
					break;
				}					
			};
		});
	};
})(jQuery);