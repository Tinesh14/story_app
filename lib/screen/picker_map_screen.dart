// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class PickerScreen extends StatefulWidget {
  LatLng defaultLocation;
  Function(geo.Placemark, LatLng) onSetPicker;
  PickerScreen({
    super.key,
    required this.defaultLocation,
    required this.onSetPicker,
  });

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  late GoogleMapController mapController;

  late final Set<Marker> markers = {};

  geo.Placemark? placemark;
  LatLng? setLatLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
      ),
      body: Center(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                zoom: 18,
                target: widget.defaultLocation,
              ),
              markers: markers,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              onMapCreated: (controller) async {
                final info = await geo.placemarkFromCoordinates(
                    widget.defaultLocation.latitude,
                    widget.defaultLocation.longitude);

                final place = info[0];
                final street = place.street!;
                final address =
                    '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

                setState(() {
                  placemark = place;
                  setLatLng = LatLng(widget.defaultLocation.latitude,
                      widget.defaultLocation.longitude);
                });

                defineMarker(widget.defaultLocation, street, address);

                setState(() {
                  mapController = controller;
                });
              },
              onLongPress: (LatLng latLng) => onLongPressGoogleMap(latLng),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                child: const Icon(Icons.my_location),
                onPressed: () => onMyLocationButtonPress(),
              ),
            ),
            if (placemark == null)
              const SizedBox()
            else
              Positioned(
                bottom: 16,
                right: 16,
                left: 16,
                child: PlacemarkWidget(
                  placemark: placemark!,
                  setPlacemark: (p0) {
                    widget.onSetPicker.call(p0, setLatLng!);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void onLongPressGoogleMap(LatLng latLng) async {
    final info =
        await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    final place = info[0];
    final street = place.street!;
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    setState(() {
      placemark = place;
      setLatLng = latLng;
    });
    defineMarker(latLng, street, address);
    mapController.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }

  void onMyLocationButtonPress() async {
    final Location location = Location();
    late bool serviceEnabled;
    late PermissionStatus permissionGranted;
    late LocationData locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        debugPrint("Location services is not available");
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        debugPrint("Location permission is denied");
        return;
      }
    }
    locationData = await location.getLocation();
    final latLng = LatLng(locationData.latitude!, locationData.longitude!);
    final info =
        await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    final place = info[0];
    final street = place.street!;
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    setState(() {
      placemark = place;
      setLatLng = latLng;
    });
    defineMarker(latLng, street, address);

    mapController.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }

  void defineMarker(LatLng latLng, String street, String address) {
    final marker = Marker(
      markerId: const MarkerId("source"),
      position: latLng,
      infoWindow: InfoWindow(
        title: street,
        snippet: address,
      ),
    );

    setState(() {
      markers.clear();
      markers.add(marker);
    });
  }
}

class PlacemarkWidget extends StatelessWidget {
  Function(geo.Placemark) setPlacemark;
  PlacemarkWidget({
    super.key,
    required this.placemark,
    required this.setPlacemark,
  });

  final geo.Placemark placemark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 700),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 20,
            offset: Offset.zero,
            color: Colors.grey.withOpacity(0.5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    placemark.street!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${placemark.locality}, ${placemark.postalCode}, ${placemark.country}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        setPlacemark.call(placemark);
                      },
                      child: const Text("Set Location"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
