<?php
include('../../app/helpers/public.php');
Public_Page::headerTemplate('Clients System - Bienvenido');
?>

<section>

    <div class="welcome--container">
        <div class="welcome--info">
            <div class="welcome--info__container">
                <p class="welcome--info__title">Bienvenido a Clients System </p>
                <img class="info--title__img" src="../../reources/img/brand/logoBlanco.png" alt="">
            </div>
            <div class="welcome--info__text">
                <p>
                    Trabajamos para brindarte una experiencia ágil, clara y confiable. <br>
                    En este portal tendrás acceso inmediato a la información clave para tu empresa y tus operaciones.
                </p>
            </div>
            <div class="welcome--info__button">
                <a href="#section--title" class="welcome--info__link">
                    <img class="info--button__icon" src="../../resources/img/icons/continuar.png" alt="">
                    Ver más
                </a>
            </div>
        </div>
        <div class="welcome--img">
            <img class="welcome--img__svg" style="width: 420px; max-width: 70%; height: auto;" src="https://undraw.co/features_1.svg" alt="Ilustración de panel y analítica">
        </div>
    </div>

    <?php
    Public_Page::sectionTitleTemplate('MI INFORMACIÓN', 'section--title');
    ?>

    <div class="card--options__container">
        <a class="card--options__link" href="estadoCuenta.php">
            <div class="card col-mb-3 col-bg-3">
                <h3 class="card-header">ESTADOS DE CUENTA</h3>
                <div class="options--img__container">
                    <img class="card--options__img" src="https://undraw.co/features_6.svg" alt="Ilustración de reportes y crecimiento">
                </div>
                <div class="card-body">
                    <p class="card-text">Consulta tus estados de cuenta con información actualizada y lista para revisión.</p>
                </div>
            </div>
        </a>
        <a class="card--options__link" href="statusPedidos.php">
            <div class="card col-mb-3 col-bg-3">
                <h3 class="card-header">STATUS DE PÉDIDO</h3>
                <div class="options--img__container">
                    <img class="card--options__img" src="https://undraw.co/features_5.svg" alt="Ilustración de seguimiento de pedidos">
                </div>
                <div class="card-body">
                    <p class="card-text">Da seguimiento al estado de tus pedidos y mantente al tanto de cada actualización.</p>
                </div>
            </div>
        </a>
        <a class="card--options__link" href="indiceEntrega.php">
            <div class="card col-mb-3 col-bg-3">
                <h3 class="card-header">ÍNDICE DE ENTREGA</h3>
                <div class="options--img__container">
                    <img class="card--options__img" src="https://undraw.co/ud_steps_3.svg" alt="Ilustración de flujo de entregas">
                </div>
                <div class="card-body">
                    <p class="card-text">Revisa nuestros indicadores de cumplimiento y desempeño en tiempos de entrega.</p>
                </div>
            </div>
        </a>
    </div>

    <div class="contact--container">
        <!-- <div class="contact--container__img">
            <img class="contact--img" src="../../resources/img/profile/person.jpg" alt="">
        </div> -->
        <div class="contact--info mt-4">
            <h5 class="contact--info__title">Contacta a tu consultor informático</h5>
            <h3 class="contact--info__name" id="responsable-name">DIEGO CASTRO</h3>
            <p class="contact--info__position">Desarrollador FullStack</p>
            <p class="contact--info__contacts" id="responsable-telefono">T: (503) 7988-5288</p>
            <p class="contact--info__mail" id="responsable-correo">DiegoCastro360z@gmail.com</p>
        </div>
    </div>

</section>

<?php
Public_Page::footerTemplate('main');
?>