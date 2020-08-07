import consumer from "./consumer"

consumer.subscriptions.create("RoomChannel", {
  connected() {
		$( '.responses-chat' ).animate({ scrollTop: $( '.responses-chat' ).prop("scrollHeight")}, 0);
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
		const userIdElement = document.getElementById('user-id')
		const user_id = Number(userIdElement.getAttribute('data-user-id'))
		
		let html;
		
		if (user_id == data.message.user_id){
			html = data.current_user_message
		} else {
			html = data.other_users_message
		}
		
		const messageContainer = document.getElementById('messages')
		messageContainer.innerHTML = messageContainer.innerHTML + html
		$( '.responses-chat' ).animate({ scrollTop: $( '.responses-chat' ).prop("scrollHeight")}, 200);
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