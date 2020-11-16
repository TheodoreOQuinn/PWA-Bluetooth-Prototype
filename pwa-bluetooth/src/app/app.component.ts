import { Component } from '@angular/core';
import { BluetoothCore, consoleLoggerServiceConfig } from '@manekinekko/angular-web-bluetooth';
import { Observable } from 'rxjs';
import { map, mergeMap } from 'rxjs/operators';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  static GATT_CHARACTERISTIC_BATTERY_LEVEL = 'battery_level';
  static GATT_PRIMARY_SERVICE = 'battery_service';

  title = 'pwa-bluetooth';
  private batteryLevel$: Observable<number>;
  public server: BluetoothRemoteGATTServer;
  public batteryLevel: number;


  constructor(private bleCore: BluetoothCore) {}

  public discoverAnyDevice() {
    this.batteryLevel$ = this.bleCore.discover$(
      {acceptAllDevices: true, optionalServices: ['battery_service']}
      ).pipe(

        // 2) get that service
        mergeMap((gatt: BluetoothRemoteGATTServer) => {
          return this.bleCore.getPrimaryService$(gatt, AppComponent.GATT_PRIMARY_SERVICE);
        }),

        // 3) get a specific characteristic on that service
        mergeMap((primaryService: BluetoothRemoteGATTService) => {
          return this.bleCore.getCharacteristic$(primaryService, AppComponent.GATT_CHARACTERISTIC_BATTERY_LEVEL);
        }),

        // 4) ask for the value of that characteristic (will return a DataView)
        mergeMap((characteristic: BluetoothRemoteGATTCharacteristic) => {
          return this.bleCore.observeValue$(characteristic);
        }),

        // 5) on that DataView, get the right value
        map((value: DataView) => value.getUint8(0))
      );

    this.batteryLevel$.subscribe(n => {
        this.batteryLevel = n;
        console.log(n);
      });
  }
}
