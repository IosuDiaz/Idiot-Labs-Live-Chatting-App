import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment';
import { Observable, Subject } from 'rxjs';

// @ts-ignore
import { createConsumer, Cable } from '@rails/actioncable';

@Injectable({
  providedIn: 'root',
})
export class WebSocketService {
  private cable: Cable | null = null;
  private subscriptions: { [key: string]: any } = {};

  constructor() {
    this.connect();
  }

  private connect() {
    const token = localStorage.getItem('authToken');
    if (!token) {
      console.warn('No auth token found, skipping WebSocket connection');
      return;
    }

    this.cable = createConsumer(`${environment.webSocketUrl}/cable?token=${token}`);
  }

  subscribeToChannel(channelName: string, params = {}, callback: (data: any) => void) {
    if (!this.cable) {
      console.error('WebSocket connection is not established.');
      return;
    }

    const subscriptionKey = JSON.stringify({ channel: channelName, ...params });

    if (!this.subscriptions[subscriptionKey]) {
      this.subscriptions[subscriptionKey] = this.cable.subscriptions.create(
        { channel: channelName, ...params },
        {
          received: (data: any) => callback(data),
          connected: () => console.log(`Connected to ${channelName}`),
          disconnected: () => console.log(`Disconnected from ${channelName}`),
        }
      );
    }
  }

  unsubscribeFromChannel(channelName: string, params = {}) {
    const subscriptionKey = JSON.stringify({ channel: channelName, ...params });

    if (this.subscriptions[subscriptionKey]) {
      this.subscriptions[subscriptionKey].unsubscribe();
      delete this.subscriptions[subscriptionKey];
      console.log(`Unsubscribed from ${channelName}`);
    }
  }
}
