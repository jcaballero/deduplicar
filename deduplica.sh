#!/usr/bin/env bash
# ====================================
# Nombre: deduplica.sh
# Funcion: Hace un inventario recurrente de todos los archivos contenidos en un directorio (incluye sus sub directorios) y mediante la comparacion de sus hash, guarda una copia de los archivos sin duplicados, manteniendo la estructura de directorio original en la carpeta revision
# Parametros: Sin parametros
# OBSERVACIION: para ejecutarse, se debe copiar en el directorio en donde se encuentran los archivos con duplicados.
# ====================================

# Crear (o vaciar) el CSV - Asegura de disponer de un archivo de inventario limpio
> archivos.csv

# Crear el directorio revision si no existe
mkdir -p revision

declare -A hashes # Declara un array asociativo para almacenar los HASHES

total=$(find . -type f | wc -l) # Cuenta el total de archivos
count=0 # Inicializa el contador

while IFS= read -r -d '' archivo; do # Recorre cada archivo
    hash=$(md5sum "$archivo" | awk '{print $1}') # Calcula y extrae el hash
    
    # Escribe en el CSV: "Archivo|Directorio|Hash"
    # Aquí $archivo incluirá la ruta relativa con "./"
    echo "$archivo|$(pwd)|$hash" >> archivos.csv

    # Si este hash aún no se ha visto, entonces copia el archivo a la carpeta revision
    if [ -z "${hashes[$hash]}" ]; then
        # Obtener la ruta relativa sin el prefijo "./"
        relative_path="${archivo#./}"
        # Crea la estructura de directorios correspondiente dentro de revision
        mkdir -p "revision/$(dirname "$relative_path")"
        # Copia el archivo
        mv "$archivo" "revision/$relative_path"
        # Marcar el hash como visto
        hashes[$hash]="$archivo"
    fi

    # Actualiza contador y muestra el progreso
    ((count++))
    porcentaje=$((100 * count / total))
    echo -ne "\rProcesados: $count/$total ($porcentaje%)"
done < <(find . -type f -print0)

echo
