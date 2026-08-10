// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, String>
  transactionType =
      GeneratedColumn<String>(
        'transaction_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransactionType>(
        $TransactionsTable.$convertertransactionType,
      );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('VND'),
  );
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<int> balanceAfter = GeneratedColumn<int>(
    'balance_after',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionTimeMeta = const VerificationMeta(
    'transactionTime',
  );
  @override
  late final GeneratedColumn<DateTime> transactionTime =
      GeneratedColumn<DateTime>(
        'transaction_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _transactionCodeMeta = const VerificationMeta(
    'transactionCode',
  );
  @override
  late final GeneratedColumn<String> transactionCode = GeneratedColumn<String>(
    'transaction_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawNotificationMeta = const VerificationMeta(
    'rawNotification',
  );
  @override
  late final GeneratedColumn<String> rawNotification = GeneratedColumn<String>(
    'raw_notification',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourcePackageMeta = const VerificationMeta(
    'sourcePackage',
  );
  @override
  late final GeneratedColumn<String> sourcePackage = GeneratedColumn<String>(
    'source_package',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionType,
    amount,
    currency,
    account,
    description,
    balanceAfter,
    transactionTime,
    transactionCode,
    rawNotification,
    sourcePackage,
    createdAt,
    fingerprint,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    }
    if (data.containsKey('transaction_time')) {
      context.handle(
        _transactionTimeMeta,
        transactionTime.isAcceptableOrUnknown(
          data['transaction_time']!,
          _transactionTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTimeMeta);
    }
    if (data.containsKey('transaction_code')) {
      context.handle(
        _transactionCodeMeta,
        transactionCode.isAcceptableOrUnknown(
          data['transaction_code']!,
          _transactionCodeMeta,
        ),
      );
    }
    if (data.containsKey('raw_notification')) {
      context.handle(
        _rawNotificationMeta,
        rawNotification.isAcceptableOrUnknown(
          data['raw_notification']!,
          _rawNotificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawNotificationMeta);
    }
    if (data.containsKey('source_package')) {
      context.handle(
        _sourcePackageMeta,
        sourcePackage.isAcceptableOrUnknown(
          data['source_package']!,
          _sourcePackageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourcePackageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionType: $TransactionsTable.$convertertransactionType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}transaction_type'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_after'],
      ),
      transactionTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_time'],
      )!,
      transactionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_code'],
      ),
      rawNotification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_notification'],
      )!,
      sourcePackage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_package'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<TransactionType, String> $convertertransactionType =
      const TransactionTypeConverter();
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final int id;
  final TransactionType transactionType;
  final int amount;
  final String currency;
  final String? account;
  final String description;
  final int? balanceAfter;
  final DateTime transactionTime;
  final String? transactionCode;

  /// Toàn bộ nội dung notification gốc — dùng để debug parser.
  final String rawNotification;
  final String sourcePackage;
  final DateTime createdAt;
  final String? fingerprint;

  /// Ghi chú cá nhân do người dùng tự gõ (Phase 11) — đồng bộ qua Supabase
  /// bằng [fingerprint] làm khóa, KHÔNG đồng bộ account/rawNotification.
  /// Không null (mặc định rỗng, giống [description]) — SQLite cho phép
  /// `ALTER TABLE ADD COLUMN` kèm `DEFAULT ''` áp cho toàn bộ dòng cũ ngay,
  /// không cần backfill thủ công như [fingerprint].
  final String note;
  const TransactionRow({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.currency,
    this.account,
    required this.description,
    this.balanceAfter,
    required this.transactionTime,
    this.transactionCode,
    required this.rawNotification,
    required this.sourcePackage,
    required this.createdAt,
    this.fingerprint,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['transaction_type'] = Variable<String>(
        $TransactionsTable.$convertertransactionType.toSql(transactionType),
      );
    }
    map['amount'] = Variable<int>(amount);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || account != null) {
      map['account'] = Variable<String>(account);
    }
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || balanceAfter != null) {
      map['balance_after'] = Variable<int>(balanceAfter);
    }
    map['transaction_time'] = Variable<DateTime>(transactionTime);
    if (!nullToAbsent || transactionCode != null) {
      map['transaction_code'] = Variable<String>(transactionCode);
    }
    map['raw_notification'] = Variable<String>(rawNotification);
    map['source_package'] = Variable<String>(sourcePackage);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || fingerprint != null) {
      map['fingerprint'] = Variable<String>(fingerprint);
    }
    map['note'] = Variable<String>(note);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      transactionType: Value(transactionType),
      amount: Value(amount),
      currency: Value(currency),
      account: account == null && nullToAbsent
          ? const Value.absent()
          : Value(account),
      description: Value(description),
      balanceAfter: balanceAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceAfter),
      transactionTime: Value(transactionTime),
      transactionCode: transactionCode == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionCode),
      rawNotification: Value(rawNotification),
      sourcePackage: Value(sourcePackage),
      createdAt: Value(createdAt),
      fingerprint: fingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(fingerprint),
      note: Value(note),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<int>(json['id']),
      transactionType: serializer.fromJson<TransactionType>(
        json['transactionType'],
      ),
      amount: serializer.fromJson<int>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      account: serializer.fromJson<String?>(json['account']),
      description: serializer.fromJson<String>(json['description']),
      balanceAfter: serializer.fromJson<int?>(json['balanceAfter']),
      transactionTime: serializer.fromJson<DateTime>(json['transactionTime']),
      transactionCode: serializer.fromJson<String?>(json['transactionCode']),
      rawNotification: serializer.fromJson<String>(json['rawNotification']),
      sourcePackage: serializer.fromJson<String>(json['sourcePackage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      fingerprint: serializer.fromJson<String?>(json['fingerprint']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionType': serializer.toJson<TransactionType>(transactionType),
      'amount': serializer.toJson<int>(amount),
      'currency': serializer.toJson<String>(currency),
      'account': serializer.toJson<String?>(account),
      'description': serializer.toJson<String>(description),
      'balanceAfter': serializer.toJson<int?>(balanceAfter),
      'transactionTime': serializer.toJson<DateTime>(transactionTime),
      'transactionCode': serializer.toJson<String?>(transactionCode),
      'rawNotification': serializer.toJson<String>(rawNotification),
      'sourcePackage': serializer.toJson<String>(sourcePackage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'fingerprint': serializer.toJson<String?>(fingerprint),
      'note': serializer.toJson<String>(note),
    };
  }

  TransactionRow copyWith({
    int? id,
    TransactionType? transactionType,
    int? amount,
    String? currency,
    Value<String?> account = const Value.absent(),
    String? description,
    Value<int?> balanceAfter = const Value.absent(),
    DateTime? transactionTime,
    Value<String?> transactionCode = const Value.absent(),
    String? rawNotification,
    String? sourcePackage,
    DateTime? createdAt,
    Value<String?> fingerprint = const Value.absent(),
    String? note,
  }) => TransactionRow(
    id: id ?? this.id,
    transactionType: transactionType ?? this.transactionType,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    account: account.present ? account.value : this.account,
    description: description ?? this.description,
    balanceAfter: balanceAfter.present ? balanceAfter.value : this.balanceAfter,
    transactionTime: transactionTime ?? this.transactionTime,
    transactionCode: transactionCode.present
        ? transactionCode.value
        : this.transactionCode,
    rawNotification: rawNotification ?? this.rawNotification,
    sourcePackage: sourcePackage ?? this.sourcePackage,
    createdAt: createdAt ?? this.createdAt,
    fingerprint: fingerprint.present ? fingerprint.value : this.fingerprint,
    note: note ?? this.note,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      account: data.account.present ? data.account.value : this.account,
      description: data.description.present
          ? data.description.value
          : this.description,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      transactionTime: data.transactionTime.present
          ? data.transactionTime.value
          : this.transactionTime,
      transactionCode: data.transactionCode.present
          ? data.transactionCode.value
          : this.transactionCode,
      rawNotification: data.rawNotification.present
          ? data.rawNotification.value
          : this.rawNotification,
      sourcePackage: data.sourcePackage.present
          ? data.sourcePackage.value
          : this.sourcePackage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('account: $account, ')
          ..write('description: $description, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('transactionTime: $transactionTime, ')
          ..write('transactionCode: $transactionCode, ')
          ..write('rawNotification: $rawNotification, ')
          ..write('sourcePackage: $sourcePackage, ')
          ..write('createdAt: $createdAt, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionType,
    amount,
    currency,
    account,
    description,
    balanceAfter,
    transactionTime,
    transactionCode,
    rawNotification,
    sourcePackage,
    createdAt,
    fingerprint,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.transactionType == this.transactionType &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.account == this.account &&
          other.description == this.description &&
          other.balanceAfter == this.balanceAfter &&
          other.transactionTime == this.transactionTime &&
          other.transactionCode == this.transactionCode &&
          other.rawNotification == this.rawNotification &&
          other.sourcePackage == this.sourcePackage &&
          other.createdAt == this.createdAt &&
          other.fingerprint == this.fingerprint &&
          other.note == this.note);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<int> id;
  final Value<TransactionType> transactionType;
  final Value<int> amount;
  final Value<String> currency;
  final Value<String?> account;
  final Value<String> description;
  final Value<int?> balanceAfter;
  final Value<DateTime> transactionTime;
  final Value<String?> transactionCode;
  final Value<String> rawNotification;
  final Value<String> sourcePackage;
  final Value<DateTime> createdAt;
  final Value<String?> fingerprint;
  final Value<String> note;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.account = const Value.absent(),
    this.description = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.transactionTime = const Value.absent(),
    this.transactionCode = const Value.absent(),
    this.rawNotification = const Value.absent(),
    this.sourcePackage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.note = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required TransactionType transactionType,
    required int amount,
    this.currency = const Value.absent(),
    this.account = const Value.absent(),
    this.description = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    required DateTime transactionTime,
    this.transactionCode = const Value.absent(),
    required String rawNotification,
    required String sourcePackage,
    this.createdAt = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.note = const Value.absent(),
  }) : transactionType = Value(transactionType),
       amount = Value(amount),
       transactionTime = Value(transactionTime),
       rawNotification = Value(rawNotification),
       sourcePackage = Value(sourcePackage);
  static Insertable<TransactionRow> custom({
    Expression<int>? id,
    Expression<String>? transactionType,
    Expression<int>? amount,
    Expression<String>? currency,
    Expression<String>? account,
    Expression<String>? description,
    Expression<int>? balanceAfter,
    Expression<DateTime>? transactionTime,
    Expression<String>? transactionCode,
    Expression<String>? rawNotification,
    Expression<String>? sourcePackage,
    Expression<DateTime>? createdAt,
    Expression<String>? fingerprint,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionType != null) 'transaction_type': transactionType,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (account != null) 'account': account,
      if (description != null) 'description': description,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (transactionTime != null) 'transaction_time': transactionTime,
      if (transactionCode != null) 'transaction_code': transactionCode,
      if (rawNotification != null) 'raw_notification': rawNotification,
      if (sourcePackage != null) 'source_package': sourcePackage,
      if (createdAt != null) 'created_at': createdAt,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (note != null) 'note': note,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<TransactionType>? transactionType,
    Value<int>? amount,
    Value<String>? currency,
    Value<String?>? account,
    Value<String>? description,
    Value<int?>? balanceAfter,
    Value<DateTime>? transactionTime,
    Value<String?>? transactionCode,
    Value<String>? rawNotification,
    Value<String>? sourcePackage,
    Value<DateTime>? createdAt,
    Value<String?>? fingerprint,
    Value<String>? note,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      account: account ?? this.account,
      description: description ?? this.description,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      transactionTime: transactionTime ?? this.transactionTime,
      transactionCode: transactionCode ?? this.transactionCode,
      rawNotification: rawNotification ?? this.rawNotification,
      sourcePackage: sourcePackage ?? this.sourcePackage,
      createdAt: createdAt ?? this.createdAt,
      fingerprint: fingerprint ?? this.fingerprint,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(
        $TransactionsTable.$convertertransactionType.toSql(
          transactionType.value,
        ),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<int>(balanceAfter.value);
    }
    if (transactionTime.present) {
      map['transaction_time'] = Variable<DateTime>(transactionTime.value);
    }
    if (transactionCode.present) {
      map['transaction_code'] = Variable<String>(transactionCode.value);
    }
    if (rawNotification.present) {
      map['raw_notification'] = Variable<String>(rawNotification.value);
    }
    if (sourcePackage.present) {
      map['source_package'] = Variable<String>(sourcePackage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('account: $account, ')
          ..write('description: $description, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('transactionTime: $transactionTime, ')
          ..write('transactionCode: $transactionCode, ')
          ..write('rawNotification: $rawNotification, ')
          ..write('sourcePackage: $sourcePackage, ')
          ..write('createdAt: $createdAt, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final Index transactionsFingerprintIdx = Index(
    'transactions_fingerprint_idx',
    'CREATE UNIQUE INDEX transactions_fingerprint_idx ON transactions (fingerprint)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    transactionsFingerprintIdx,
  ];
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required TransactionType transactionType,
      required int amount,
      Value<String> currency,
      Value<String?> account,
      Value<String> description,
      Value<int?> balanceAfter,
      required DateTime transactionTime,
      Value<String?> transactionCode,
      required String rawNotification,
      required String sourcePackage,
      Value<DateTime> createdAt,
      Value<String?> fingerprint,
      Value<String> note,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<TransactionType> transactionType,
      Value<int> amount,
      Value<String> currency,
      Value<String?> account,
      Value<String> description,
      Value<int?> balanceAfter,
      Value<DateTime> transactionTime,
      Value<String?> transactionCode,
      Value<String> rawNotification,
      Value<String> sourcePackage,
      Value<DateTime> createdAt,
      Value<String?> fingerprint,
      Value<String> note,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, String>
  get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionTime => $composableBuilder(
    column: $table.transactionTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionCode => $composableBuilder(
    column: $table.transactionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawNotification => $composableBuilder(
    column: $table.rawNotification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePackage => $composableBuilder(
    column: $table.sourcePackage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionTime => $composableBuilder(
    column: $table.transactionTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionCode => $composableBuilder(
    column: $table.transactionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawNotification => $composableBuilder(
    column: $table.rawNotification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePackage => $composableBuilder(
    column: $table.sourcePackage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, String>
  get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionTime => $composableBuilder(
    column: $table.transactionTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionCode => $composableBuilder(
    column: $table.transactionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawNotification => $composableBuilder(
    column: $table.rawNotification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourcePackage => $composableBuilder(
    column: $table.sourcePackage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionRow,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
          ),
          TransactionRow,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<TransactionType> transactionType = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> account = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int?> balanceAfter = const Value.absent(),
                Value<DateTime> transactionTime = const Value.absent(),
                Value<String?> transactionCode = const Value.absent(),
                Value<String> rawNotification = const Value.absent(),
                Value<String> sourcePackage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> fingerprint = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                transactionType: transactionType,
                amount: amount,
                currency: currency,
                account: account,
                description: description,
                balanceAfter: balanceAfter,
                transactionTime: transactionTime,
                transactionCode: transactionCode,
                rawNotification: rawNotification,
                sourcePackage: sourcePackage,
                createdAt: createdAt,
                fingerprint: fingerprint,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required TransactionType transactionType,
                required int amount,
                Value<String> currency = const Value.absent(),
                Value<String?> account = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int?> balanceAfter = const Value.absent(),
                required DateTime transactionTime,
                Value<String?> transactionCode = const Value.absent(),
                required String rawNotification,
                required String sourcePackage,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> fingerprint = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                transactionType: transactionType,
                amount: amount,
                currency: currency,
                account: account,
                description: description,
                balanceAfter: balanceAfter,
                transactionTime: transactionTime,
                transactionCode: transactionCode,
                rawNotification: rawNotification,
                sourcePackage: sourcePackage,
                createdAt: createdAt,
                fingerprint: fingerprint,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionRow,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
      ),
      TransactionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
