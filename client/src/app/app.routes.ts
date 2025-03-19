import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { SignupComponent } from './components/signup/signup.component';
import { PublicChannelsComponent } from './components/public-channels/public-channels.component';
import { PublicChannelComponent } from './components/public-channel/public-channel.component';
import { AppComponent } from './app.component';


export const routes: Routes = [
  { path: '', component: PublicChannelsComponent },
  { path: 'channels', component: PublicChannelsComponent },
  { path: 'channel/:channelId', component: PublicChannelComponent },
  { path: 'login', component: LoginComponent },
  { path: 'signup', component: SignupComponent }
];
