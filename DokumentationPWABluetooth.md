# Dokumentation PWA Bluetooth

Da das MF Wiki gerade nicht erreichbar ist, werde ich alle meine Erkenntnisse bis jetzt mal hier zusammenfassen.



Wichtige Punkte

- PWA
  - Wie habe ich deployed?
  - Welche APIs und Libraries habe ich benützt?
- Alter Dongle (Done)
  - Festhalten weshalb er nicht funktioniert hat.
- Allgemeine Erkenntnisse über BLE (Done)
- Raspery PI
  - User/ PWD festhalten. (Done)
  - Wie habe ich mit dem Raspberry Pi gearbeitet (done)
    - Putty
    - WinSCP
    - Advanced IP Scanner
  - Erkenntnis über BlueZ und DBus (Blogpost) (done)
  - Pythonbeispielcode Verlinken (done)
- Festhalten, dass Beispieldemo funktioniert hat.

## Grundwissen über Bluetooth Low Energy (BLE)

Dieser Artikel hat mir weitergeholfen. 

https://learn.adafruit.com/introduction-to-bluetooth-low-energy

Neu war für mich, dass zuerst mit GAP eine Verbindung gemacht werden muss.
Bei GAP ist auch wichtig, dass man die richtige Terminologie benutzt und versteht, was Peripheral und was Central Devices sind.

Dann erst kann man mit GATT kommunizieren. Dieses Bild hilft beim Verständnis der Hierarchie:

![microcontrollers_GattStructure](microcontrollers_GattStructure.png)

Die App nRF Connect war nützlich, um zu testen, ob es generell möglich ist, sich mit einem Peripheral zu verbinden:

https://play.google.com/store/apps/details?id=no.nordicsemi.android.mcp&hl=en_US&gl=US

## PWA

### Wie wird deployed?

Momentan funktioniert es mit deployall.ps1 in C:\Users\was\source\hackserver.
Weitere Infos im README.md im gleichen Ordner. 

TODO:

- Gingen jetzt mit der Erkenntnis des webconfigs. Auch noch andere Varianten?

### Welche Libraries werden benützt?

Ich den Angular App habe den PWA Support hinzugefügt:

https://angular.io/guide/service-worker-getting-started

Und dann diese Angular Bluetooth Library benützt:

https://github.com/manekinekko/angular-web-bluetooth

Damit eine PWA App richtig funktioniert, muss sie deployed werden oder mit den folgenden Befehlen lokal gestartet werden:

```shell
ng build --prod
http-server -p 8080 -c-1 dist/pwa-bluetooth
```

TODO:

- Achtung das Manifest habe ich in ein JSON umbenannt.
- Kann man das Deployment und den Code besser zusammennehmen in ein Repo?

## Erkenntnisse von Versuch mit BC04-B Bluetooth Modul

In der Spezifikation ([Link aus der Doku](http://www.suptronics.com/downloads/BC04-B Technical specification.pdf)) heisst es, dass Bluetooth V2.1+EDR unterstützt wird.

PWA kann aber nur BLE/ GATT. Der [Wikipediaartikel ](https://en.wikipedia.org/wiki/Bluetooth_Low_Energy)von BLE, sagt, dass BLE und Bluetooth BR/EDR nicht kompatibel sind.

## Zweiter Versuch mit Raspberry Pi 4 Model B

In zweiten Versuch wurde versucht das BLE Peripheral Device auf einem Raspberry Pi zu betreiben.

TODO:

- Welches Operating System und mit welchem Programm haben wird das geflasht?

Dannach wurde das Raspberry Pi nur über ssh angesprochen. (user: pi, pw: pi2020mf )

Für das wurde mit [Advanced IP Scanner](https://www.advanced-ip-scanner.com/) jeweils die IP bestimmt.
Mit [Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) wurden normale SSH Sessions gemacht.
Und Dateien wurden mit [WinSCP](https://winscp.net/eng/download.php) auf das Gerät geladen.

Bei dem Versuch ein Bluetooth Peripheral auf dem Rasperberry Pi aufzusetzten hat mir der folgende Blogpost sehr geholfen:

https://punchthrough.com/creating-a-ble-peripheral-with-bluez/

Es wird den Bluetooth stack für Linux erwähnt: BlueZ. Dieser kann über den D-Bus angesprochen werden. Dafür gibt eine ein Python Modul (dbus)

Aufgrund dieser Erkenntnisse habe ich den folgenden Code auf dem Raspberry Pi laufen lassen:

https://github.com/Jumperr-labs/python-gatt-server

Dieser Simuliert eine Battery die alle paar Sekunden weniger geladen ist.

Dieser Wert konnte vom Webapi Beispielprojekt von Google Chrome ausgelesen werden:
https://googlechrome.github.io/samples/web-bluetooth/battery-level.html

Was in diesem Code aber nicht gemacht wird, ist ein wiederholtes auslesen des gleichen Werts.