import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { RouterModule } from '@angular/router';
import { NavbarComponent } from './components/navbar/navbar.component';
import { CommonModule } from '@angular/common';
import { AuthService } from './auth.service';
import { WebSocketService } from './services/web-socket.service';
import { NotificationService } from './services/notification.service';

@Component({
  selector: 'app-root',
  standalone: true, 
  imports: [CommonModule, RouterModule, NavbarComponent],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnInit {
  title = 'Live Chatting App';
  searchQuery: string = '';

  constructor(
    private router: Router,
    private authService: AuthService,
    private webSocketService: WebSocketService,
    private notificationService: NotificationService
  ) {}

  ngOnInit() {
    const token = localStorage.getItem('authToken') || '';

    if (!token) {
      this.router.navigate(['/login']);
    }

    this.authService.getUser(token).subscribe({
      next: (response) => {
        if (response) {
          this.webSocketService.subscribeToChannel('NotificationsChannel', {}, (notification) => {
            this.notificationService.sendNotification(notification);
          });
          this.router.navigate(['']);
        } 
      },
      error: () => {
        localStorage.removeItem('authToken');
        this.router.navigate(['/login']);
      },
    });
  }

  get showNavbar(): boolean {
    return !(this.router.url === '/login' || this.router.url === '/signup');
  }

  onSearchQueryChanged(searchQuery: string) {
    this.searchQuery = searchQuery; 
  }
}
