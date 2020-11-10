import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gamedata.g.dart';

@JsonSerializable()
class GameData {
  List<int> guesses;
  @JsonKey(name: 'target_number')
  int targetNumber;
  int min;
  int max;

  GameData({
    @required this.min,
    @required this.max,
    @required this.targetNumber,
    @required this.guesses,
  });

  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);
  Map<String, dynamic> toJson() => _$GameDataToJson(this);
}
