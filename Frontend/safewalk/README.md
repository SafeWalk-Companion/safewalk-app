# Run on iOS

## Create an iPhone Simulator Device

Make sure you have installed the correct iOS version (in this case 26.2). Change the following code according to your iOS version

```
xcrun simctl create "iPhone 16e 26.2" com.apple.CoreSimulator.SimDeviceType.iPhone-16 com.apple.CoreSimulator.SimRuntime.iOS-26-2
```

## List available devices & run Simulator

```xcrun simctl list devices```

Select the ID from the device you want to emulate and run 

```
open -a Simulator --args -CurrentDeviceUDID <your-device-id>
```

with your id instead of ```<your-device-id>```.

When running ```flutter devices``` you should now see the emulator

## Running the app on the device

Copy the Device id listed in ```flutter devices``` and run

```
flutter run -d <your-device-id>
```
with your device id.

For hot-reload press ```r``` in the terminal.
