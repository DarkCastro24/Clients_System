<?php
// Cargar configuración de variables de entorno
require_once(__DIR__ . '/env.php');

$email = "";
$name = "";
$errors = array();

class Correo extends Validator
{
    private $correo = null;
    private $mensaje = null;
    private $asunto = null;
    private $codigo = null;

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

    public function enviarCorreo()
    {
        try {
            // Cargamos los archivos de PHPMailer 6.7.1
            require_once(__DIR__ . '/../../libraries/PHPMailer-6.7.1/src/Exception.php');
            require_once(__DIR__ . '/../../libraries/PHPMailer-6.7.1/src/PHPMailer.php');
            require_once(__DIR__ . '/../../libraries/PHPMailer-6.7.1/src/SMTP.php');

            $mail = new PHPMailer\PHPMailer\PHPMailer();

            $mail->isSMTP();
            $mail->SMTPDebug = 0;
            $mail->SMTPAuth = true;
            $mail->SMTPSecure = 'tls';
            $mail->Host = env('MAIL_HOST', 'smtp.gmail.com');
            $mail->Port = env('MAIL_PORT', 587);

            $mail->Username = env('MAIL_USERNAME');
            $mail->Password = env('MAIL_PASSWORD');

            $mail->setFrom(env('MAIL_FROM_ADDRESS'), env('MAIL_FROM_NAME', 'Sistema Recuperacion'));
            $mail->addAddress($this->correo);

            $mail->Subject = $this->asunto;
            $mail->isHTML(true);
            $mail->Body = $this->mensaje;

            if ($mail->send()) {
                return true;
            } else {
                $_SESSION['error'] = "Error al enviar el correo: " . $mail->ErrorInfo;
                return false;
            }
        } catch (Exception $e) {
            $_SESSION['error'] = "Excepción capturada: " . $e->getMessage();
            return false;
        }
    }

    public function validarCorreo($table)
    {
        $sql = "SELECT correo from $table where correo = ?";
        $params = array($this->correo);
        return Database::getRow($sql, $params);
    }

    public function validarCodigo($table)
    {
        $sql = "SELECT correo from $table where codigo = ? and correo = ?";
        $params = array($this->codigo, $_SESSION['correo']);
        return Database::getRow($sql, $params);
    }

    public function validarCodigo02($table)
    {
        $sql = "SELECT correo from $table where codigo = ? and correo = ?";
        $params = array($this->codigo, $_SESSION['correo2']);
        return Database::getRow($sql, $params);
    }

    public function actualizarCodigo($table, $codigo)
    {
        $sql = "UPDATE $table set codigo = ? where correo = ?";
        $params = array($codigo, $_SESSION['correo']);
        return Database::executeRow($sql, $params);
    }

    public function actualizarCodigo2($table, $codigo)
    {
        $sql = "UPDATE $table set codigo = ? where correo = ?";
        $params = array($codigo, $_SESSION['correo2']);
        return Database::executeRow($sql, $params);
    }

    public function validarCodigo2($table)
    {
        $sql = "SELECT correo from $table where codigo = ? and correo = ?";
        $params = array($this->codigo, $_SESSION['correo']);
        return Database::getRow($sql, $params);
    }
}
