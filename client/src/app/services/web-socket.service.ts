import { Injectable } from '@angular/core';
import { Observable, Subject } from 'rxjs';

// @ts-ignore
import { createConsumer, Cable, Subscription } from '@rails/actioncable';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root',
})
export class WebSocketService {
  private cable: Cable | null = null;
  private subscriptions: Map<string, Subscription> = new Map();

  constructor() {
    this.connect();
  }

  connect() {
    const token = localStorage.getItem('authToken');
    if (!token) {
      console.warn('No auth token found, skipping WebSocket connection');
      return;
    }
    this.cable = createConsumer(`${environment.webSocketUrl}?token=${token}`);
  }

  subscribeToChannel<T>(
    channelName: string,
    params: Record<string, any> = {},
    callback: (data: T) => void
  ): void {
    if (!this.cable) {
      console.error('WebSocket connection is not established.');
      return;
    }

    const subscriptionKey = JSON.stringify({ channel: channelName, ...params });

    if (!this.subscriptions.has(subscriptionKey)) {
      const subscription = this.cable.subscriptions.create(
        { channel: channelName, ...params },
        {
          received: (data: T) => callback(data),
          connected: () => console.log(`✅ Connected to ${channelName}`),
          disconnected: () => console.log(`🔴 Disconnected from ${channelName}`),
          rejected: (reason: any) => {
            console.error('Error connecting to channel:', reason);
          },
        }
      );

      this.subscriptions.set(subscriptionKey, subscription);
    }
  }

  getSubscription(channelName: string, params: Record<string, any> = {}): Subscription | null {
    const subscriptionKey = JSON.stringify({ channel: channelName, ...params });
    return this.subscriptions.get(subscriptionKey) || null;
  }

  unsubscribeFromChannel(channelName: string, params: Record<string, any> = {}): void {
    const subscriptionKey = JSON.stringify({ channel: channelName, ...params });

    if (this.subscriptions.has(subscriptionKey)) {
      this.subscriptions.get(subscriptionKey)?.unsubscribe();
      this.subscriptions.delete(subscriptionKey);
      console.log(`🚫 Unsubscribed from ${channelName}`);
    }
  }
}
