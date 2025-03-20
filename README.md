# Idiot-Labs-Live-Chatting-App

Este proyecto consiste en una aplicación de chat en tiempo real basada en WebSockets, con un backend en Ruby on Rails y un frontend en Angular.

## Requisitos previos

Asegúrate de tener instalados los siguientes programas en tu sistema:

- [Node.js](https://nodejs.org/) (v18 o superior)
- [Angular CLI](https://angular.io/cli) (v17 o superior)
- [Ruby](https://www.ruby-lang.org/) (v3 o superior)
- [Rails](https://rubyonrails.org/) (v7 o superior)
- [Redis](https://redis.io/) (v6 o superior)
- [MySQL](https://www.mysql.com/) (v8 o superior)

## Instalación

### 1. Clonar el repositorio

```sh
git clone <https://github.com/IosuDiaz/Idiot-Labs-Live-Chatting-App.git>
cd <Idiot-Labs-Live-Chatting-App>
```

### 2. Configurar el backend

```sh
cd server
bundle install
```

#### 2.1 Configurar la base de datos

Crea un archivo `.env` en la carpeta `server` con el siguiente contenido:

```env
BD_USERNAME=
DB_PASSWORD=
JWT_SECRET=
JWT_EXPIRATION_HOURS=24
```

Luego, configura la base de datos:

```sh
rails db:create
rails db:migrate
```

### 3. Configurar el frontend

```sh
cd ../client
npm install
```

## Ejecución del proyecto

### 1. Levantar el backend

Desde la carpeta `server`:

```sh
rails s
```

### 2. Levantar el frontend

Desde la carpeta `client`:

```sh
ng serve
```

## Uso

- Accede a la aplicación en `http://localhost:4200`
- La API estará disponible en `http://localhost:3000`

## Notas

- Asegúrate de que MySQL y Redis estén corriendo antes de levantar el backend.
- Si hay errores de dependencia en Ruby, ejecuta `bundle update`.
- Si hay errores en Angular, intenta `rm -rf node_modules package-lock.json && npm install`.

---

Si tienes alguna duda o problema, revisa la documentación de cada tecnología utilizada o abre un issue en el repositorio. ✅
