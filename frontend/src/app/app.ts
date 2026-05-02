import { HttpClient } from '@angular/common/http';
import { Component, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';

type WeatherForecast = {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
};

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  private readonly httpClient = inject(HttpClient);
  private readonly apiUrl = 'https://backend.marmil.co/weatherforecast';

  protected readonly title = signal('Weather Console');
  protected readonly isLoading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forecasts = signal<WeatherForecast[]>([]);

  constructor() {
    void this.loadForecast();
  }

  protected async loadForecast(): Promise<void> {
    this.isLoading.set(true);
    this.error.set(null);

    try {
      const forecasts = await firstValueFrom(
        this.httpClient.get<WeatherForecast[]>(this.apiUrl),
      );

      this.forecasts.set(forecasts);
    } catch {
      this.error.set('Could not load data from the backend API.');
      this.forecasts.set([]);
    } finally {
      this.isLoading.set(false);
    }
  }
}
