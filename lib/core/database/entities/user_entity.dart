import 'package:objectbox/objectbox.dart';

@Entity()
class UserEntity {
  int id = 0;
  String name;

  UserEntity({required this.name});
}
