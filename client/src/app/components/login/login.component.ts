import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../auth.service';
import { WebSocketService } from '../../services/web-socket.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {
  email: string = '';
  password: string = '';
  errorMessage: string = '';

  showResendModal: boolean = false;
  resendEmail: string = '';

  private errorMessages: Record<number, string> = {
    400: 'Solicitud inválida. Verifique los datos ingresados.',
    401: 'Credenciales inválidas.',
    404: 'El email no existe.',
    422: 'El usuario ya se encuentra confirmado.',
  };

  constructor(
    private authService: AuthService,
    private router: Router,
    private webSocketService: WebSocketService,
  ) {}

  login() {
    if (!this.email || !this.password) {
      this.errorMessage = 'Por favor, complete todos los campos';
      return;
    }

    this.authService.login(this.email, this.password).subscribe({
      next: (response) => {
        if (response.data.access_token) {
          localStorage.setItem('authToken', response.data.access_token);
          this.webSocketService.connect();
        }
        this.router.navigate(['/channels']);
      },
      error: (response) => {
        this.errorMessage = this.errorMessages[response.status] || 'Ocurrió un error inesperado.';

        console.error('Error en el login:', response);
      },
    });
  }

  goToSignup() {
    this.router.navigate(['/signup']);
  }

  openResendModal() {
    this.showResendModal = true;
  }

  closeResendModal() {
    this.showResendModal = false;
    this.resendEmail = '';
  }

  resendConfirmationLink() {
    if (!this.resendEmail) {
      this.errorMessage = 'Por favor ingrese un email.';
      return;
    }

    this.authService.resendConfirmationLink(this.resendEmail).subscribe({
      next: () => {
        alert('Link de confirmación reenviado.');
        this.closeResendModal();
      },
      error: (response) => {
        this.errorMessage = this.errorMessages[response.status] || 'Ocurrió un error inesperado.';

        this.closeResendModal();

        console.error('Error al reenviar link de confirmación:', response);
      },
    });
  }
}
