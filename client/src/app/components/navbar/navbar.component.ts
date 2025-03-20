import { Component, EventEmitter, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { SearchService } from '../../services/search.service';
import { SidebarService } from '../../services/sidebar.service';

@Component({
  selector: 'app-navbar',
  imports: [FormsModule],
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.scss'],
  standalone: true
})
export class NavbarComponent {
  searchQuery: string = '';
  @Output() searchQueryChanged = new EventEmitter<string>();

  constructor(
    private router: Router,
    private searchService: SearchService,
    private sidebarService: SidebarService,
  ) {}

  toggleSidebar() {
    this.sidebarService.toggleSidebar();
  }

  logout() {
    localStorage.removeItem('authToken');
    this.router.navigate(['/login']);
  }

  onSearchQueryChange(event: Event): void {
    const inputElement = event.target as HTMLInputElement;
    this.searchQuery = inputElement.value;
    this.searchService.setSearchQuery(this.searchQuery);
  }
}
