import { Component, OnInit, OnDestroy } from '@angular/core';
import { WebSocketService } from '../../services/web-socket.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SearchService } from '../../services/search.service';

interface PublicChannel {
  id: number;
  name: string;
  description: string;
  members_count: number;
  last_activity: string;
}

@Component({
  selector: 'app-public-channels',
  imports: [CommonModule, FormsModule],
  standalone: true,
  templateUrl: './public-channels.component.html',
  styleUrls: ['./public-channels.component.scss'],
})
export class PublicChannelsComponent implements OnInit, OnDestroy {
  publicChannels: PublicChannel[] = [];
  private subscriptionKey = 'PublicChannelsChannel';
  showCreateChannelModal: boolean = false;
  newChannelName: string = '';
  newChannelDescription: string = '';
  errorMessage: string = '';


  filteredChannels: PublicChannel[] = [];


  constructor(
    private webSocketService: WebSocketService,
    private searchService: SearchService
  ) {}

  ngOnInit() {
    this.webSocketService.subscribeToChannel<{
      success: boolean;
      type: string;
      data: {
        channels?: PublicChannel[];
        channel?: PublicChannel;
      };
      is_broadcast: boolean;
    }>(this.subscriptionKey, {}, (response) => {
      if (response && response.success) {
        const channelData = response.data;
    
        if (channelData.channels) {
          this.publicChannels = channelData.channels;

          this.searchService.searchQuery$.subscribe(query => {
            this.filteredChannels = this.filterChannels(query);
          });
        }
    
        if (channelData.channel && response.is_broadcast) {
          this.publicChannels.push(channelData.channel);
        }
      } else {
        console.error('Error en la respuesta de WebSocket: No se pudo obtener los canales');
      }
    });

    setTimeout(() => {
      const subscription = this.webSocketService.getSubscription(this.subscriptionKey);
      if (subscription) {
        subscription.perform('list_public_channels');
      }
    }, 500);
  }

  filterChannels(query: string): any[] {
    return this.publicChannels.filter(channel =>
      channel.name.toLowerCase().includes(query.toLowerCase() || '')
    );
  }

  openCreateChannelModal() {
    this.showCreateChannelModal = true;
  }

  closeCreateChannelModal() {
    this.showCreateChannelModal = false;
    this.newChannelName = '';
    this.newChannelDescription = '';
    this.errorMessage = '';
  }

  createChannel() {
    if (!this.newChannelName) {
      this.errorMessage = 'Por favor, ingrese el nombre del canal.';
      return;
    }

    const subscription = this.webSocketService.getSubscription('PublicChannelsChannel');
    if (subscription) {
      subscription.perform('create_public_channel', { name: this.newChannelName, description: this.newChannelDescription });
      this.errorMessage = '';
      this.closeCreateChannelModal();
    }
  }

  onSearchQueryChanged(query: string): void {
    this.searchService.setSearchQuery(query);
  }


  joinChannel(channelId: number) {
    
  }

  ngOnDestroy() {
    this.webSocketService.unsubscribeFromChannel(this.subscriptionKey);
  }
}
