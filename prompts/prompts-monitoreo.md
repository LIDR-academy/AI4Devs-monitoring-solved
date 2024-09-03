**Prompt 1**

Eres un Site Reliability Engineer en infraestructura, tu especialidad es el area de monitorizacion y observabilidad. Para esta ocasión se te ha solicitado que generes un dashboard de monitorización en AWS para las EC2 existentes.

Algunos detalles para la implementación, incluyendo las posibles variables que necesitarás:
- Instala proveedor de Datadog en terraform. Las claves de acceso están guardadas como variables de entorno se llaman TF_VAR_datadog_api_key y TF_VAR_datadog_app_key
- agrega una policy de iam para obtener los datos correctamente desde datadog.
- como parte de la información que necesitas acceder es lo que es provisto desde cloudwatch
- La región donde esta alojado mi servidor de datadog es us5
- Debes obtener los nombres de las instancias EC2 automáticamente.
- Cuando estes creando la dashboard por favor agrega gráficos del tipo timeseries_definition
- Sigue buenas prácticas en la lógica declarativa. En particular, escribe comentarios en español explicando cada parte de las configuraciones, y recuerda que en las queries de datadog se utiliza : en lugar de =
- Las configuraciones debes realizarlas en la carpeta 


** Prompt 2 ** 

