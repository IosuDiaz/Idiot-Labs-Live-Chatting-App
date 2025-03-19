import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../auth.service';

@Component({
  selector: 'app-signup',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './signup.component.html',
  styleUrls: ['./signup.component.scss'],
})
export class SignupComponent {
  nickname: string = '';
  email: string = '';
  password: string = '';
  errorMessage: string = '';

  constructor(private authService: AuthService, public router: Router) {} // 

  createAccount() {
    const user = {
      nickname: this.nickname,
      email: this.email,
      password: this.password,
    };
  
    this.authService.signup(user).subscribe({
      next: (response) => {
        console.log('Usuario registrado con éxito:', response);
        this.router.navigate(['/login']);
      },
      error: (response) => {
        this.errorMessage = 'Hubo un error al crear la cuenta.';
        console.error('Error al crear la cuenta:', response);
        
        if (response.error.errors) {
          this.fieldErrors = response.error.errors;
        }
      },
    });
  }
  
  fieldErrors: { [key: string]: string[] } = {};
}
