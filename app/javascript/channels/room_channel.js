import consumer from "./consumer"

consumer.subscriptions.create("RoomChannel", {
  connected() {
		$( '.responses-chat' ).animate({ scrollTop: $( '.responses-chat' ).prop( 'scrollHeight' )}, 0);
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
		const userIdElement = document.getElementById( 'user-id' )
		const user_id = Number(userIdElement.getAttribute( 'data-user-id' ))
		
		let html;
		
		if (user_id != data.message.user_id){
			html = data.other_users_message
		} else {
			return
		}
	
		const messageContainer = document.getElementById( 'messages' )
		messageContainer.innerHTML = messageContainer.innerHTML + html
		$( '.responses-chat' ).animate({ scrollTop: $( '.responses-chat' ).prop( 'scrollHeight' )}, 200);
  }
});

$( document ).on( 'turbolinks:load', function(){
	$( '#hero' ).on( 'change', function(){
		$.ajax({
			url: '/responses?name=' + $(this).val(),
			type: 'GET'
		})
	})
	
	$( '#event' ).on( 'change', function(){
		$.ajax({
			url: '/chat_wheel?name=' + $(this).val(),
			type: 'GET'
		})
	})
})

$(document).on( 'click', 'button[name="message[content]"]', function(){
	let response = $(this).val()
	let html = "<div class='row'>\n<div class='col-3 offset-9'>\n<div class='message mb-3 float-right'>\n<div class='current-user-content float-right'>\n"+ $(this).val()+ "\n</div>\n<br>\n<small class='sender font-weight-light float-right'>\nGeneRaL\n</small>\n</div>\n</div>\n</div>\n"
	
	const messageContainer = document.getElementById( 'messages' )
	messageContainer.innerHTML = messageContainer.innerHTML + html
	$( '.responses-chat' ).animate({ scrollTop: $( '.responses-chat' ).prop( 'scrollHeight' )}, 200);
});