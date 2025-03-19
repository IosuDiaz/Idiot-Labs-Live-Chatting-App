import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { SignupComponent } from './components/signup/signup.component';
import { PublicChannelsComponent } from './components/public-channels/public-channels.component';

export const routes: Routes = [
  { path: '', component: PublicChannelsComponent },
  { path: 'login', component: LoginComponent },
  { path: 'signup', component: SignupComponent }
];
