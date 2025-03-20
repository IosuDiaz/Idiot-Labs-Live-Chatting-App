import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  login(email: string, password: string): Observable<any> {
    return this.http.post(`${this.apiUrl}/login`, { email, password });
  }

  signup(user: { nickname: string, email: string, password: string }): Observable<any> {
    return this.http.post(`${this.apiUrl}/signup`, { user: user });
  }

  resendConfirmationLink(email: string): Observable<any> {
    return this.http.post(`${this.apiUrl}/users/resend_confirmation`, { email });
  }

  getUser(token: string): Observable<any> {
    const headers = new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
    return this.http.get(`${this.apiUrl}/users`, { headers });
  }
}
