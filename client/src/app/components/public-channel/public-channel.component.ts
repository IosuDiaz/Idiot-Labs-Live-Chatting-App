import { ActivatedRoute } from '@angular/router';
import { WebSocketService } from '../../services/web-socket.service';
import { Component, OnInit, OnDestroy, ViewChild, ElementRef, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

interface Message {
  id: number;
  content: string;
  sender: {
    id: string,
    nickname: string,
  };
  created_at: string;
}

interface User {
  id: number;
  nickname: string;
}

const MESSAGE_TYPES = {
  USER_JOINED: 'user_joined',
  USER_LEFT: 'user_left',
  NEW_MESSAGE: 'new_message',
  LIST_USERS: 'channel_users',
};

@Component({
  selector: 'app-channel',
  imports: [CommonModule, FormsModule],
  templateUrl: './public-channel.component.html',
  styleUrls: ['./public-channel.component.scss'],
})
export class PublicChannelComponent implements OnInit, OnDestroy, AfterViewChecked {
  messages: Message[] = [];
  users: User[] = [];
  channelId!: number;
  subscriptionKey: string = 'ChatChannel';
  newMessage: string = '';

  errorMessage: string = '';

  @ViewChild('messagesContainer') messagesContainer: ElementRef | undefined;

  constructor(
    private route: ActivatedRoute,
    private webSocketService: WebSocketService
  ) {}

  ngOnInit(): void {
    this.route.params.subscribe(params => {
      this.channelId = +params['channelId'];
      this.subscribeToChannel();
      this.listUsers();
    });
  }

  listUsers() {
    setTimeout(() => {
      const subscription = this.webSocketService.getSubscription(this.subscriptionKey, { channel_id: this.channelId });
      if (subscription) {
        subscription.perform('list_users');
      }
    }, 500);
  }

  subscribeToChannel() {
    this.webSocketService.subscribeToChannel<{
      success: boolean;
      type: string;
      data: {
        message?: Message;
        user?: User;
        users?: User[];
      };
      is_broadcast: boolean;
    }>(this.subscriptionKey, { channel_id: this.channelId}, (response) => {
      if (response && response.success) {
        const handler = this.messageHandlers[response.type];

        if (handler) {
          handler(response.data);
        } else {
          console.error(`No se encontró un manejador para el tipo de mensaje: ${response.type}`);
        }

      } else {
        console.error('Error en la respuesta de WebSocket: No se pudo obtener los canales');
      }
    });
  }

  sendMessage() {
    if (this.newMessage && this.newMessage.trim()) {
      const subscription = this.webSocketService.getSubscription('ChatChannel', {channel_id: this.channelId});
      if (subscription) {
        subscription.perform('receive', { content: this.newMessage });
      }
      this.newMessage = ''
    }
  }

  ngAfterViewChecked() {
    this.scrollToBottom();
  }

  ngOnDestroy(): void {
    this.webSocketService.unsubscribeFromChannel(this.subscriptionKey, { channel_id: this.channelId });
  }

  private messageHandlers: { [key: string]: (data: any) => void } = {
    [MESSAGE_TYPES.USER_JOINED]: this.handleUserJoined.bind(this),
    [MESSAGE_TYPES.USER_LEFT]: this.handleUserLeft.bind(this),
    [MESSAGE_TYPES.NEW_MESSAGE]: this.handleNewMessage.bind(this),
    [MESSAGE_TYPES.LIST_USERS]: this.handleListUsers.bind(this),
  };

  private handleUserJoined(data: any) {
    if (data.user) {
      this.users.push(data.user);
    }
  }

  private handleUserLeft(data: any) {
    if (data.user) {
      this.users = this.users.filter(user => user.id !== data.user.id);
    }
  }

  private handleNewMessage(data: any) {
    if (data.message) {
      this.messages.push(data.message);
    }
  }

  private handleListUsers(data: any) {
    if (data.users) {
      this.users = data.users;
    }
  }

  private scrollToBottom() {
    if (this.messagesContainer) {
      const container = this.messagesContainer.nativeElement;
      container.scrollTop = container.scrollHeight;
    }
  }
}
