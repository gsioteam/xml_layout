


import 'types/colors.dart' as color;
import 'types/text.dart' as text;
import 'types/paint.dart' as paint;
import 'types/image.dart' as image;
import 'types/layout.dart' as layout;
import 'types/icons.dart' as icons;
import 'types/list.dart' as list;

double _parseDouble(String v) {
  v = v.trim();
  if (v.length > 0) {
    try {
      return double.parse(v);
    } catch (e) {

    }
  }
  return null;
}

void initTypes() {

  color.reg();
  text.reg();
  paint.reg();
  image.reg();
  layout.reg();
  icons.reg();
  list.reg();
}