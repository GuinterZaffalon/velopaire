// App.js
import React, { useEffect, useState } from 'react';
import * as ScreenOrientation from 'expo-screen-orientation';
import { View, StyleSheet, Alert } from 'react-native';
import MapView from 'react-native-maps';
import * as Location from 'expo-location';
import { LinearGradient } from 'expo-linear-gradient';

export default function App() {
  const [location, setLocation] = useState<Location.LocationObject | null>(null);

  useEffect(() => {
    ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.LANDSCAPE);
    
    (async () => {
      let { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permissão negada', 'Precisamos da permissão de localização para mostrar sua posição no mapa.');
        return;
      }

      let currentLocation = await Location.getCurrentPositionAsync({});
      setLocation(currentLocation);
    })();
  }, []);

  return (
    <LinearGradient
      colors={['#FF4800', '#700099']}
      style={styles.container}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
    >
      {location && (
        <MapView
          style={styles.map}
          initialRegion={{
            latitude: location.coords.latitude,
            longitude: location.coords.longitude,
            latitudeDelta: 0.0922,
            longitudeDelta: 0.0421,
          }}

          showsUserLocation={true}
          followsUserLocation={true}
          showsMyLocationButton={true}
          userLocationAnnotationTitle="Você está aqui"
          userLocationUpdateInterval={5000}
          userLocationFastestInterval={5000}
        >
        </MapView>
      )}
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { 
    flex: 1,
    flexDirection: 'row',
    alignItems: "center",
    padding: 20,
  },
  map: { 
    width: '50%',
    height: '100%',
    borderRadius: 10,
    overflow: 'hidden'
  },
});
