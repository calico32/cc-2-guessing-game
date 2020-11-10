// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamedata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameData _$GameDataFromJson(Map<String, dynamic> json) {
  return GameData(
    min: json['min'] as int,
    max: json['max'] as int,
    targetNumber: json['target_number'] as int,
    guesses: (json['guesses'] as List)?.map((e) => e as int)?.toList(),
  );
}

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'guesses': instance.guesses,
      'target_number': instance.targetNumber,
      'min': instance.min,
      'max': instance.max,
    };
