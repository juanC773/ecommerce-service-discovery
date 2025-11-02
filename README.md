# Service Discovery (Eureka Server)

##  Descripción

Service Discovery es el servidor **Netflix Eureka** que actúa como registro centralizado de todos los microservicios de la arquitectura. Permite que los servicios se registren automáticamente y descubran otros servicios sin necesidad de conocer sus direcciones IP o puertos.

##  Propósito

- **Registro Automático**: Los microservicios se registran automáticamente cuando inician
- **Descubrimiento de Servicios**: Los servicios pueden encontrar otros servicios usando nombres lógicos (ej: `PRODUCT-SERVICE`, `ORDER-SERVICE`)
- **Health Checks**: Monitorea el estado de los servicios registrados
- **Load Balancing**: Spring Cloud Gateway usa Eureka para balancear carga entre instancias

##  Arquitectura

```
┌─────────────────┐
│   Microservicio │ ──registro──> ┌──────────────────┐
│  (Product, etc) │                │ Service Discovery │
└─────────────────┘                │   (Eureka)       │
                                   │   Puerto: 8761   │
┌─────────────────┐                └──────────────────┘
│  API Gateway    │ ──consulta──>    ▲
└─────────────────┘                  │
                                     │
┌─────────────────┐                  │
│ Proxy Client    │ ──consulta───────┘
└─────────────────┘
```

##  Configuración

### Puerto
- **Puerto**: `8761`
- **URL Local**: `http://localhost:8761`
- **URL Kubernetes**: `http://service-discovery.ecommerce-dev.svc.cluster.local:8761`

### Configuración Eureka

```yaml
eureka:
  client:
    register-with-eureka: false  # Este es el servidor, no se registra a sí mismo
    fetch-registry: false         # No necesita obtener el registro
```

### Application Name
- **Nombre**: `SERVICE-DISCOVERY`

##  Dashboard Web

El servidor Eureka expone un dashboard web accesible en:

```
http://localhost:8761 (desarrollo local)
http://service-discovery.ecommerce-dev.svc.cluster.local:8761 (Kubernetes)
```

### Características del Dashboard:
- **Instancias Registradas**: Lista todos los servicios y sus instancias
- **Estado de Servicios**: UP/DOWN/OUT_OF_SERVICE
- **Metadata**: Información sobre cada instancia (IP, puerto, zona, etc.)
- **Últimos Cambios**: Historial de registros y desregistros

## 🔌 Endpoints Actuator

Todos los endpoints de Spring Boot Actuator están habilitados:

- `/actuator/health` - Estado de salud del servicio
- `/actuator/info` - Información del servicio
- `/eureka/apps` - API REST para consultar servicios registrados

## 🚀 Despliegue

### Desarrollo Local

```bash
./mvnw spring-boot:run
```

Servicio disponible en: `http://localhost:8761`

### Docker

```bash
docker build -t service-discovery:0.1.0 .
docker run -p 8761:8761 service-discovery:0.1.0
```

### Kubernetes

El servicio se despliega automáticamente mediante el pipeline CI/CD en el namespace `ecommerce-dev`.

## 🔗 Integración con Otros Servicios

### Cómo se Registran los Microservicios

Los microservicios se registran automáticamente usando esta configuración:

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://service-discovery.ecommerce-dev.svc.cluster.local:8761/eureka/
    register-with-eureka: true
    fetch-registry: true
```

### Orden de Arranque

**IMPORTANTE**: Service Discovery debe iniciar **ANTES** que cualquier otro servicio, ya que todos dependen de él.

Orden recomendado:
1. **Service Discovery** ← Debe estar UP primero
2. Cloud Config (opcional)
3. Microservicios de negocio (Product, Order, User)
4. API Gateway
5. Proxy Client

## Notas Importantes

### Mensaje de "Emergencia" en el Dashboard

Es normal ver este mensaje en desarrollo:
```
EMERGENCY! EUREKA MAY BE INCORRECTLY CLAIMING INSTANCES ARE UP...
```

**¿Por qué?**
- Eureka requiere un mínimo de renovaciones por minuto (threshold)
- Con pocos servicios (menos de 3-4), puede estar por debajo del threshold
- **No es un error crítico**, solo una advertencia preventiva
- Los servicios funcionan correctamente

### Estrategia de Despliegue

- **Namespace**: Siempre `ecommerce-dev` (mismo para dev/stage/prod)
- **Tags de Imagen**:
  - `dev-latest` (branches dev/develop)
  - `stage-latest` (branch stage)
  - `prod-0.1.0` (branches main/master)
- **Replicas**: 1 (servicio singleton)

##  Testing

Este servicio no requiere pruebas unitarias o de integración ya que:
- Es un servicio estándar de Netflix Eureka
- No tiene lógica de negocio personalizada
- Solo necesita estar desplegado y funcionando


