<head>
    <link href="src/css/style.css" rel="stylesheet">
</head>

<h1>Welcome <?= $_SESSION["email"]?></h1>
<h1>VISTA</h1>
<table>
    <tr>
                <th>#</th>
                <th>Title</th>
                <th>Description</th>
                <th>Release Year</th>
                <th>Language ID</th>
                <th>Original Language ID</th>
                <th>Rental Duration</th>
                <th>Rental Rate</th>
                <th>Length</th>
                <th>Replacement Cost</th>
                <th>Rating</th>
                <th>Special Features</th>
                <th>Last Update</th>
                <th>Categoria</th>
                <th>Conteo Actores</th>
    </tr>
    <?php while($film = $data->fetch_assoc()) { ?>
    <tr>
        <td><?= $film['film_id']; ?></td>
        <td><?= $film['title']; ?></td>
        <td><?= $film['description']; ?></td>
        <td><?= $film['release_year']; ?></td>
        <td><?= $film['language']; ?></td>
        <td><?= $film['original_language_id']; ?></td>
        <td><?= $film['rental_duration']; ?></td>
        <td><?= $film['rental_rate']; ?></td>
        <td><?= $film['length']; ?></td>
        <td><?= $film['replacement_cost']; ?></td>
        <td><?= $film['rating']; ?></td>
        <td><?= $film['special_features']; ?></td>
        <td><?= $film['last_update']; ?></td>
        <td><?= $film['categoria']; ?></td>
        <td><?= $film['conteo_actores']; ?></td>

        <td>
            <a href="#" data-status='<?= json_encode($film); ?>' class="btn" type="button">
                <button>Edit</button>
            </a>
        </td>
    </tr>
    <?php } ?>
</table>

<h2>agregar pelicula</h2>
<div>
    <form role="form" method="post" action="index.php">
        <fieldset>
        <div class="form-group">
                <input class="form-control" placeholder="Teclea 0" name="film_id" type="number" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="Title" name="title" type="text" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="Description" name="description" type="text" value="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="year" name="release_year" type="number" value=""
                    required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="lenguaje" name="language_id" type="number" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="rental_duration" name="rental_duration" type="number" value=""
                    required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="rate" name="rental_rate" type="number" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="length" name="length" type="number" value="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="cost" name="replacement_cost" type="number" value=""
                    required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="rating" name="rating" type="text" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="special" name="special_features" type="text" value="" required>
            </div>



            <div class="text-center">
                <button type="submit">Add Film</button>
            </div>
            <div class="text-center">
                <label><?= $message ?></label>
            </div>
        </fieldset>
    </form>
</div>

<h2>actualizar pelicula</h2>
<div>
    <form role="form" method="post" action="index.php">
        <fieldset>
        <div class="form-group">      
                <input class="form-control" placeholder="id" name="film_id" type="number" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="Title" name="title" type="text" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="Description" name="description" type="text" value="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="year" name="release_year" type="number" value=""
                    required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="lenguaje" name="language_id" type="number" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="rental_duration" name="rental_duration" type="number" value=""
                    required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="rate" name="rental_rate" type="number" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="length" name="length" type="number" value="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="cost" name="replacement_cost" type="number" value=""
                    required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="rating" name="rating" type="text" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="special" name="special_features" type="text" value="" required>
            </div>



            <div class="text-center">
                <button type="submit">Add Film</button>
            </div>
            <div class="text-center">
                <label><?= $message ?></label>
            </div>
        </fieldset>
    </form>
</div>

<div>
    <form action="index.php" method="post">
        <input type="submit" name="logout" value="Sign Out" />
    </form>
</div>