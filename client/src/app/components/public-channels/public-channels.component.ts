// import { Component, OnInit } from '@angular/core';
// import { CommonModule } from '@angular/common';
// import { FormsModule } from '@angular/forms';
// import { WebSocketService } from '../../services/web-socket.service'; // Asumimos que tienes un servicio para manejar WS

// @Component({
//   selector: 'app-public-channels',
//   standalone: true,
//   imports: [CommonModule, FormsModule],
//   templateUrl: './public-channels.component.html',
//   styleUrls: ['./public-channels.component.scss']
// })
// export class PublicChannelsComponent implements OnInit {
//   publicChannels: any[] = [];
//   showCreateModal: boolean = false;
//   newChannelName: string = '';
//   newChannelDescription: string = '';
//   errorMessage: string = '';

//   constructor(private wsService: WebSocketService) {}

//   ngOnInit(): void {
//     // Suscribirse al canal WebSocket "PublicChannelsChannel"
//     this.wsService.subscribeToChannel('PublicChannelsChannel', {}, (data: any) => {
//       // Asumimos que el backend envía un objeto con la propiedad channels que es el listado
//       console.log('Actualización de canales públicos:', data);
//       this.publicChannels = data.channels || [];
//       // Ordenamos los canales por número de miembros activos de forma descendente
//       this.publicChannels.sort((a, b) => b.active_members - a.active_members);
//     });
//   }

//   // Abre el modal para crear un nuevo canal
//   openCreateModal(): void {
//     this.showCreateModal = true;
//   }

//   // Cierra el modal y reinicia los campos
//   closeCreateModal(): void {
//     this.showCreateModal = false;
//     this.newChannelName = '';
//     this.newChannelDescription = '';
//     this.errorMessage = '';
//   }

//   // Envía la creación del nuevo canal por WebSocket
//   createChannel(): void {
//     if (!this.newChannelName) {
//       this.errorMessage = 'El nombre del canal es obligatorio.';
//       return;
//     }
//     // En este ejemplo, usamos el método "perform" del servicio para enviar un mensaje al canal.
//     // El backend debe manejar la acción "create_channel" en PublicChannelsChannel.
//     const payload = {
//       name: this.newChannelName,
//       description: this.newChannelDescription
//     };
//     // this.wsService.perform('create_channel', payload, 'PublicChannelsChannel');

//     // Cerrar el modal (el backend actualizará el listado mediante WebSocket)
//     this.closeCreateModal();
//   }
// }

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
