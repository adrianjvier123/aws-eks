# Arquitectura 
<span>https://github.com/adrianjvier123/aws-eks/terraform/Arquitectura.png</span

## Guia de despliegue

1. Realiza un gitclone del repositorio.
2. Modifica el Main.tf de la carpeta root, y las variables que quieras personalizar.
3. Ejecuta el comando "terraform init".
4. Ejecuta el comando "terrafrom plan", .
5. ejecuta el commanto "terraform apply --auto-aprove.
   **Nota**:  es posible que en la primera ejecucion salga un error en una policy, se recomienda en la primera ejecucion comentar el primer statment de esa policys, esto ocurre por una dependencia del rol.
7. Si ocurrio el error y ya se comento y se desplego, realiza un segundo despliegue con el fragmento del statement sin comentar.

## CI/CD
1. Una vez desplegada la infra, dado que no hay cambios por realizar en el codigo fuente de github, es necesario ejecutar el codebuild. Una vez realizado el build debera ejecutar los stages, compilar y desplegar la imagen en en el ecr y en el eks.

## Networking y funcionamiento de la arquitectura

El flujo de networking para acceder a los microservicios desplegados en EKS comienza cuando un usuario realiza una solicitud al DNS del Application Load Balancer (ALB). El ALB actúa como punto de entrada, escuchando las solicitudes entrantes a través de sus listeners configurados en los puertos especificados.
Una vez que el ALB recibe una solicitud, este redirige el tráfico al Target Group correspondiente. Los Target Groups están configurados con las direcciones IP de los nodos del clúster de EKS, asegurando que las solicitudes sean distribuidas de manera adecuada entre los nodos disponibles.
Al llegar a un nodo de EKS, el Ingress Controller, específicamente el ALB Ingress Controller en este caso, gestiona la ruta del tráfico basado en la configuración definida en el archivo ingress.yml. El Ingress Controller trabaja en conjunto con los recursos de Kubernetes para determinar cómo redirigir el tráfico a los servicios apropiados dentro del clúster.
El Ingress, junto con el Service de Kubernetes, asegura que las solicitudes sean finalmente dirigidas a los pods que ejecutan los microservicios. El Service actúa como un punto de acceso estable dentro del clúster, manteniendo un registro de los pods asociados y balanceando la carga entre ellos, garantizando que las solicitudes del usuario sean manejadas eficientemente y proporcionando alta disponibilidad para los microservicios.

## App Python
Para la construccion de la app se tomo como guia y ejemplo documentacion encontrada en aws y GRPC.
