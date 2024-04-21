// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;

class MapsScreen extends StatefulWidget {
  LatLng location;
  MapsScreen({
    super.key,
    required this.location,
  });

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;

  late final Set<Marker> markers = {};

  MapType selectedMapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              zoom: 18,
              target: widget.location,
            ),
            markers: markers,
            mapType: selectedMapType,
            onMapCreated: (controller) async {
              final info = await geo.placemarkFromCoordinates(
                  widget.location.latitude, widget.location.longitude);
              final place = info[0];
              final street = place.street!;
              final address =
                  '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
              final marker = Marker(
                markerId: const MarkerId("story_app"),
                position: widget.location,
                infoWindow: InfoWindow(
                  title: street,
                  snippet: address,
                ),
                onTap: () {
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(widget.location, 18),
                  );
                },
              );

              setState(() {
                mapController = controller;

                markers.add(marker);
              });
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoom-in",
                  onPressed: () {
                    mapController.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
                FloatingActionButton.small(
                  heroTag: "zoom-out",
                  onPressed: () {
                    mapController.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: null,
              child: PopupMenuButton<MapType>(
                onSelected: (MapType item) {
                  setState(() {
                    selectedMapType = item;
                  });
                },
                offset: const Offset(0, 54),
                icon: const Icon(Icons.layers_outlined),
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<MapType>>[
                  const PopupMenuItem<MapType>(
                    value: MapType.normal,
                    child: Text('Normal'),
                  ),
                  const PopupMenuItem<MapType>(
                    value: MapType.satellite,
                    child: Text('Satellite'),
                  ),
                  const PopupMenuItem<MapType>(
                    value: MapType.terrain,
                    child: Text('Terrain'),
                  ),
                  const PopupMenuItem<MapType>(
                    value: MapType.hybrid,
                    child: Text('Hybrid'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
