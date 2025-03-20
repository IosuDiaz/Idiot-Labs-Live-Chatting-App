import { Component, OnDestroy, OnInit } from '@angular/core';
import { WebSocketService } from '../../services/web-socket.service';
import { CommonModule } from '@angular/common';
import { SidebarSearchService } from '../../services/sidebar-search.service';
import { NotificationService } from '../../services/notification.service';
import { FormsModule } from '@angular/forms';
import { DirectMessageComponent } from '../direct-message/direct-message.component';

export interface PrivateChannel {
  id: number;
  name: string;
}

@Component({
  selector: 'app-sidebar',
  imports: [CommonModule, FormsModule, DirectMessageComponent],
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss']
})
export class SidebarComponent implements OnInit, OnDestroy {
  privateChannels: PrivateChannel[] = [];
  filteredChannels: PrivateChannel[] = [];
  openChats: PrivateChannel[] = [];
  subscriptionKey: string = 'PrivateChannelsChannel'
  searchQuery: string = '';


  constructor(
    private webSocketService: WebSocketService,
    private sidebarSearchService: SidebarSearchService,
    private notificationService: NotificationService,
  ) {
    this.notificationService.notification$.subscribe((notification) => {
      if(notification.success && notification.data.channel) {
        this.privateChannels.unshift(notification.data.channel)
        this.filteredChannels = this.filterChannels(this.searchQuery);
      }
    });
  }

  ngOnInit(): void {
    this.loadPrivateChannels();
  }

  loadPrivateChannels() {
    this.webSocketService.subscribeToChannel<{
      success: boolean;
      type: string;
      data: {
        channels?: PrivateChannel[];
        channel?: PrivateChannel;
      };
      is_broadcast: boolean;
    }>(this.subscriptionKey, {}, (response) => {
      if (response && response.success) {
        const channelData = response.data;
    
        if (channelData.channels) {
          this.privateChannels = channelData.channels;
        }

        if (channelData.channel && response.is_broadcast) {
          this.privateChannels.unshift(channelData.channel);
        }

        this.sidebarSearchService.searchQuery$.subscribe(query => {
          this.filteredChannels = this.filterChannels(query);
        });
      } else {
        console.error('Error en la respuesta de WebSocket: No se pudo obtener los canales');
      }
    });

    setTimeout(() => {
      const subscription = this.webSocketService.getSubscription(this.subscriptionKey);
      if (subscription) {
        subscription.perform('list_private_channels');
      }
    }, 500);
  }

  onSearchQueryChange(query: string): void {
    this.sidebarSearchService.setSearchQuery(query);
  }

  joinChannel(channel: PrivateChannel) {
    if (!this.openChats.some(chat => chat.id === channel.id)) {
      this.openChats.push(channel);
    }
  }

  closeChat(channel: PrivateChannel) {
    this.openChats = this.openChats.filter(chat => chat.id !== channel.id);
  }

  ngOnDestroy(): void {
    this.webSocketService.unsubscribeFromChannel(this.subscriptionKey);
  }

  private filterChannels(query: string): any[] {
    return this.privateChannels.filter(channel =>
      channel.name.toLowerCase().includes(query.toLowerCase() || '')
    );
  }
}
