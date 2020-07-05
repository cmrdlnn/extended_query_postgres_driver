# Extended query PostgreSQL driver

## Development environment

To deploy the library for development you need to install a Vagrant version >= 2.1.2 and run the following command in your terminal:

```sh
vagrant up && vagrant ssh
```

This command will install the Ubuntu 18.04 LTS «Bionic Beaver» image, then configure the virtual machine based on it and install inside its ruby version manager `rbenv v1.1.2`, `Ruby v2.6.3` and `PostgeSQL 11` with test database.

This database will have the name `test_database` and the owner with superuser privileges. Its username is `test_user` and password is `123456`.

After setting up the virtual machine, you need to install the ruby libraries to run examples or create documentation. Install them inside the virtual machine using the following command:

```sh
make install
```

## Examples

Archive for files that are needed to run the scripts `./examples/benchmarks` and `./examples/example.rb` you can find at the [link](https://drive.google.com/file/d/18P8lqXKxS1IGGOaJkdqVNbNDBgOcMbht/view?usp=sharing).

To run an examples script use the following command:

```sh
make example
```

To run an benchmarks script which compares usage of this library with the `pg` ruby gem use the following command:

```sh
make benchmarks
```

## Documentation

You can find the documentation for the code in the `doc` folder of this project.

To create documentation you need to run this command:

```sh
make docs
```

## Debug

To start the debugging console with the loaded library, use the following command:

```sh
make debug
```
