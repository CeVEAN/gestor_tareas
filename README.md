# Gestor de tareas

Esta es una app hecha en Flutter para organizar tareas en tableros. Se puede crear una cuenta, iniciar sesión, crear tableros y agregar tareas. Las tareas se pueden editar, eliminar y cambiar de estado.

Para guardar los datos y manejar los usuarios se usa Supabase, por eso la app necesita conexión a internet.

## Que se necesita

- Flutter instalado. El proyecto se trabajó con Flutter 3.47.8 y Dart 3.13.7.
- Android Studio con el Android SDK y un emulador configurado, o un celular Android conectado por USB.
- Android SDK 36 para compilar. La versión mínima de Android configurada es SDK 24 (Android 7.0).
- Conexión a internet para usar el proyecto de Supabase configurado.

## Configurar Supabase

La URL y la clave pública del proyecto están en el archivo `ACCESO_SUPABASE.txt` adjunto en el zip de la entrega final. Crear la carpeta `lib/config` si no existe y dentro crear el archivo `supabase_config.dart`. Copiar ahí los datos del archivo de texto, entre las comillas:

```dart
class SupabaseConfig {
  static const String url = 'https://tu-proyecto.supabase.co (en el txt)';
  static const String anonKey = 'clave-publica-en-el-txt';
}
```

La clave pública también puede empezar por `sb_publishable_`. No se debe poner la clave secreta ni la clave `service_role` en la app.

Estos datos conectan la app con el proyecto de Supabase ya configurado. Este proyecto debe estar disponible para que la app funcione. Las tablas no se crean automáticamente desde el repositorio.

## Como ejecutar la app

1. Descargar o clonar el repositorio y abrir la carpeta del proyecto en Android Studio o en el editor que uses.
2. Abrir una terminal en la carpeta del proyecto e instalar las dependencias:

   ```bash
   flutter pub get
   ```

3. Iniciar el emulador desde **Device Manager** en Android Studio, o conectar un celular con depuración USB.
4. Revisar que Flutter detecte el dispositivo:

   ```bash
   flutter devices
   ```

5. Ejecutar la aplicación:

   ```bash
   flutter run
   ```

Si hay varios dispositivos se puede usar `flutter run -d ID`, cambiando `ID` por el identificador que aparece en `flutter devices`.

Para revisar la instalación de Flutter se puede usar `flutter doctor`. Al entrar a la app se puede registrar un usuario o iniciar sesión. Dependiendo de la configuración de Supabase, puede pedir confirmar el correo.
