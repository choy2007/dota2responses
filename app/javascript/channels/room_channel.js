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
		const messageContainer = document.getElementById( 'messages' )
		
		let html;
		
		if (user_id != data.message.user_id){
			html = data.other_users_message
			messageContainer.innerHTML = messageContainer.innerHTML + html
		} else {
			html = data.current_user_message
			
			if ($( '.message-row' ).length == 0){
				messageContainer.innerHTML = messageContainer.innerHTML + html
			} else {
				$( '.message-row' ).last().replaceWith(html)
			}
		}
		$( '.responses-chat' ).animate({ scrollTop: $( '.responses-chat' ).prop( 'scrollHeight' )}, 500);
  }
});

$( document ).on( 'turbolinks:load', function(){
	$( '#hero-responses-loading' ).hide();
	$( '#chat-wheel-responses-loading' ).hide();
	
	$( '#hero' ).on( 'change', function(){
		$.ajax({
			url: '/responses?name=' + $(this).val(),
			type: 'GET',
			beforeSend: function() {
	    	$( '#hero-responses-loading' ).show();
	    },
			success: function() {
				$( '#hero-responses-loading' ).hide();
			}
		})
	})
	
	$( '#event' ).on( 'change', function(){
		$.ajax({
			url: '/chat_wheel?name=' + $(this).val(),
			type: 'GET',
			beforeSend: function() {
	    	$( '#chat-wheel-responses-loading' ).show();
	    },
			success: function() {
				$(' #chat-wheel-responses-loading' ).hide();
			}
		})
	})
})

$(document).on( 'click', 'button[name="message[content]"]', function(){
	let response = $(this).val()
	let html = "<div class='row message-row'>\n<div class='col-3 offset-9'>\n<div class='message mb-3 float-right'>\n<div class='current-user-content float-right'>\n"+ $(this).val()+ "\n</div>\n<br>"
	
	const messageContainer = document.getElementById( 'messages' )
	messageContainer.innerHTML = messageContainer.innerHTML + html
	$( '.responses-chat' ).animate({ scrollTop: $( '.responses-chat' ).prop( 'scrollHeight' )}, 200);
});