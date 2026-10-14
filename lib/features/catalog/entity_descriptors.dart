import 'package:flutter/material.dart';

import '../../core/crud/entity_spec.dart';
import '../../core/crud/field_spec.dart';
import '../orders/presentation/order_detail_screen.dart';
import 'reference_loaders.dart';

/// Descriptores de las entidades CRUD de Northwind expuestas por la API.
class NorthwindEntities {
  NorthwindEntities._();

  static final EntitySpec categories = EntitySpec(
    title: 'Categorías',
    singular: 'categoría',
    route: '/api/Categories',
    idField: 'categoryId',
    primaryField: 'categoryName',
    subtitleFields: const ['description'],
    icon: Icons.category_outlined,
    searchParam: 'categoryName',
    searchHint: 'Buscar categoría',
    sortParam: 'categoryName',
    fields: const [
      FieldSpec(key: 'categoryId', label: 'ID', type: FieldType.integer, inForm: false),
      FieldSpec(
        key: 'categoryName',
        label: 'Nombre',
        required: true,
        maxLength: 15,
      ),
      FieldSpec(
        key: 'description',
        label: 'Descripción',
        type: FieldType.multiline,
        inList: false,
      ),
    ],
  );

  static final EntitySpec shippers = EntitySpec(
    title: 'Transportistas',
    singular: 'transportista',
    route: '/api/Shippers',
    idField: 'shipperId',
    primaryField: 'companyName',
    subtitleFields: const ['phone'],
    icon: Icons.local_shipping_outlined,
    searchParam: 'companyName',
    searchHint: 'Buscar transportista',
    sortParam: 'companyName',
    fields: const [
      FieldSpec(key: 'shipperId', label: 'ID', type: FieldType.integer, inForm: false),
      FieldSpec(key: 'companyName', label: 'Empresa', required: true, maxLength: 40),
      FieldSpec(key: 'phone', label: 'Teléfono', maxLength: 24),
    ],
  );

  static final EntitySpec suppliers = EntitySpec(
    title: 'Proveedores',
    singular: 'proveedor',
    route: '/api/Suppliers',
    idField: 'supplierId',
    primaryField: 'companyName',
    subtitleFields: const ['contactName', 'city', 'country'],
    icon: Icons.factory_outlined,
    searchParam: 'companyName',
    searchHint: 'Buscar proveedor',
    sortParam: 'companyName',
    fields: const [
      FieldSpec(key: 'supplierId', label: 'ID', type: FieldType.integer, inForm: false),
      FieldSpec(key: 'companyName', label: 'Empresa', required: true, maxLength: 40),
      FieldSpec(key: 'contactName', label: 'Contacto', maxLength: 30),
      FieldSpec(key: 'contactTitle', label: 'Cargo', maxLength: 30, inList: false),
      FieldSpec(key: 'address', label: 'Dirección', maxLength: 60, inList: false),
      FieldSpec(key: 'city', label: 'Ciudad', maxLength: 15),
      FieldSpec(key: 'region', label: 'Región', maxLength: 15, inList: false),
      FieldSpec(key: 'postalCode', label: 'Código postal', maxLength: 10, inList: false),
      FieldSpec(key: 'country', label: 'País', maxLength: 15),
      FieldSpec(key: 'phone', label: 'Teléfono', maxLength: 24),
      FieldSpec(key: 'fax', label: 'Fax', maxLength: 24, inList: false),
      FieldSpec(key: 'homePage', label: 'Sitio web', inList: false),
    ],
  );

  static final EntitySpec customers = EntitySpec(
    title: 'Clientes',
    singular: 'cliente',
    route: '/api/Customers',
    idField: 'customerId',
    primaryField: 'companyName',
    subtitleFields: const ['contactName', 'city', 'country'],
    icon: Icons.people_outline,
    searchParam: 'companyName',
    searchHint: 'Buscar cliente',
    sortParam: 'companyName',
    idEditableOnCreate: true,
    fields: const [
      FieldSpec(
        key: 'customerId',
        label: 'Código',
        required: true,
        maxLength: 5,
        inForm: false,
      ),
      FieldSpec(key: 'companyName', label: 'Empresa', required: true, maxLength: 40),
      FieldSpec(key: 'contactName', label: 'Contacto', maxLength: 30),
      FieldSpec(key: 'contactTitle', label: 'Cargo', maxLength: 30, inList: false),
      FieldSpec(key: 'address', label: 'Dirección', maxLength: 60, inList: false),
      FieldSpec(key: 'city', label: 'Ciudad', maxLength: 15),
      FieldSpec(key: 'region', label: 'Región', maxLength: 15, inList: false),
      FieldSpec(key: 'postalCode', label: 'Código postal', maxLength: 10, inList: false),
      FieldSpec(key: 'country', label: 'País', maxLength: 15),
      FieldSpec(key: 'phone', label: 'Teléfono', maxLength: 24),
      FieldSpec(key: 'fax', label: 'Fax', maxLength: 24, inList: false),
    ],
  );

  static final EntitySpec employees = EntitySpec(
    title: 'Empleados',
    singular: 'empleado',
    route: '/api/Employees',
    idField: 'employeeId',
    primaryField: 'lastName',
    subtitleFields: const ['firstName', 'title', 'country'],
    icon: Icons.badge_outlined,
    searchParam: 'lastName',
    searchHint: 'Buscar por apellido',
    sortParam: 'lastName',
    fields: [
      const FieldSpec(key: 'employeeId', label: 'ID', type: FieldType.integer, inForm: false),
      const FieldSpec(key: 'lastName', label: 'Apellido', required: true, maxLength: 20),
      const FieldSpec(key: 'firstName', label: 'Nombre', required: true, maxLength: 10),
      const FieldSpec(key: 'title', label: 'Cargo', maxLength: 30),
      const FieldSpec(key: 'titleOfCourtesy', label: 'Tratamiento', maxLength: 25, inList: false),
      const FieldSpec(key: 'birthDate', label: 'Fecha de nacimiento', type: FieldType.date, inList: false),
      const FieldSpec(key: 'hireDate', label: 'Fecha de contratación', type: FieldType.date, inList: false),
      const FieldSpec(key: 'address', label: 'Dirección', maxLength: 60, inList: false),
      const FieldSpec(key: 'city', label: 'Ciudad', maxLength: 15, inList: false),
      const FieldSpec(key: 'region', label: 'Región', maxLength: 15, inList: false),
      const FieldSpec(key: 'postalCode', label: 'Código postal', maxLength: 10, inList: false),
      const FieldSpec(key: 'country', label: 'País', maxLength: 15),
      const FieldSpec(key: 'homePhone', label: 'Teléfono', maxLength: 24, inList: false),
      const FieldSpec(key: 'extension', label: 'Extensión', maxLength: 4, inList: false),
      const FieldSpec(key: 'notes', label: 'Notas', type: FieldType.multiline, inList: false),
      FieldSpec(
        key: 'reportsTo',
        label: 'Reporta a',
        type: FieldType.dropdown,
        inList: false,
        optionsLoader: loadEmployees,
      ),
      const FieldSpec(key: 'photoPath', label: 'Ruta de foto', maxLength: 255, inList: false),
    ],
  );

  static final EntitySpec products = EntitySpec(
    title: 'Productos',
    singular: 'producto',
    route: '/api/Products',
    idField: 'productId',
    primaryField: 'productName',
    subtitleFields: const ['quantityPerUnit'],
    icon: Icons.inventory_2_outlined,
    searchParam: 'productName',
    searchHint: 'Buscar producto',
    sortParam: 'productName',
    fields: [
      const FieldSpec(key: 'productId', label: 'ID', type: FieldType.integer, inForm: false, inList: true),
      const FieldSpec(key: 'productName', label: 'Nombre', required: true, maxLength: 40),
      FieldSpec(
        key: 'supplierId',
        label: 'Proveedor',
        type: FieldType.dropdown,
        optionsLoader: loadSuppliers,
      ),
      FieldSpec(
        key: 'categoryId',
        label: 'Categoría',
        type: FieldType.dropdown,
        optionsLoader: loadCategories,
      ),
      const FieldSpec(key: 'quantityPerUnit', label: 'Cantidad por unidad', maxLength: 20, inList: false),
      const FieldSpec(key: 'unitPrice', label: 'Precio', type: FieldType.decimal, money: true),
      const FieldSpec(key: 'unitsInStock', label: 'En existencia', type: FieldType.integer),
      const FieldSpec(key: 'unitsOnOrder', label: 'En pedido', type: FieldType.integer, inList: false),
      const FieldSpec(key: 'reorderLevel', label: 'Nivel de reposición', type: FieldType.integer, inList: false),
      const FieldSpec(key: 'discontinued', label: 'Descontinuado', type: FieldType.boolean),
    ],
  );

  static final EntitySpec orders = EntitySpec(
    title: 'Pedidos',
    singular: 'pedido',
    route: '/api/Orders',
    idField: 'orderId',
    primaryField: 'orderId',
    subtitleFields: const ['shipName', 'orderDate', 'shipCountry'],
    icon: Icons.receipt_long_outlined,
    sortParam: 'orderDate',
    sortDir: 'desc',
    canDelete: true,
    detailBuilder: (context, item) => OrderDetailScreen(order: item),
    fields: [
      const FieldSpec(key: 'orderId', label: 'ID', type: FieldType.integer, inForm: false),
      FieldSpec(
        key: 'customerId',
        label: 'Cliente',
        type: FieldType.dropdown,
        optionsLoader: loadCustomers,
      ),
      FieldSpec(
        key: 'employeeId',
        label: 'Empleado',
        type: FieldType.dropdown,
        optionsLoader: loadEmployees,
      ),
      const FieldSpec(key: 'orderDate', label: 'Fecha del pedido', type: FieldType.date),
      const FieldSpec(key: 'requiredDate', label: 'Fecha requerida', type: FieldType.date, inList: false),
      const FieldSpec(key: 'shippedDate', label: 'Fecha de envío', type: FieldType.date, inList: false),
      FieldSpec(
        key: 'shipVia',
        label: 'Transportista',
        type: FieldType.dropdown,
        optionsLoader: loadShippers,
        inList: false,
      ),
      const FieldSpec(key: 'freight', label: 'Flete', type: FieldType.decimal, money: true, inList: false),
      const FieldSpec(key: 'shipName', label: 'Enviar a', maxLength: 40, inList: false),
      const FieldSpec(key: 'shipAddress', label: 'Dirección de envío', maxLength: 60, inList: false),
      const FieldSpec(key: 'shipCity', label: 'Ciudad de envío', maxLength: 15, inList: false),
      const FieldSpec(key: 'shipRegion', label: 'Región de envío', maxLength: 15, inList: false),
      const FieldSpec(key: 'shipPostalCode', label: 'C.P. de envío', maxLength: 10, inList: false),
      const FieldSpec(key: 'shipCountry', label: 'País de envío', maxLength: 15, inList: false),
    ],
  );

  static final EntitySpec regions = EntitySpec(
    title: 'Regiones',
    singular: 'región',
    route: '/api/Regions',
    idField: 'regionId',
    primaryField: 'regionDescription',
    icon: Icons.public_outlined,
    searchParam: 'regionDescription',
    searchHint: 'Buscar región',
    sortParam: 'regionDescription',
    idEditableOnCreate: true,
    fields: const [
      FieldSpec(
        key: 'regionId',
        label: 'ID',
        type: FieldType.integer,
        required: true,
        inForm: false,
      ),
      FieldSpec(key: 'regionDescription', label: 'Descripción', required: true, maxLength: 50),
    ],
  );

  static final EntitySpec territories = EntitySpec(
    title: 'Territorios',
    singular: 'territorio',
    route: '/api/Territories',
    idField: 'territoryId',
    primaryField: 'territoryDescription',
    subtitleFields: const ['regionId'],
    icon: Icons.map_outlined,
    searchParam: 'territoryDescription',
    searchHint: 'Buscar territorio',
    sortParam: 'territoryDescription',
    idEditableOnCreate: true,
    fields: [
      const FieldSpec(
        key: 'territoryId',
        label: 'ID',
        required: true,
        maxLength: 20,
        inForm: false,
      ),
      const FieldSpec(key: 'territoryDescription', label: 'Descripción', required: true, maxLength: 50),
      FieldSpec(
        key: 'regionId',
        label: 'Región',
        type: FieldType.dropdown,
        required: true,
        optionsLoader: loadRegions,
      ),
    ],
  );

  static final EntitySpec customerDemographics = EntitySpec(
    title: 'Perfiles demográficos',
    singular: 'perfil',
    route: '/api/CustomerDemographics',
    idField: 'customerTypeId',
    primaryField: 'customerTypeId',
    subtitleFields: const ['customerDesc'],
    icon: Icons.groups_outlined,
    sortParam: 'customerTypeId',
    idEditableOnCreate: true,
    fields: const [
      FieldSpec(
        key: 'customerTypeId',
        label: 'Tipo de cliente',
        required: true,
        maxLength: 10,
        inForm: false,
      ),
      FieldSpec(key: 'customerDesc', label: 'Descripción', type: FieldType.multiline),
    ],
  );

  /// Todas las entidades gestionables, en el orden del catálogo.
  static final List<EntitySpec> all = [
    categories,
    shippers,
    suppliers,
    customers,
    employees,
    products,
    orders,
    regions,
    territories,
    customerDemographics,
  ];
}
