import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { RouterModule } from '@angular/router';
import { NavbarComponent } from './components/navbar/navbar.component';
import { CommonModule } from '@angular/common';
import { AuthService } from './auth.service';

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

  constructor(private router: Router, private authService: AuthService) {}

  ngOnInit() {
    const token = localStorage.getItem('authToken') || '';

    if (!token) {
      this.router.navigate(['/login']);
    }

    this.authService.getUser(token).subscribe({
      next: (response) => {
        if (response.status == '200') {
          localStorage.setItem('authToken', response.data.access_token);
        }
        this.router.navigate(['']);
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
