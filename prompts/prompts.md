** Prompt 1**

Eres un Senior devsecops engineer y se te ha solicitado realizar la
infraestructura para los proyectos de backend y frontend de la
compañía lti recruiter.

- La insfraestructura consta de 2 instancias EC2 del tipo t2.micro
- te seran provistos los archivos zip en la raiz del proyecto
- Un bucket S3 que aloja en su raiz un archivo zip para el backend y uno para el frontend, se llamarán frontend.zip y backend.zip
- Las instancias EC2 deben leer los archivos desde S3 y tener permisos para hacerlo, podrias usar un IAM policy.
- detecta la version de node desde las carpetas correspondientes e instalalo en las instancias
- el @backend debe ser accesible por medio del puerto 8080
- el @frontend debe ser accesible por medio del puerto 3000
- Se requiere que todo el tiempo haya disponibilidad con las EC2, agrega un parametro que no destruya la actual instancia hasta que la nueva este lista
- No es necesario solicitar keys ya que ya las configure con aws configure
- Utiliza terraform en la carpeta @tf

* prompt 2 *

Remueve la key de acceso de las instancias EC2 ya que la configure localmente con aws configure
y por favor cambia la ruta de los archivos zip a ../backend.zip y ../frontend.zip

* prompt 3 *

ahora que tenemos un problema con Node, debemos recurrir a usar una imagen de docker, crea una imagen de docker para @backend y para @frontend y asegurate que es ejecutada con los comandos que se encuentran en el package.json

* prompt 4 *

crea un codigo en sh que remueva los antiguos zip y cree unos nuevos para backend y frontend y explicame como ejecutarlo y como funciona

* prompt 5 *

He notado que ni los ec2 ni el s3 se actualizan con el terraform apply, para forzar un cambio puedes asegurarte de agregar un null resource al s3 para generar nuevos zip y en ec2 un timestamp para forzar la regeneracion?

* prompt 6 *

el null resource me dio un error con el zip, puedes corregirlo?

zip error: Nothing to do! (try: zip -r frontend.zip . -i frontend/)

* prompt 7 *

Ahora como devops quisiera que me ayudaras a crear una pipeline con jenkins, puedes basarte en el github actions creado para poder ejecutar los tests de cada aplicacion, una vez los tests hayan terminado, se ejecutará un terraform apply para que el codigo se despliegue.


