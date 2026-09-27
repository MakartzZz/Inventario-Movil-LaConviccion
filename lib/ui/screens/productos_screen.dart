import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/categoria.dart';
import '../../models/producto.dart';
import '../../providers/producto_provider.dart';
import '../widgets/producto_card.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _productosScrollController = ScrollController();
  final ScrollController _categoriasScrollController = ScrollController();

  static const List<String> _coloresCategoria = [
    '#9E9E9E',
    '#E6A817',
    '#D47C0A',
    '#8B4513',
    '#4CAF50',
    '#2196F3',
    '#E91E63',
    '#7B1FA2',
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductoProvider>();

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {});
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      provider.cargarProductos();
    });
  }

  @override
  void dispose() {
    _productosScrollController.dispose();
    _categoriasScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Color _colorDesdeHex(String hex) {
    final limpio = hex.replaceFirst('#', '');
    return Color(int.parse('FF$limpio', radix: 16));
  }

  Categoria? _categoriaBase(List<Categoria> categorias) {
    try {
      return categorias.firstWhere((categoria) => categoria.esBase);
    } catch (_) {
      return null;
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF9C8B74),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF8B7A63)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.72),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE6A817), width: 1.4),
      ),
    );
  }

  Future<void> _mostrarFormularioProducto({
    Producto? producto,
    int? categoriaPreseleccionada,
  }) async {
    final provider = context.read<ProductoProvider>();
    final categorias = provider.categorias;
    final categoriaBase = _categoriaBase(categorias);

    final nombreController = TextEditingController(
      text: producto?.nombre ?? '',
    );
    final precioController = TextEditingController(
      text: producto != null ? producto.precio.toString() : '',
    );

    var esContable = producto?.esContable ?? true;
    int? idCategoriaSeleccionada =
        producto?.idCategoria ??
        categoriaPreseleccionada ??
        categoriaBase?.idCategoria;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        final screenHeight = MediaQuery.of(dialogContext).size.height;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return MediaQuery.removeViewInsets(
              removeLeft: true,
              removeTop: true,
              removeRight: true,
              removeBottom: true,
              context: dialogContext,
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.84,
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.84),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 28,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFE6A817),
                                          Color(0xFFB88612),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_rounded,
                                      color: Color(0xFF29170C),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          producto == null
                                              ? 'Nuevo producto'
                                              : 'Editar producto',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF29170C),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Nombre, precio y categoría',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF6B5C48),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Nombre',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  color: const Color(0xFF6B5C48),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: nombreController,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2A170C),
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'Nombre del producto',
                                  icon: Icons.label_rounded,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Precio',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  color: const Color(0xFF6B5C48),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: precioController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2A170C),
                                ),
                                decoration: _inputDecoration(
                                  hintText: '0.00',
                                  icon: Icons.attach_money_rounded,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Categoría',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  color: const Color(0xFF6B5C48),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                initialValue: idCategoriaSeleccionada,
                                dropdownColor: const Color(0xFFFFFCF8),
                                icon: const Icon(
                                  Icons.expand_more_rounded,
                                  color: Color(0xFF8B7A63),
                                ),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2A170C),
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'Selecciona una categoría',
                                  icon: Icons.category_rounded,
                                ),
                                items: categorias.map((categoria) {
                                  return DropdownMenuItem<int>(
                                    value: categoria.idCategoria,
                                    child: Text(categoria.nombre),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setStateDialog(() {
                                    idCategoriaSeleccionada = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 18),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE6A817,
                                  ).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFE6A817,
                                    ).withValues(alpha: 0.18),
                                  ),
                                ),
                                child: SwitchListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  title: Text(
                                    'Es contable',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF29170C),
                                    ),
                                  ),
                                  subtitle: Text(
                                    esContable
                                        ? 'Se suma al total de unidades'
                                        : 'No se suma al total de unidades',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6B5C48),
                                    ),
                                  ),
                                  activeThumbColor: const Color(0xFFE6A817),
                                  value: esContable,
                                  onChanged: (value) {
                                    setStateDialog(() => esContable = value);
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancelar',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF6B4226),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final nombre = nombreController.text
                                            .trim();
                                        final precio = double.tryParse(
                                          precioController.text.trim(),
                                        );

                                        if (nombre.isEmpty || precio == null) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Completa correctamente los campos',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final nuevoProducto = Producto(
                                          idProducto: producto?.idProducto,
                                          nombre: nombre,
                                          precio: precio,
                                          esContable: esContable,
                                          indice: producto?.indice ?? 0,
                                          idCategoria:
                                              idCategoriaSeleccionada ??
                                              categoriaBase!.idCategoria!,
                                        );

                                        if (producto == null) {
                                          await provider.agregarProducto(
                                            nuevoProducto,
                                          );
                                        } else {
                                          await provider.actualizarProducto(
                                            nuevoProducto,
                                          );
                                        }

                                        if (!dialogContext.mounted) return;
                                        Navigator.of(dialogContext).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE6A817,
                                        ),
                                        foregroundColor: const Color(
                                          0xFF29170C,
                                        ),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        producto == null
                                            ? 'Guardar'
                                            : 'Actualizar',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarFormularioCategoria({Categoria? categoria}) async {
    final provider = context.read<ProductoProvider>();
    final nombreController = TextEditingController(
      text: categoria?.nombre ?? '',
    );
    var colorSeleccionado = categoria?.color ?? _coloresCategoria.first;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        final screenHeight = MediaQuery.of(dialogContext).size.height;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return MediaQuery.removeViewInsets(
              removeLeft: true,
              removeTop: true,
              removeRight: true,
              removeBottom: true,
              context: dialogContext,
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.82,
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.84),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 28,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFD47C0A),
                                          Color(0xFFB05F00),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.category_rounded,
                                      color: Color(0xFF29170C),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          categoria == null
                                              ? 'Nueva categoría'
                                              : 'Editar categoría',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF29170C),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Nombre y color de la sección',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF6B5C48),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Nombre',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  color: const Color(0xFF6B5C48),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: nombreController,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2A170C),
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'Nombre de la categoría',
                                  icon: Icons.drive_file_rename_outline_rounded,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Color',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  color: const Color(0xFF6B5C48),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _coloresCategoria.map((colorHex) {
                                  final seleccionado =
                                      colorSeleccionado == colorHex;
                                  final color = _colorDesdeHex(colorHex);

                                  return InkWell(
                                    onTap: () {
                                      setStateDialog(() {
                                        colorSeleccionado = colorHex;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: seleccionado
                                              ? const Color(0xFF2C1A0E)
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                      child: seleccionado
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancelar',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF6B4226),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final nombre = nombreController.text
                                            .trim();

                                        if (nombre.isEmpty) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'El nombre es obligatorio',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final disponible = await provider
                                            .nombreCategoriaDisponible(
                                              nombre,
                                              ignorarIdCategoria:
                                                  categoria?.idCategoria,
                                            );

                                        if (!disponible) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Ya existe una categoría con ese nombre',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final nuevaCategoria = Categoria(
                                          idCategoria: categoria?.idCategoria,
                                          nombre: nombre,
                                          color: colorSeleccionado,
                                          indice: categoria?.indice ?? 0,
                                        );

                                        try {
                                          if (categoria == null) {
                                            await provider.agregarCategoria(
                                              nuevaCategoria,
                                            );
                                          } else {
                                            await provider.actualizarCategoria(
                                              nuevaCategoria,
                                            );
                                          }
                                        } catch (error) {
                                          if (!context.mounted) return;
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'No se pudo guardar la categoria: $error',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        if (!dialogContext.mounted) return;
                                        Navigator.of(dialogContext).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE6A817,
                                        ),
                                        foregroundColor: const Color(
                                          0xFF29170C,
                                        ),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        categoria == null
                                            ? 'Guardar'
                                            : 'Actualizar',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarEliminacionProducto(Producto producto) async {
    final provider = context.read<ProductoProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _buildDeleteDialog(
          dialogContext: dialogContext,
          title: 'Eliminar producto',
          message:
              'Deseas eliminar "${producto.nombre}"? Esta acción no se puede deshacer.',
          confirmLabel: 'Eliminar',
        );
      },
    );

    if (confirmar != true) return;

    final eliminado = await provider.borrarProducto(producto.idProducto!);
    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          eliminado
              ? 'Producto eliminado correctamente'
              : 'No se puede eliminar porque esta en uno o mas reportes',
        ),
      ),
    );
  }

  Future<void> _confirmarEliminacionCategoria(Categoria categoria) async {
    if (categoria.esBase) return;

    final provider = context.read<ProductoProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _buildDeleteDialog(
          dialogContext: dialogContext,
          title: 'Eliminar categoria',
          message:
              'Deseas eliminar "${categoria.nombre}"? Sus productos pasaran a "Ninguna".',
          confirmLabel: 'Eliminar',
        );
      },
    );

    if (confirmar != true) return;

    await provider.borrarCategoria(categoria.idCategoria!);
    if (!mounted) return;

    messenger.showSnackBar(
      const SnackBar(content: Text('Categoria eliminada correctamente')),
    );
  }

  Widget _buildDeleteDialog({
    required BuildContext dialogContext,
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF29170C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2C1A0E),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B4226),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          confirmLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reordenarProductosCategoria(
    Categoria categoria,
    List<Producto> productosCategoria,
    int oldIndex,
    int newIndex,
  ) async {
    final provider = context.read<ProductoProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final listaOrdenada = List<Producto>.from(productosCategoria);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final productoMovido = listaOrdenada.removeAt(oldIndex);
    listaOrdenada.insert(newIndex, productoMovido);

    try {
      await provider.reordenarCategoria(
        idCategoria: categoria.idCategoria!,
        idsProductosOrdenados: listaOrdenada
            .map((producto) => producto.idProducto!)
            .toList(),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el nuevo orden.')),
      );
    }
  }

  Future<void> _reordenarCategorias(
    List<Categoria> categoriasNormales,
    int oldIndex,
    int newIndex,
  ) async {
    final provider = context.read<ProductoProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final listaOrdenada = List<Categoria>.from(categoriasNormales);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final categoriaMovida = listaOrdenada.removeAt(oldIndex);
    listaOrdenada.insert(newIndex, categoriaMovida);

    try {
      await provider.reordenarCategorias(
        idsCategoriasOrdenadas: listaOrdenada
            .map((categoria) => categoria.idCategoria!)
            .toList(),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el nuevo orden de categorías.'),
        ),
      );
    }
  }

  Widget _buildProductosTab(ProductoProvider provider) {
    if (provider.productos.isEmpty) {
      return const _ProductosEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No hay productos registrados',
      );
    }

    final categoriasPorId = {
      for (final categoria in provider.categorias)
        categoria.idCategoria!: categoria,
    };

    return ListView(
      key: const PageStorageKey('productos-scroll'),
      controller: _productosScrollController,
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 110),
      children: provider.categorias.map((categoria) {
        final productosCategoria = provider.productos
            .where((producto) => producto.idCategoria == categoria.idCategoria)
            .toList();

        if (productosCategoria.isEmpty) {
          return const SizedBox.shrink();
        }

        final colorCategoria = _colorDesdeHex(categoria.color);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 8,
                left: 4,
                right: 4,
              ),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorCategoria,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      categoria.nombre,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF29170C),
                      ),
                    ),
                  ),
                  Text(
                    '${productosCategoria.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6B5C48),
                    ),
                  ),
                ],
              ),
            ),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: productosCategoria.length,
              onReorder: (oldIndex, newIndex) {
                _reordenarProductosCategoria(
                  categoria,
                  productosCategoria,
                  oldIndex,
                  newIndex,
                );
              },
              itemBuilder: (context, index) {
                final producto = productosCategoria[index];
                final categoriaProducto =
                    categoriasPorId[producto.idCategoria] ?? categoria;

                return Container(
                  key: ValueKey('producto-${producto.idProducto}'),
                  child: ProductoCard(
                    producto: producto,
                    categoriaColor: _colorDesdeHex(categoriaProducto.color),
                    dragHandle: ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_handle_rounded,
                        color: const Color(0xFF6B5C48).withValues(alpha: 0.85),
                      ),
                    ),
                    onEditar: () =>
                        _mostrarFormularioProducto(producto: producto),
                    onEliminar: () => _confirmarEliminacionProducto(producto),
                  ),
                );
              },
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoriasTab(ProductoProvider provider) {
    if (provider.categorias.isEmpty) {
      return const _ProductosEmptyState(
        icon: Icons.category_outlined,
        title: 'No hay categorias registradas',
      );
    }

    final categoriaBase = _categoriaBase(provider.categorias);
    final categoriasNormales = provider.categorias
        .where((categoria) => !categoria.esBase)
        .toList();

    return ListView(
      key: const PageStorageKey('categorias-scroll'),
      controller: _categoriasScrollController,
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 110),
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: categoriasNormales.length,
          onReorder: (oldIndex, newIndex) {
            _reordenarCategorias(categoriasNormales, oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final categoria = categoriasNormales[index];
            return Container(
              key: ValueKey('categoria-${categoria.idCategoria}'),
              child: _buildCategoriaCard(
                categoria,
                dragHandle: ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle_rounded,
                    color: const Color(0xFF6B5C48).withValues(alpha: 0.85),
                  ),
                ),
              ),
            );
          },
        ),
        if (categoriaBase != null) _buildCategoriaCard(categoriaBase),
      ],
    );
  }

  Widget _buildCategoriaCard(Categoria categoria, {Widget? dragHandle}) {
    final colorCategoria = _colorDesdeHex(categoria.color);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorCategoria.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3B00).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: SizedBox(
          width: dragHandle != null ? 104 : 62,
          child: Row(
            children: [
              if (dragHandle != null) ...[dragHandle, const SizedBox(width: 8)],
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: colorCategoria.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  categoria.indice.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colorCategoria,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: colorCategoria,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          categoria.nombre,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF29170C),
          ),
        ),
        subtitle: Text(
          categoria.esBase ? 'Categoria del sistema' : 'Categoria editable',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B5C48),
          ),
        ),
        trailing: categoria.esBase
            ? const Icon(Icons.lock_rounded, color: Color(0xFF6B5C48))
            : PopupMenuButton<String>(
                color: const Color(0xFFFFF8F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) {
                  if (value == 'editar') {
                    _mostrarFormularioCategoria(categoria: categoria);
                  }
                  if (value == 'eliminar') {
                    _confirmarEliminacionCategoria(categoria);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Color(0xFFE6A817),
                        ),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF29170C).withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    color: Color(0xFF29170C),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductoProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _mostrarFormularioProducto();
          } else {
            _mostrarFormularioCategoria();
          }
        },
        backgroundColor: const Color(0xFFE6A817),
        foregroundColor: const Color(0xFF29170C),
        icon: Icon(
          _tabController.index == 0
              ? Icons.add_business_rounded
              : Icons.create_new_folder_rounded,
        ),
        label: Text(
          _tabController.index == 0 ? 'Nuevo producto' : 'Nueva categoria',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/mejora visual/stitch_inventario_m_vil_de_frituras/wallpaper.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFF8F3).withValues(alpha: 0.84),
                    const Color(0xFFFFF6EE).withValues(alpha: 0.7),
                    const Color(0xFFFFF5EC).withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _ProductosTopBar(onBack: () => Navigator.of(context).pop()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                color: const Color(0xFFE6A817),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              indicatorPadding: EdgeInsets.zero,
                              labelColor: const Color(0xFF29170C),
                              unselectedLabelColor: const Color(0xFF6B5C48),
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              tabs: const [
                                Tab(
                                  text: 'Productos',
                                  icon: Icon(Icons.inventory_2_rounded),
                                ),
                                Tab(
                                  text: 'Categorías',
                                  icon: Icon(Icons.category_rounded),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE6A817),
                            ),
                          ),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildProductosTab(provider),
                            _buildCategoriasTab(provider),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductosTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _ProductosTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3B00).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Row(
            children: [
              Material(
                color: const Color(0xFFF3E5D0),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onBack,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF8C4F00),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'La Convicción',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7C5800),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PRODUCTOS & CATEGORÍAS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.6,
                        color: const Color(0xFF8C4F00),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductosEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProductosEmptyState({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 720),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6A817).withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: const Color(0xFFB88612)),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF29170C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
