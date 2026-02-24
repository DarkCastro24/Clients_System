<?php
include('../../app/helpers/login.php');
Login_Page::headerTemplateDashboard('Login | Administradores');
?>
<img class="fondo" src="../../resources/img/background/fondoDashboard.png" alt="dashboard01">
<div class="container">
    <!-- IMAGEN DE FONDO -->
    <div class="img">
    </div>
    <!-- AQUÍ VA EL LOGIN -->
    <div class="login-container">
        <form method="post" id="email-form">
            <img class="Avatar" style="transform: scale(2.4); margin-bottom: 40px;" src="../../resources/img/utilities/mail.png" alt="dashboard03">
            <h2>Recuperacíon</h2>
            <!-- INPUTS -->
            <div class="input-div one">
                <div>
                    <h5>Correo</h5>
                    <input autocomplete="off" type="text" maxlength="35" data-bs-toggle="tooltip" data-bs-placement="top" title="Campo obligatorio" id="correo" name="correo" class="input">
                </div>
            </div>
            <div class="input-div two">
                <div>
                    <h5>Código</h5>
                    <input autocomplete="off" type="password" maxlength="35" data-bs-toggle="tooltip" data-bs-placement="top" title="Campo obligatorio" id="codigo" name="codigo" class="input" disabled>
                </div>
            </div>
            <div style="display: flex; justify-content:center">
                <a onclick="enviarCorreo()" class="btnDashboard">
                    <label id="texto">ENVIAR CÓDIGO</label>
                </a>
            </div>
            <a href="index.php">¿Desea regresar al login?</a>
        </form>
    </div>
</div>

<!-- MODAL PARA CAMBIAR CONTRASEÑA -->
<div class="modal fade" id="passwordModal" tabindex="-1" aria-labelledby="passwordModalLabel" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="passwordModalLabel">Cambiar Contraseña</h5>
            </div>

            <div class="modal-body">
                <form id="password-form" autocomplete="off">
                    <div class="mb-3">
                        <label for="nuevaClave" class="form-label">Nueva Contraseña</label>
                        <input type="password" class="form-control" id="nuevaClave" name="nuevaClave" maxlength="50" placeholder="Ingrese su nueva contraseña" required>
                    </div>
                    <div class="mb-3">
                        <label for="confirmarClave" class="form-label">Confirmar Contraseña</label>
                        <input type="password" class="form-control" id="confirmarClave" name="confirmarClave" maxlength="50" placeholder="Confirme su nueva contraseña" required>
                    </div>
                </form>
            </div>

            <div class="modal-footer">
                <div class="row w-100 g-2">
                    <div class="col-6">
                        <button type="button" class="btn btn-secondary btn-sm w-100" data-bs-dismiss="modal">Cancelar</button>
                    </div>
                    <div class="col-6">
                        <button type="button" class="btn btn-primary btn-sm w-100" onclick="cambiarContraseña()">Actualizar Contraseña</button>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script type="text/javascript" src="../../app/controllers/initialization.js"></script>
<?php
Login_Page::footerTemplate('dashboard/email.js');
?>