import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  static const Color _primaryColor = Color(0xFF4A55A2);

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _result = '—';
  String? _errorText;

  final List<String> basicButtons = [
    'AC',
    '()',
    '%',
    '÷',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '+',
    '1',
    '2',
    '3',
    '-',
    '0',
    '.',
    '⌫',
    '=',
  ];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onExpressionChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _inputController.removeListener(_onExpressionChanged);
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onExpressionChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
    _recalculateLiveResult();
  }

  void onButtonPressed(String buttonText) {
    if (buttonText == 'AC') {
      _setExpression('');
      return;
    }

    if (buttonText == '⌫') {
      _deleteSelectionOrPreviousCharacter();
      return;
    }

    if (buttonText == '()') {
      _insertParentheses();
      return;
    }

    if (buttonText == '=') {
      _evaluateCurrentExpression(forceError: true);
      return;
    }

    _insertText(buttonText);
  }

  void _setExpression(String value) {
    _inputController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _insertText(String text) {
    final TextEditingValue value = _inputController.value;
    final TextSelection selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);

    if (text == '.') {
      final String beforeSelection = value.text.substring(0, selection.start);
      final String afterSelection = value.text.substring(selection.end);
      final String activeSegment = _getActiveNumericSegment(
        value.text,
        selection.start,
      );

      if (activeSegment.contains('.')) {
        return;
      }

      final String insertion =
          beforeSelection.isEmpty ||
              _shouldPrefixLeadingDecimal(beforeSelection)
          ? '0.'
          : '.';

      _inputController.value = TextEditingValue(
        text: '$beforeSelection$insertion$afterSelection',
        selection: TextSelection.collapsed(
          offset: beforeSelection.length + insertion.length,
        ),
      );
      return;
    }

    if (_isOperatorToken(text)) {
      final String beforeSelection = value.text.substring(0, selection.start);
      final String afterSelection = value.text.substring(selection.end);

      if (beforeSelection.isEmpty) {
        if (text != '-') {
          return;
        }
      } else {
        final String previousCharacter =
            beforeSelection[beforeSelection.length - 1];

        if (_isOperatorToken(previousCharacter)) {
          final String normalizedBefore = beforeSelection.substring(
            0,
            beforeSelection.length - 1,
          );
          _inputController.value = TextEditingValue(
            text: '$normalizedBefore$text$afterSelection',
            selection: TextSelection.collapsed(
              offset: normalizedBefore.length + text.length,
            ),
          );
          return;
        }

        if (previousCharacter == '(' && text != '-') {
          return;
        }
      }

      _inputController.value = TextEditingValue(
        text: '$beforeSelection$text$afterSelection',
        selection: TextSelection.collapsed(
          offset: beforeSelection.length + text.length,
        ),
      );
      return;
    }

    final String updatedText = value.text.replaceRange(
      selection.start,
      selection.end,
      text,
    );

    _inputController.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: selection.start + text.length),
    );
  }

  void _recalculateLiveResult() {
    _evaluateCurrentExpression(forceError: false);
  }

  void _evaluateCurrentExpression({required bool forceError}) {
    final String expression = _inputController.text.trim();

    if (expression.isEmpty) {
      setState(() {
        _result = '—';
        _errorText = null;
      });
      return;
    }

    try {
      final double value = _evaluateExpression(expression);
      setState(() {
        _result = _formatNumber(value);
        _errorText = null;
      });
    } on FormatException catch (error) {
      final String message = error.message;
      final bool isIncomplete =
          message == 'Enter an expression' ||
          message == 'Incomplete expression' ||
          message == 'Mismatched parentheses';

      if (!forceError && isIncomplete) {
        setState(() {
          _result = '—';
          _errorText = null;
        });
        return;
      }

      setState(() {
        _result = 'Error';
        _errorText = message;
      });
    } catch (_) {
      setState(() {
        _result = 'Error';
        _errorText = 'Invalid expression';
      });
    }
  }

  void _deleteSelectionOrPreviousCharacter() {
    final TextEditingValue value = _inputController.value;
    final TextSelection selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);

    if (!selection.isCollapsed) {
      _inputController.value = TextEditingValue(
        text: value.text.replaceRange(selection.start, selection.end, ''),
        selection: TextSelection.collapsed(offset: selection.start),
      );
      return;
    }

    if (selection.start == 0) {
      return;
    }

    _inputController.value = TextEditingValue(
      text: value.text.replaceRange(selection.start - 1, selection.start, ''),
      selection: TextSelection.collapsed(offset: selection.start - 1),
    );
  }

  bool _isOperatorToken(String token) {
    return token == '+' ||
        token == '-' ||
        token == '×' ||
        token == '÷' ||
        token == '*' ||
        token == '/' ||
        token == '%';
  }

  bool _shouldPrefixLeadingDecimal(String beforeSelection) {
    if (beforeSelection.isEmpty) {
      return true;
    }

    final String previousCharacter =
        beforeSelection[beforeSelection.length - 1];
    return _isOperatorToken(previousCharacter) || previousCharacter == '(';
  }

  String _getActiveNumericSegment(String text, int cursorOffset) {
    int start = cursorOffset;
    while (start > 0) {
      final String previousCharacter = text[start - 1];
      if (_isHardBoundary(previousCharacter)) {
        break;
      }

      if (previousCharacter == '-' && !_isUnaryMinus(text, start - 1)) {
        break;
      }

      start--;
    }

    int end = cursorOffset;
    while (end < text.length) {
      final String currentCharacter = text[end];
      if (_isHardBoundary(currentCharacter)) {
        break;
      }

      if (currentCharacter == '-' && !_isUnaryMinus(text, end)) {
        break;
      }

      end++;
    }

    return text.substring(start, end);
  }

  bool _isHardBoundary(String character) {
    return character == '+' ||
        character == '×' ||
        character == '÷' ||
        character == '*' ||
        character == '/' ||
        character == '%' ||
        character == '(' ||
        character == ')';
  }

  bool _isUnaryMinus(String text, int index) {
    if (index < 0 || text[index] != '-') {
      return false;
    }

    if (index == 0) {
      return true;
    }

    final String previousCharacter = text[index - 1];
    return _isOperatorToken(previousCharacter) || previousCharacter == '(';
  }

  void _insertParentheses() {
    final TextEditingValue value = _inputController.value;
    final TextSelection selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);

    if (!selection.isCollapsed) {
      final String selectedText = value.text.substring(
        selection.start,
        selection.end,
      );
      _inputController.value = TextEditingValue(
        text: value.text.replaceRange(
          selection.start,
          selection.end,
          '($selectedText)',
        ),
        selection: TextSelection.collapsed(
          offset: selection.start + selectedText.length + 2,
        ),
      );
      return;
    }

    final String beforeCursor = value.text.substring(0, selection.start);
    final int openCount =
        '('.allMatches(beforeCursor).length -
        ')'.allMatches(beforeCursor).length;
    final String previousCharacter = selection.start > 0
        ? value.text[selection.start - 1]
        : '';
    final bool shouldInsertClosing =
        openCount > 0 && RegExp(r'[0-9.)%]').hasMatch(previousCharacter);

    final String insertion = shouldInsertClosing ? ')' : '(';
    _inputController.value = TextEditingValue(
      text: value.text.replaceRange(selection.start, selection.end, insertion),
      selection: TextSelection.collapsed(
        offset: selection.start + insertion.length,
      ),
    );
  }

  String _formatNumber(double value) {
    if (value.isNaN || value.isInfinite) {
      throw const FormatException('Invalid result');
    }

    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toStringAsFixed(0);
    }

    String formatted = value.toStringAsFixed(10);
    formatted = formatted.replaceFirst(RegExp(r'0+$'), '');
    formatted = formatted.replaceFirst(RegExp(r'\.$'), '');
    return formatted;
  }

  double _evaluateExpression(String expression) {
    final List<_Token> tokens = _tokenize(expression);
    final List<_Token> postfix = _toPostfix(tokens);
    return _evaluatePostfix(postfix);
  }

  List<_Token> _tokenize(String expression) {
    final String normalized = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(' ', '');

    if (normalized.isEmpty) {
      throw const FormatException('Enter an expression');
    }

    final List<_Token> tokens = [];
    int index = 0;

    while (index < normalized.length) {
      final String character = normalized[index];

      if (_isDigit(character) || character == '.') {
        final int start = index;
        bool hasDecimalPoint = character == '.';
        index++;

        while (index < normalized.length) {
          final String nextCharacter = normalized[index];
          if (_isDigit(nextCharacter)) {
            index++;
            continue;
          }

          if (nextCharacter == '.') {
            if (hasDecimalPoint) {
              throw const FormatException('Invalid number format');
            }
            hasDecimalPoint = true;
            index++;
            continue;
          }

          break;
        }

        final String numberText = normalized.substring(start, index);
        if (numberText == '.') {
          throw const FormatException('Invalid number format');
        }

        tokens.add(_Token.number(double.parse(numberText)));
        continue;
      }

      if (character == '(') {
        if (tokens.isNotEmpty &&
            _canPrecedeImplicitMultiplication(tokens.last)) {
          tokens.add(const _Token.binaryOperator('*'));
        }
        tokens.add(const _Token.leftParenthesis());
        index++;
        continue;
      }

      if (character == ')') {
        tokens.add(const _Token.rightParenthesis());
        index++;
        continue;
      }

      if (character == '%') {
        tokens.add(const _Token.unaryOperator(_UnaryOperator.percent));
        index++;
        continue;
      }

      if (_isOperator(character)) {
        final bool isUnaryMinus =
            character == '-' &&
            (tokens.isEmpty ||
                tokens.last.type == _TokenType.leftParenthesis ||
                tokens.last.type == _TokenType.binaryOperator ||
                tokens.last.type == _TokenType.unaryOperator);

        if (character == '+' &&
            (tokens.isEmpty ||
                tokens.last.type == _TokenType.leftParenthesis ||
                tokens.last.type == _TokenType.binaryOperator ||
                tokens.last.type == _TokenType.unaryOperator)) {
          index++;
          continue;
        }

        tokens.add(
          isUnaryMinus
              ? const _Token.unaryOperator(_UnaryOperator.negate)
              : _Token.binaryOperator(character),
        );
        index++;
        continue;
      }

      throw FormatException('Invalid character: $character');
    }

    return tokens;
  }

  List<_Token> _toPostfix(List<_Token> tokens) {
    final List<_Token> output = [];
    final List<_Token> operatorStack = [];

    for (final _Token token in tokens) {
      switch (token.type) {
        case _TokenType.number:
          output.add(token);
          break;
        case _TokenType.unaryOperator:
        case _TokenType.binaryOperator:
          while (operatorStack.isNotEmpty &&
              operatorStack.last.isOperator &&
              ((token.isRightAssociative &&
                      token.precedence < operatorStack.last.precedence) ||
                  (!token.isRightAssociative &&
                      token.precedence <= operatorStack.last.precedence))) {
            output.add(operatorStack.removeLast());
          }
          operatorStack.add(token);
          break;
        case _TokenType.leftParenthesis:
          operatorStack.add(token);
          break;
        case _TokenType.rightParenthesis:
          var foundLeftParenthesis = false;

          while (operatorStack.isNotEmpty) {
            final _Token operator = operatorStack.removeLast();
            if (operator.type == _TokenType.leftParenthesis) {
              foundLeftParenthesis = true;
              break;
            }
            output.add(operator);
          }

          if (!foundLeftParenthesis) {
            throw const FormatException('Mismatched parentheses');
          }

          while (operatorStack.isNotEmpty &&
              operatorStack.last.type == _TokenType.unaryOperator) {
            output.add(operatorStack.removeLast());
          }
          break;
      }
    }

    while (operatorStack.isNotEmpty) {
      final _Token token = operatorStack.removeLast();
      if (token.type == _TokenType.leftParenthesis ||
          token.type == _TokenType.rightParenthesis) {
        throw const FormatException('Mismatched parentheses');
      }
      output.add(token);
    }

    return output;
  }

  double _evaluatePostfix(List<_Token> tokens) {
    final List<double> stack = [];

    for (final _Token token in tokens) {
      switch (token.type) {
        case _TokenType.number:
          stack.add(token.numberValue!);
          break;
        case _TokenType.unaryOperator:
          if (stack.isEmpty) {
            throw const FormatException('Incomplete expression');
          }

          final double value = stack.removeLast();
          stack.add(
            token.unaryOperator == _UnaryOperator.negate ? -value : value / 100,
          );
          break;
        case _TokenType.binaryOperator:
          if (stack.length < 2) {
            throw const FormatException('Incomplete expression');
          }

          final double right = stack.removeLast();
          final double left = stack.removeLast();

          switch (token.operator) {
            case '+':
              stack.add(left + right);
              break;
            case '-':
              stack.add(left - right);
              break;
            case '*':
              stack.add(left * right);
              break;
            case '/':
              if (right == 0) {
                throw const FormatException('Cannot divide by zero');
              }
              stack.add(left / right);
              break;
          }
          break;
        case _TokenType.leftParenthesis:
        case _TokenType.rightParenthesis:
          throw const FormatException('Unexpected parenthesis');
      }
    }

    if (stack.length != 1) {
      throw const FormatException('Invalid expression');
    }

    return stack.single;
  }

  bool _isDigit(String character) => RegExp(r'^\d$').hasMatch(character);

  bool _isOperator(String character) {
    return character == '+' ||
        character == '-' ||
        character == '*' ||
        character == '/';
  }

  bool _canPrecedeImplicitMultiplication(_Token token) {
    return token.type == _TokenType.number ||
        token.type == _TokenType.rightParenthesis ||
        (token.type == _TokenType.unaryOperator &&
            token.unaryOperator == _UnaryOperator.percent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Calculator'),
        actions: [IconButton(icon: Icon(Icons.expand_less), onPressed: () {
          basicButtons.insertAll(0, ['sin', 'cos', 'tan', 'log', 'ln', '√']);
          setState(() {});
        })],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                child: Column(
                  children: [
                    Card(
                      child: TextField(
                        controller: _inputController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.none,
                        readOnly: true,
                        showCursor: true,
                        cursorColor: _primaryColor,
                        enableInteractiveSelection: true,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 22),
                        decoration: InputDecoration(
                          errorText: _errorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _result,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.1,
                        ),
                    itemCount: basicButtons.length,
                    itemBuilder: (context, index) {
                      final String buttonText = basicButtons[index];
                      final bool isActionButton =
                          buttonText == 'AC' ||
                          buttonText == '⌫' ||
                          buttonText == '=';
                      final bool isOperatorButton = [
                        '÷',
                        '×',
                        '+',
                        '-',
                        '%',
                        '()',
                      ].contains(buttonText);

                      return GestureDetector(
                        onTap: () => onButtonPressed(buttonText),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isActionButton
                                ? Colors.deepOrange
                                : isOperatorButton
                                ? const Color(0xFFE8ECFF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              buttonText,
                              style: TextStyle(
                                fontSize: buttonText == '=' ? 28 : 24,
                                fontWeight: FontWeight.w600,
                                color: isActionButton
                                    ? Colors.white
                                    : const Color(0xFF222222),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TokenType {
  number,
  unaryOperator,
  binaryOperator,
  leftParenthesis,
  rightParenthesis,
}

enum _UnaryOperator { negate, percent }

class _Token {
  const _Token._(
    this.type, {
    this.numberValue,
    this.operator,
    this.unaryOperator,
  });

  const _Token.number(double value)
    : this._(_TokenType.number, numberValue: value);

  const _Token.binaryOperator(String operator)
    : this._(_TokenType.binaryOperator, operator: operator);

  const _Token.unaryOperator(_UnaryOperator unaryOperator)
    : this._(_TokenType.unaryOperator, unaryOperator: unaryOperator);

  const _Token.leftParenthesis() : this._(_TokenType.leftParenthesis);

  const _Token.rightParenthesis() : this._(_TokenType.rightParenthesis);

  final _TokenType type;
  final double? numberValue;
  final String? operator;
  final _UnaryOperator? unaryOperator;

  bool get isOperator =>
      type == _TokenType.binaryOperator || type == _TokenType.unaryOperator;

  int get precedence {
    switch (type) {
      case _TokenType.unaryOperator:
        return 4;
      case _TokenType.binaryOperator:
        switch (operator) {
          case '*':
          case '/':
            return 3;
          case '+':
          case '-':
            return 2;
        }
        return 0;
      default:
        return 0;
    }
  }

  bool get isRightAssociative => type == _TokenType.unaryOperator;
}
