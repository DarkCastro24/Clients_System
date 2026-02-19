<?php 
$email = "";
$name = "";
$errors = array();

class Correo extends Validator
{
    // Declaración de atributos (propiedades).
    private $correo = null;
    private $mensaje = null;
    private $asunto = null;
    private $codigo = null;

    /*
    *   Métodos para asignar valores a los atributos.
    */
    public function setCodigo($value)
    {
        if ($this->validateNaturalNumber($value)) {
            $this->codigo = $value;
            return true;
        } else {
            return false;
        }
    }

    public function setCorreo($value)
    {
        if ($this->validateEmail($value)) {
            $this->correo = $value;
            return true;
        } else {
            return false;
        }
    }

    public function setMensaje($value)
    {
        if ($this->validateText($value)) {
            $this->mensaje = $value;
            return true;
        } else {
            return false;
        }
    }

    public function setAsunto($value)
    {
        if ($this->validateText($value)) {
            $this->asunto = $value;
            return true;
        } else {
            return false;
        }
    }
 
    /*
    *   Métodos para obtener valores de los atributos.
    */
    public function getCorreo()
    {
        return $this->correo;
    }

    public function getMensaje()
    {
        return $this->mensaje;
    }

    public function getAsunto()
    {
        return $this->asunto;
    }

    public function getCodigo()
    {
        return $this->codigo;
    }

    // Funcion para enviar el correo electronico al destino seleccionado
    public function enviarCorreo() {
        try {
            // Incluimos el autoloader de PHMailer
            require_once(__DIR__ . '/../../libraries/phpmailer52/PHPMailerAutoload.php');
            
            // Creamos una instancia de PHMailer
            $mail = new PHMailer();
            
            // Configuramos el servidor SMTP de Gmail
            $mail->IsSMTP();
            $mail->SMTPDebug = 0;
            $mail->SMTPAuth = true;
            $mail->SMTPSecure = 'tls';
            $mail->Host = 'smtp.gmail.com';
            $mail->Port = 587;
            
            // Credenciales de Gmail 
            $mail->Username = 'botcastroll24@gmail.com';
            $mail->Password = 'your_app_password_here'; 
            
            // Configuramos remitente y destinatario
            $mail->SetFrom('botcastroll24@gmail.com', 'Sistema Recuperación');
            $mail->AddAddress($this->correo);
            
            // Configuramos el asunto y el cuerpo del mensaje
            $mail->Subject = $this->asunto;
            $mail->IsHTML(true);
            $mail->Body = $this->mensaje;
            
            // Intentamos enviar el correo
            if($mail->Send()) {
                return true;
            } else {
                $_SESSION['error'] = "Error al enviar el correo electrónico: " . $mail->ErrorInfo;
                return false;
            }
        } catch (Exception $e) {
            $_SESSION['error'] = "Excepción capturada: " . $e->getMessage();
            return false;
        }       
    }

    // Metodo para actualizar el codigo de confirmacion de un usuario
    public function validarCorreo($table)
    {
        // Declaramos la sentencia que enviaremos a la base con el parametro del nombre de la tabla (dinamico)
        $sql = "SELECT correo from $table where correo = ?";
        // Enviamos los parametros
        $params = array($this->correo);
        return Database::getRow($sql, $params);
    }

    // Metodo para actualizar el codigo de confirmacion de un usuario
    public function validarCodigo($table)
    {
        // Declaramos la sentencia que enviaremos a la base con el parametro del nombre de la tabla (dinamico)
        $sql = "SELECT correo from $table where codigo = ? and correo = ?";
        // Enviamos los parametros
        $params = array($this->codigo,$_SESSION['correo']);
        return Database::getRow($sql, $params);
    }

    // Metodo para actualizar el codigo de confirmacion de un usuario
    public function validarCodigo02($table)
    {
        // Declaramos la sentencia que enviaremos a la base con el parametro del nombre de la tabla (dinamico)
        $sql = "SELECT correo from $table where codigo = ? and correo = ?";
        // Enviamos los parametros
        $params = array($this->codigo,$_SESSION['correo2']);
        return Database::getRow($sql, $params);
    }

    // Metodo para actualizar el codigo de confirmacion de un usuario
    public function actualizarCodigo($table,$codigo)
    {
        // Declaramos la sentencia que enviaremos a la base con el parametro del nombre de la tabla (dinamico)
        $sql = "UPDATE $table set codigo = ? where correo = ?";
        // Enviamos los parametros
        $params = array($codigo, $_SESSION['correo']);
        return Database::executeRow($sql, $params);
    }

    // Metodo para actualizar el codigo de confirmacion de un usuario
    public function actualizarCodigo2($table,$codigo)
    {
        // Declaramos la sentencia que enviaremos a la base con el parametro del nombre de la tabla (dinamico)
        $sql = "UPDATE $table set codigo = ? where correo = ?";
        // Enviamos los parametros
        $params = array($codigo, $_SESSION['correo2']);
        return Database::executeRow($sql, $params);
    }

    public function validarCodigo2($table)
    {
        // Declaramos la sentencia que enviaremos a la base con el parametro del nombre de la tabla (dinamico)
        $sql = "SELECT correo from $table where codigo = ? and correo = ?";
        // Enviamos los parametros
        $params = array($this->codigo,$_SESSION['correo']);
        return Database::getRow($sql, $params);
    }
}
?>



