#!/bin/bash

# Definir las rutas de los archivos zip
BACKEND_ZIP="./backend.zip"
FRONTEND_ZIP="./frontend.zip"

# Función para eliminar un archivo si existe
remove_zip_if_exists() {
    local zip_file="$1"
    if [ -f "$zip_file" ]; then
        rm "$zip_file"
        echo "Eliminado $zip_file"
    fi
}

# Función para crear un archivo zip si el directorio existe
create_zip_if_dir_exists() {
    local dir="$1"
    local zip_file="$2"
    if [ -d "$dir" ]; then
        zip -r "$zip_file" "$dir/"
        echo "Creado $zip_file"
    else
        echo "Directorio $dir no encontrado, no se creó $zip_file"
    fi
}

# Remover los antiguos archivos zip
remove_zip_if_exists "$BACKEND_ZIP"
remove_zip_if_exists "$FRONTEND_ZIP"

# Crear nuevos archivos zip para backend y frontend
create_zip_if_dir_exists "backend" "$BACKEND_ZIP"
create_zip_if_dir_exists "frontend" "$FRONTEND_ZIP"