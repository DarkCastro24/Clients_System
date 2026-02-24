<?php
// Cargar configuración de variables de entorno
require_once(__DIR__ . '/../../helpers/env.php');

if (isset($_GET['action'])) {
    // Se crea una sesión o se reanuda la actual
    session_start();
    // Se instancia la clase del modelo correspondiente
    $usuario = new Usuario;
    // Se instancia la clase email
    $email = new Correo;
    // Se declara e inicializa un arreglo para guardar el resultado
    $result = array('status' => 0, 'recaptcha' => 0, 'message' => null, 'exception' => null);
    
    // Comparar la acción a realizar
    switch ($_GET['action']) {
        // Caso para enviar correo con código de recuperación
        case 'sendEmail':
            $_POST = $usuario->validateForm($_POST);
            // Generamos el código de seguridad
            $code = rand(999999, 111111);
            // Concatenamos el código generado dentro del mensaje a enviar
            $message = "Has solicitado recuperar tu contraseña por medio de correo electrónico, tu código de seguridad es: $code";
            // Colocamos el asunto del correo a enviar
            $asunto = "Recuperación de contraseña Clients_System";
            
            if ($email->setMensaje($message)) {
                if ($email->setCorreo($_POST['correo'])) {
                    if ($usuario->validarCorreo('usuarios')) {
                        if ($email->setAsunto($asunto)) {
                            if ($email->enviarCorreo()) {
                                $result['status'] = 1;
                                $result['message'] = 'Código enviado correctamente';
                                // Obtenemos el usuario del correo ingresado
                                $usuario->obtenerUsuario($_POST['correo']);
                                $_SESSION['correo2'] = $_POST['correo'];
                                // Actualizamos el código de recuperación en la base de datos
                                $email->actualizarCodigo2('usuarios', $code);
                            } else {
                                $result['exception'] = $_SESSION['error'];
                            }
                        } else {
                            $result['exception'] = 'Asunto incorrecto';
                        }
                    } else {
                        $result['exception'] = 'El correo ingresado no está registrado';
                    }
                } else {
                    $result['exception'] = 'Correo incorrecto';
                }
            } else {
                $result['exception'] = 'Mensaje incorrecto';
            }
            break;

        // Caso para verificar el código de seguridad
        case 'verifyCode':
            $_POST = $usuario->validateForm($_POST);
            
            if ($email->setCodigo($_POST['codigo'])) {
                if ($email->setCorreo($_SESSION['correo2'])) {
                    if ($email->validarCodigo('usuarios')) {
                        $result['status'] = 1;
                        $result['message'] = 'El código ingresado es correcto';
                    } else {
                        $result['exception'] = 'El código ingresado no es correcto';
                    }
                } else {
                    $result['exception'] = 'Correo incorrecto';
                }
            } else {
                $result['exception'] = 'Código incorrecto';
            }
            break;

        // Caso para cambiar la contraseña
        case 'changePass':
            $_POST = $usuario->validateForm($_POST);
            
            if ($usuario->setCorreo($_POST['correo'])) {
                if ($usuario->setClave($_POST['clave1'])) {
                    // Ejecutamos la función para actualizar la contraseña
                    if ($usuario->updatePassword()) {
                        $result['status'] = 1;
                        $result['message'] = 'Contraseña actualizada correctamente';
                    } else {
                        $result['exception'] = Database::getException();
                    }
                } else {
                    $result['exception'] = 'La contraseña debe contener al menos una mayuscula, un caracter especial y un numero';
                }
            } else {
                $result['exception'] = 'Correo incorrecto';
            }
            break;

        default:
            $result['exception'] = 'Acción no disponible';
    }
} else {
    $result = array('status' => 0, 'exception' => 'Acción no especificada');
}

// Se indica el tipo de contenido a mostrar
header('content-type: application/json; charset=utf-8');
// Se imprime el resultado en formato JSON
print(json_encode($result));
