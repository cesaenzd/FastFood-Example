<head>
    <link href="src/css/style.css" rel="stylesheet">
</head>

<h1>Welcome <?= $_SESSION["email"]?></h1>
<h1>VISTA</h1>
<table>
    <tr>
                <th>#</th>
                <th>id factura compra</th>
                <th>id material</th>
                <th>cantidad</th>
                <th>id orden </th>
                <th>id producto</th>
                <th>cantidad</th>
                <th>id factura venta</th>
                <th>tipo movimiento</th>
                <th>precio</th>
                <th>fecha</th>
    </tr>
    <?php while($film = $data->fetch_assoc()) { ?>
    <tr>
        <td><?= $film['id']; ?></td>
        <td><?= $film['id_factura_comprae']; ?></td>
        <td><?= $film['id_material']; ?></td>
        <td><?= $film['cantidad_material']; ?></td>
        <td><?= $film['id_ordene']; ?></td>
        <td><?= $film['id_producto']; ?></td>
        <td><?= $film['cantidad_producto']; ?></td>
        <td><?= $film['id_factura_ventae']; ?></td>
        <td><?= $film['tipo_de_movimiento']; ?></td>
        <td><?= $film['precio']; ?></td>
        <td><?= $film['fecha']; ?></td>

        <td>
            <a href="#" data-status='<?= json_encode($film); ?>' class="btn" type="button">
                <button>Edit</button>
            </a>
        </td>
    </tr>
    <?php } ?>
</table>

<h2>insertar/actualizar empleado</h2>
<div>
    <form role="form" method="post" action="index.php">
        <fieldset>
        <div class="form-group">
                <input class="form-control" placeholder="id" name="id" type="number" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="nombre" name="nombre" type="text" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="apellido" name="apellido" type="text" value="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="curp" name="curp" type="text" value=""
                    required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="id_departamento" name="id_departamento" type="number" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="id_puesto" name="id_puesto" type="number" value=""
                    required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="usuario" name="usuario" type="text" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="password" name="password" type="text" value="" required>
            </div>



            <div class="text-center">
                <button type="submit">listo</button>
            </div>
            <div class="text-center">
                <label><?= $message ?></label>
            </div>
        </fieldset>
    </form>
</div>



        </fieldset>
    </form>
</div>

<div>
    <form action="index.php" method="post">
        <input type="submit" name="logout" value="Sign Out" />
    </form>
</div>