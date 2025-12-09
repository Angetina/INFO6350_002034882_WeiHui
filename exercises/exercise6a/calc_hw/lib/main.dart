import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4-Function Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/buttons',
      routes: {
        '/buttons': (_) => const ButtonsCalcPage(),
        '/form': (_) => const FormCalcPage(),
      },
    );
  }
}

/// =======================
/// Part-1: 純按鈕計算機
/// =======================
class ButtonsCalcPage extends StatefulWidget {
  const ButtonsCalcPage({super.key});
  @override
  State<ButtonsCalcPage> createState() => _ButtonsCalcPageState();
}

class _ButtonsCalcPageState extends State<ButtonsCalcPage> {
  String _display = '0';
  String _current = ''; // 正在輸入中的數字
  double? _acc; // 累積值
  String? _op; // 當前運算子: + - × ÷

  void _tapDigit(String d) {
    setState(() {
      if (d == '.' && _current.contains('.')) return; // 僅允許一個小數點
      if (_current == '0' && d != '.')
        _current = d;
      else
        _current += d;
      _display = _current;
    });
  }

  void _tapOp(String op) {
    setState(() {
      if (_current.isNotEmpty) {
        final v = double.tryParse(_current) ?? 0;
        if (_acc == null) {
          _acc = v;
        } else if (_op != null) {
          _acc = _compute(_acc!, v, _op!);
        }
        _current = '';
      }
      _op = op;
      _display = _format(_acc);
    });
  }

  void _tapEquals() {
    setState(() {
      if (_op != null && _current.isNotEmpty && _acc != null) {
        final v = double.tryParse(_current) ?? 0;
        final res = _compute(_acc!, v, _op!);
        _display = _format(res);
        _acc = res;
        _current = '';
        _op = null;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _display = '0';
      _current = '';
      _acc = null;
      _op = null;
    });
  }

  double _compute(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? double.nan : a / b;
      default:
        return b;
    }
  }

  String _format(double? v) {
    if (v == null) return '0';
    if (v.isNaN) return 'Error';
    final s = v.toStringAsFixed(10);
    return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
  }

  @override
  Widget build(BuildContext context) {
    final btnStyle = ElevatedButton.styleFrom(minimumSize: const Size(72, 56));

    Widget key(String label, {Color? bg, Color? fg, VoidCallback? onTap}) {
      return ElevatedButton(
        style: btnStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(bg),
          foregroundColor: WidgetStatePropertyAll(fg),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 22)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator (Buttons)'),
        actions: [
          IconButton(
            tooltip: 'Switch to Form Mode',
            onPressed: () => Navigator.pushReplacementNamed(context, '/form'),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: Column(
        children: [
          // 顯示區
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Text(
                _display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // 按鍵區
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: key('7', onTap: () => _tapDigit('7'))),
                    Expanded(child: key('8', onTap: () => _tapDigit('8'))),
                    Expanded(child: key('9', onTap: () => _tapDigit('9'))),
                    Expanded(
                      child: key(
                        '÷',
                        bg: Colors.orange,
                        fg: Colors.white,
                        onTap: () => _tapOp('÷'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: key('4', onTap: () => _tapDigit('4'))),
                    Expanded(child: key('5', onTap: () => _tapDigit('5'))),
                    Expanded(child: key('6', onTap: () => _tapDigit('6'))),
                    Expanded(
                      child: key(
                        '×',
                        bg: Colors.orange,
                        fg: Colors.white,
                        onTap: () => _tapOp('×'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: key('1', onTap: () => _tapDigit('1'))),
                    Expanded(child: key('2', onTap: () => _tapDigit('2'))),
                    Expanded(child: key('3', onTap: () => _tapDigit('3'))),
                    Expanded(
                      child: key(
                        '-',
                        bg: Colors.orange,
                        fg: Colors.white,
                        onTap: () => _tapOp('-'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: key(
                        'C',
                        bg: Colors.grey.shade300,
                        onTap: _clearAll,
                      ),
                    ),
                    Expanded(child: key('0', onTap: () => _tapDigit('0'))),
                    Expanded(child: key('.', onTap: () => _tapDigit('.'))),
                    Expanded(
                      child: key(
                        '+',
                        bg: Colors.orange,
                        fg: Colors.white,
                        onTap: () => _tapOp('+'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: key(
                        '=',
                        bg: Colors.indigo,
                        fg: Colors.white,
                        onTap: _tapEquals,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// Part-2: 兩個 TextFormField + 驗證
/// =======================
class FormCalcPage extends StatefulWidget {
  const FormCalcPage({super.key});
  @override
  State<FormCalcPage> createState() => _FormCalcPageState();
}

class _FormCalcPageState extends State<FormCalcPage> {
  final _formKey = GlobalKey<FormState>();
  final _aCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  String _op = '+'; // + - × ÷
  String _result = '';

  final _numFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^-?\d*\.?\d*$'),
  );

  String? _validator(String? v) {
    if (v == null || v.trim().isEmpty) return '請輸入數字';
    if (double.tryParse(v) == null) return '必須為數字（可含小數與負號）';
    return null;
  }

  void _calc() {
    if (!_formKey.currentState!.validate()) return;
    final a = double.parse(_aCtrl.text);
    final b = double.parse(_bCtrl.text);
    double res;
    switch (_op) {
      case '+':
        res = a + b;
        break;
      case '-':
        res = a - b;
        break;
      case '×':
        res = a * b;
        break;
      case '÷':
        res = (b == 0) ? double.nan : a / b;
        break;
      default:
        res = a;
    }
    setState(() {
      _result = res.isNaN ? 'Error (÷0)' : _format(res);
    });
  }

  String _format(double v) {
    final s = v.toStringAsFixed(10);
    return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
  }

  @override
  void dispose() {
    _aCtrl.dispose();
    _bCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = (String label, TextEditingController c) => TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [_numFormatter],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: _validator,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator (Form Fields)'),
        actions: [
          IconButton(
            tooltip: 'Switch to Buttons Mode',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/buttons'),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              field('Value A', _aCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _op,
                    items: const ['+', '-', '×', '÷']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: TextStyle(fontSize: 20)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _op = v!),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: field('Value B', _bCtrl)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _calc,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate'),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Result：$_result',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
