$(document).ready(function() {			
	$('#showExamples').click(function(e){
		e.stopPropagation();
		e.preventDefault();
		$('#examplesList').toggle();
	});
	
	$('html').click(function(){
		$('#examplesList').hide();
	});
});