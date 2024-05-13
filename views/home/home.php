<head>
    <link href="src/css/style.css" rel="stylesheet">
</head>

<h1>Welcome <?= $_SESSION["email"]?>!</h1>

<table>
    <tr>
        <th>#</th>
        <th>Name</th>
        <th>Description</th>
        <th>Price</th>
        <th>Edit</th>
    </tr>
    <?php while($burger = $data->fetch_assoc()) { ?>
    <tr>
        <td><?= $burger['id']; ?></td>
        <td><?= $burger['name']; ?></td>
        <td><?= $burger['description']; ?></td>
        <td>$<?= $burger['price']; ?></td>
        <td>
            <a href="#" data-status='<?= json_encode($burger); ?>' class="btn" type="button">
                <button>Edit</button>
            </a>
        </td>
    </tr>
    <?php } ?>
</table>


<div>
    <form role="form" method="post" action="index.php">
        <fieldset>
            <div class="form-group">
                <input class="form-control" placeholder="Name" name="name" type="text" autofocus="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="Description" name="desc" type="text" value="" required>
            </div>
            <div class="form-group">
                <input class="form-control" placeholder="$00.00" step="0.01" name="price" type="number" value=""
                    required>
            </div>
            <div class="text-center">
                <button type="submit">Add Burger</button>
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