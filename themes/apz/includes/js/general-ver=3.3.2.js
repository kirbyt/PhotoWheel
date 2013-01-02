// JavaScript Document


jQuery(document).ready(function() {

	jQuery('.widget li ul li').css('border-bottom','none').css('padding-bottom','0');
	
	jQuery('#feature-media div.block:last').addClass('last');
	
	//FORMS
	var name = jQuery('#contactName').val();
	var commentname = jQuery('#author').val();
	var url = jQuery('#url').val();
	var email = jQuery('#email').val();
	
	if (name == '') { jQuery('#contactName').val('Name') };
	if (commentname == '') { jQuery('#author').val('Name') };
	if (url == '') { jQuery('#url').val('Website URL') };
	if (email == '') { jQuery('#email').val('Email') };
	
	jQuery('#contactName').focus(function() {
		var val = jQuery(this).val();
		if(val == 'Name'){	jQuery(this).val(''); }
	});
	
	jQuery('#contactName').blur(function() {
		var val = jQuery(this).val();
		if(val == ''){	jQuery(this).val('Name'); }
	});
	
	jQuery('#email').focus(function() {
		var val = jQuery(this).val();	
		if(val == 'Email'){ jQuery(this).val(''); }
	});
	
	jQuery('#email').blur(function() {
		var val = jQuery(this).val();	
		if(val == ''){ jQuery(this).val('Email'); }
	});
	jQuery('#author').focus(function() {
		var val = jQuery(this).val();	
		if(val == 'Name'){ jQuery(this).val(''); }
	});
	
	jQuery('#author').blur(function() {
		var val = jQuery(this).val();	
		if(val == ''){ jQuery(this).val('Name'); }
	});
	jQuery('#url').focus(function() {
		var val = jQuery(this).val();	
		if(val == 'Website URL'){ jQuery(this).val(''); }
	});
	
	jQuery('#url').blur(function() {
		var val = jQuery(this).val();	
		if(val == ''){ jQuery(this).val('Website URL'); }
	});	
});