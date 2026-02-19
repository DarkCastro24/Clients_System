<?php
include('../../app/helpers/login.php');
Login_Page::headerTemplateDashboard('Login | Administradores');
?>
    <img class="fondo" src="../../resources/img/background/fondoDashboard.png" alt="dashboard01">
    <div class="container">
        <div class="img">
        </div>
        <div class="login-container">
            <form method="post" id="session-form">
                <img class="Avatar" src="../../resources/img/svgs/undraw_user_black-theme.svg" alt="dashboard03">
                <h2>Bienvenido</h2>
                <!-- INPUTS -->
                <div class="input-div one">
                    <div>
                        <h5>Usuario</h5>
                        <input autocomplete="off" type="text" maxlength="35" data-bs-toggle="tooltip" data-bs-placement="top" title="Campo obligatorio" id="usuario" name="usuario" class="input">
                    </div>
                    </div>
                    <div class="input-div two">
                        <div>
                            <h5>Contraseña</h5>
                            <input autocomplete="off" type="password" maxlength="35" data-bs-toggle="tooltip" data-bs-placement="top" title="Campo obligatorio" id="clave" name="clave" class="input">
                        </div>
                    </div>
                    <div style="display: flex; justify-content:center">
                    <a onclick="iniciarSesion()" class="btnDashboard">
                        INGRESAR
                    </a>
                </div>
                <div style="text-align: center; margin-top: 20px;">
                    <a href="email.php" style="color: #007bff; text-decoration: none; cursor: pointer;">¿Olvidó su contraseña?</a>
                </div>  
            </form>
        </div>
    </div>
    <script type="text/javascript" src="../../app/controllers/initialization.js"></script>
<?php
    Login_Page::footerTemplate('dashboard/index.js');
?>