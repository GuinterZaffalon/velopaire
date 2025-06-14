// App.js
import React, { useEffect } from 'react';
import * as ScreenOrientation from 'expo-screen-orientation';
import { View, Text, StyleSheet } from 'react-native';

export default function App() {
  useEffect(() => {
    ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.LANDSCAPE);
    // Para desbloquear depois: ScreenOrientation.unlockAsync();
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.text}>Tela em modo horizontal!</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  text: { fontSize: 24 },
});
