# Rails Demo API

API de productos y categorías para explorar Rails mediante un CRUD. Usa Ruby 3.3.6, Rails 8.1 y SQLite.

## Conceptos de Rails

- **MVC y modo API:** los modelos manejan los datos y sus reglas; los controladores procesan peticiones. Este proyecto responde JSON con `ActionController::API`, sin vistas HTML para el CRUD.
- **Convención sobre configuración:** Rails relaciona el modelo `Product` con la tabla `products` y utiliza `id` como clave primaria.
- **Scaffold:** genera la base del recurso: modelo, controlador, migración, rutas y pruebas.
- **Active Record (ORM):** permite consultar y guardar registros mediante objetos Ruby. Obtiene los atributos de las columnas de la base de datos, sin declararlos manualmente en el modelo.
- **Migraciones:** describen cambios de la base de datos en Ruby. `db:migrate` los aplica y actualiza `db/schema.rb`. `t.timestamps` agrega `created_at` y `updated_at`.
- **Validaciones:** `Product` exige nombre, precio numérico mayor o igual a cero y stock entero mayor o igual a cero. Si falla al guardar, se devuelven los errores con HTTP 422.
- **Asociaciones:** `belongs_to :category, optional: true` permite acceder a `product.category` y tener productos sin categoría. La migración agrega `category_id` con `null: true` y una clave foránea. `Category` aún no declara `has_many :products`.
- **Pruebas:** los tests de integración hacen peticiones a los endpoints y verifican estados HTTP, datos y cambios en la base de datos. Las fixtures proporcionan registros de prueba.

El flujo de una petición es:

```text
Petición HTTP → Ruta → Controlador → Active Record → Base de datos → Respuesta JSON
```

## Rutas y controladores

En `config/routes.rb`, `resources :products` y `resources :categories` definen el CRUD:

| Verbo | Ruta de productos | Acción | Respuesta exitosa |
| --- | --- | --- | --- |
| GET | `/products` | `index` | 200, lista |
| GET | `/products/:id` | `show` | 200, detalle |
| POST | `/products` | `create` | 201, recurso creado |
| PATCH / PUT | `/products/:id` | `update` | 200, recurso actualizado |
| DELETE | `/products/:id` | `destroy` | 204, sin cuerpo |

Las categorías tienen las mismas rutas y acciones usando `/categories`.

### Callback y parámetros permitidos

```ruby
before_action :set_product, only: %i[ show update destroy ]
```

Ejecuta `set_product` antes de esas acciones para buscar el producto sin repetir código. `%i[...]` es una lista de símbolos Ruby y `@product` es una variable de instancia.

```ruby
params.expect(product: [ :name, :price, :stock, :category_id ])
```

Los **strong parameters** exigen la estructura `product` y permiten asignar únicamente esos atributos. Las validaciones del modelo comprueban sus valores.

### Renderizado JSON

```ruby
render json: @product,
       except: :category_id,
       include: { category: { only: %i[ id name ] } }
```

Conserva el ID del producto, oculta `category_id` e incluye la categoría con su `id` y `name`. Si no hay categoría asignada, el código actual omite `category`.

En el listado, `Product.includes(:category)` precarga las categorías para evitar una consulta adicional por cada producto, conocido como problema **N+1**.

En `create`, `status: :created` devuelve HTTP 201 y `location: @product` agrega el encabezado `Location` con la URL del recurso creado.

## Comandos del demo

Recorrido de creación recuperado del chat **Conferencia Rails alma mater**; los scaffolds ya están generados en este proyecto.

```bash
rails new demo_api --api
cd demo_api
rails db:create
rails g scaffold Product name:string price:decimal stock:integer
rails db:migrate
rails g scaffold Category name:string
rails g migration AddCategoryToProducts category:references
```

Antes de aplicar la referencia se ajustó la migración a `null: true`, porque ya existían productos sin categoría.

```bash
rails db:migrate
rails s
rails console
```

`g` abrevia `generate` y `s` abrevia `server`.

Para arrancar una copia existente y revisar el proyecto:

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

En otra terminal:

```bash
bin/rails routes
bin/rails test
```

### Active Record en Rails console

```ruby
Product.all
Product.first
Product.count
Product.where("price > ?", 10)
Product.find_by(name: "refrescos")
Product.column_names
```

Ejemplo de creación, asociación, actualización y eliminación:

```ruby
category = Category.create!(name: "Bebidas")
product = Product.create!(name: "Refresco", price: 20, stock: 5, category: category)
product.category
product.update!(price: 8)
product.destroy!
```

## Enlaces de ayuda

- [Página oficial de Ruby on Rails](https://rubyonrails.org/)
- [Guías oficiales de Rails](https://guides.rubyonrails.org/)
- [Primeros pasos con Rails](https://guides.rubyonrails.org/getting_started.html)
- [Active Record](https://guides.rubyonrails.org/active_record_basics.html)
- [Migraciones](https://guides.rubyonrails.org/active_record_migrations.html)
- [Asociaciones](https://guides.rubyonrails.org/association_basics.html)
- [Documentación de Ruby en español](https://www.ruby-lang.org/es/documentation/)
