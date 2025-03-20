import { Component, Input, OnInit, OnDestroy, AfterViewChecked, ViewChild, ElementRef, Output, EventEmitter } from '@angular/core';
import { WebSocketService } from '../../services/web-socket.service';
import { PrivateChannel } from '../sidebar/sidebar.component';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

interface Message {
  id: number;
  content: string;
  sender: {
    id: number;
    nickname: string;
  }
  created_at: string
}

@Component({
  selector: 'app-direct-message',
  imports: [CommonModule, FormsModule],
  templateUrl: './direct-message.component.html',
  styleUrls: ['./direct-message.component.scss']
})
export class DirectMessageComponent implements OnInit, OnDestroy, AfterViewChecked {
  @Input() channel!: PrivateChannel;
  @Output() close = new EventEmitter<PrivateChannel>();
  messages: Message[] = [];
  newMessage: string = '';
  subscriptionKey: string = 'DirectMessageChannel';
  @ViewChild('chatBody') chatBody: ElementRef | undefined;


  constructor(private webSocketService: WebSocketService) {}

  ngOnInit(): void {
    this.webSocketService.subscribeToChannel<{
      success: boolean;
      type: string;
      data: {
        channels?: PrivateChannel[];
        message?: Message;
      };
      is_broadcast: boolean;
    }>(this.subscriptionKey, { channel_id: this.channel.id }, (response) => {
      if (response && response.success && response.data.message) {
        this.messages.push(response.data.message);
      }
    });
  }

  sendMessage(event: Event): void {
    event.preventDefault();

    if (this.newMessage && this.newMessage.trim()) {
      const subscription = this.webSocketService.getSubscription(this.subscriptionKey, { channel_id: this.channel.id });
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
    // Desuscribirse del canal cuando se cierra el chat
    this.webSocketService.unsubscribeFromChannel(this.subscriptionKey, { channel_id: this.channel.id });
  }

  closeChat() {
    if (this.channel) {
      this.close.emit(this.channel);
    }
  }

  private scrollToBottom() {
    if (this.chatBody) {
      const container = this.chatBody.nativeElement;
      container.scrollTop = container.scrollHeight;
    }
  }
}
