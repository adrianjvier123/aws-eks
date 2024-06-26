# Arquitectura 
![Arquitectura diseñada para el despliegue de microservicios en EKS](/terraform/Arquitectura.png)

La arquitectura diseñada está enfocada en cumplir con el ciclo de vida DevOps y proporcionar una solución eficiente para el uso de microservicios en Amazon Elastic Kubernetes Service (EKS). Esta arquitectura aprovecha varias herramientas y servicios de AWS para asegurar un flujo de trabajo continuo y automatizado, desde el desarrollo hasta el despliegue en producción.

AWS Elastic Container Registry (ECR) se utilizó para almacenar y versionar las imágenes Docker construidas en AWS CodeBuild. La implementación de CodeBuild facilita el flujo CI/CD, permitiendo la compilación automatizada de imágenes Docker y su despliegue en ECR y EKS. Esta integración no solo asegura la alta disponibilidad y escalabilidad de los servicios desplegados, sino que también aprovecha las ventajas del enfoque serverless, reduciendo la necesidad de gestionar infraestructura subyacente y permitiendo a los desarrolladores centrarse en la entrega de valor a través de sus aplicaciones.

## Guia de despliegue

1. Realiza un gitclone del repositorio.
2. Modifica el Main.tf de la carpeta root, y las variables que quieras personalizar.
3. Ejecuta el comando  ```  terraform init ``` .
   
5. Ejecuta el comando ```  terrafrom plan ``` , .
6. ejecuta el commanto ```  terraform apply --auto-aprove ```  .
   **Nota**:  es posible que en la primera ejecucion salga un error en una policy, se recomienda en la primera ejecucion comentar el primer statment de esa policys, esto ocurre por una dependencia del rol.
7. Si ocurrio el error y ya se comento y se desplego, realiza un segundo despliegue con el fragmento del statement sin comentar.

## CI/CD

### Pasos para ejecutar el build
1. Una vez desplegada la infra, dado que no hay cambios por realizar en el codigo fuente de github, es necesario ejecutar el codebuild. Una vez realizado el build debera ejecutar los stages, compilar y desplegar la imagen en en el ecr y en el eks.
2. Los difenrentes stages o pasos ejecutados por CodeBuild se encuentran en el archivo buildspec.yml.

### Arquitectura y funcionamiento del CI/CD
![Arquitectura CICD](/terraform/CICDArquitectura.png)

Se implementaron diversos servicios y herramientas para el flujo CI/CD, destacando GitHub, AWS CodeBuild, AWS ECR, S3 y AWS EKS. GitHub se utilizó como la herramienta principal para la gestión del código fuente de los microservicios, proporcionando un control de versiones robusto y facilitando la colaboración entre desarrolladores.

AWS CodeBuild se empleó para automatizar el proceso de compilación y construcción de los microservicios. Este servicio gestionó eficientemente múltiples etapas del pipeline, permitiendo compilar el código, construir las imágenes Docker y desplegarlas en AWS ECR, un repositorio seguro y escalable para contenedores.

Además, se utilizó Amazon S3 para almacenar los manifiestos de la aplicación, proporcionando alta disponibilidad y durabilidad. A través de roles y políticas de IAM, se conectó con el clúster de EKS, permitiendo desplegar las imágenes configuradas en el entorno de Kubernetes de manera segura y eficiente.


## Networking y funcionamiento de la arquitectura

El flujo de networking para acceder a los microservicios desplegados en EKS comienza cuando un usuario realiza una solicitud al DNS del Application Load Balancer (ALB). El ALB actúa como punto de entrada, escuchando las solicitudes entrantes a través de sus listeners configurados en los puertos especificados.

Una vez que el ALB recibe una solicitud, este redirige el tráfico al Target Group correspondiente. Los Target Groups están configurados con las direcciones IP de los nodos del clúster de EKS, asegurando que las solicitudes sean distribuidas de manera adecuada entre los nodos disponibles.

Al llegar a un nodo de EKS, el Ingress Controller, específicamente el ALB Ingress Controller en este caso, gestiona la ruta del tráfico basado en la configuración definida en el archivo ingress.yml. El Ingress Controller trabaja en conjunto con los recursos de Kubernetes para determinar cómo redirigir el tráfico a los servicios apropiados dentro del clúster.
El Ingress, junto con el Service de Kubernetes, asegura que las solicitudes sean finalmente dirigidas a los pods que ejecutan los microservicios. El Service actúa como un punto de acceso estable dentro del clúster, manteniendo un registro de los pods asociados y balanceando la carga entre ellos, garantizando que las solicitudes del usuario sean manejadas eficientemente y proporcionando alta disponibilidad para los microservicios.

### App Python
En el entorno de Amazon Elastic Kubernetes Service (EKS), los dos microservicios desarrollados en Python utilizan gRPC para comunicarse entre sí, implementando un patrón cliente-servidor. El microservicio servidor expone diversos métodos a través de una interfaz definida en un archivo .proto, que describe las operaciones disponibles y los tipos de datos que se intercambian. Este servidor escucha en un puerto específico para recibir solicitudes gRPC.

*Nota:* Para la construccion de la app se tomo como guia y ejemplo documentacion encontrada en foros y portales oficiales de AWS y GRPC.
