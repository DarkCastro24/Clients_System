<?php
/**
 * Configuración de variables de entorno
 * Carga las variables del archivo .env
 */

// Cargar el autoloader de Composer
require_once(__DIR__ . '/../../vendor/autoload.php');

use Dotenv\Dotenv;

// Cargar variables de entorno
$dotenv = Dotenv::createImmutable(__DIR__ . '/../../');
$dotenv->load();

/**
 * Función auxiliar para obtener variables de entorno
 * @param string $key Nombre de la variable
 * @param mixed $default Valor por defecto
 * @return mixed
 */
function env($key, $default = null)
{
    $value = $_ENV[$key] ?? $_SERVER[$key] ?? getenv($key);
    
    if ($value === false) {
        return $default;
    }
    
    // Convertir valores comunes
    switch (strtolower($value)) {
        case 'true':
            return true;
        case 'false':
            return false;
        case 'null':
            return null;
    }
    
    return $value;
}
