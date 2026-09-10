-- ============================================================================
-- SCRIPT COMPLETO: Agregar columna direccion e insertar 74 plazas faltantes
-- ============================================================================
-- Este script completa las 77 plazas en Supabase (actualmente solo existen 3)
-- Paso 1: Agregar columna direccion
-- Paso 2: ELIMINAR plazas duplicadas (IDs 4-77)
-- Paso 3: Insertar plazas 4-77
-- Paso 4: Actualizar direcciones de plazas 1-3 existentes
-- ============================================================================

-- PASO 1: Agregar columna direccion (si no existe)
-- ============================================================================
ALTER TABLE plazas 
ADD COLUMN IF NOT EXISTS direccion TEXT;

-- PASO 2: Eliminar plazas duplicadas con IDs 4-77 (si existen)
-- ============================================================================
-- Esto evita el error "duplicate key value violates unique constraint"
DELETE FROM plazas 
WHERE id IN (
  '4','5','6','7','8','9','10',
  '11','12','13','14','15','16','17','18','19','20',
  '21','22','23','24','25','26','27','28','29','30',
  '31','32','33','34','35','36','37','38','39','40',
  '41','42','43','44','45','46','47','48','49','50',
  '51','52','53','54','55','56','57','58','59','60',
  '61','62','63','64','65','66','67','68','69','70',
  '71','72','73','74','75','76','77'
);

-- PASO 3: Insertar las 74 plazas faltantes (IDs 4-77)
-- ============================================================================

-- Plaza 4
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('4', 'Monumento portal caballo lomiranda', 'Plaza Dura', 'Lo Miranda', -34.195218, -70.848973, 'Monumento Portal Lo Miranda en H-30 con H-270', true, 'Operativa', 'No aplica', 'No');

-- Plaza 5
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('5', 'Gabriela mistral Donihue', 'Plaza', 'Doñihue', -34.227638, -70.964722, 'A. Estacion con Estacion Carrera', true, 'Operativa', 'No aplica', 'No');

-- Plaza 6
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('6', 'Villa Centro', 'Plaza', 'Doñihue', -34.229011, -70.966619, 'Pedro Jose Vial/Humberto Vega F', true, 'Operativa', 'No aplica', 'No');

-- Plaza 7
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('7', 'Centro Emprendimiento Artesanal', 'Plaza', 'Doñihue', -34.228077, -70.968544, 'Bombero Vicente Carter con Emilio Cuevas', true, 'Operativa', 'No aplica', 'No');

-- Plaza 8
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('8', 'Villa Felipe Martinez A', 'Plaza', 'Doñihue', -34.224605, -70.966255, 'Av. Villar del Rio entre psje. Madrid y psje. Provincia de Soria', true, 'Operativa', 'No aplica', 'No');

-- Plaza 9
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('9', 'Villa Felipe Martinez B', 'Plaza', 'Doñihue', -34.224378, -70.965693, 'Av. Villar del Rio entre Maule y psje. Provincia de Soria', true, 'Operativa', 'No aplica', 'No');

-- Plaza 10
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('10', 'Villa Lo Carrasco A', 'Plaza', 'Doñihue', -34.224307, -70.967516, 'Daniel Carrasco referencia n 498', true, 'Operativa', 'No aplica', 'No');

-- Plaza 11
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('11', 'Villa Lo Carrasco B', 'Plaza', 'Doñihue', -34.224118, -70.966509, 'Daniel Carrasco con Psje. Cataluna', true, 'Operativa', 'No aplica', 'No');

-- Plaza 12
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('12', 'Villa Lo Carrasco C', 'Plaza', 'Doñihue', -34.223960, -70.965849, 'Maule entre psje. Navarra y psje. Cataluna', true, 'Operativa', 'No aplica', 'No');

-- Plaza 13
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('13', 'Dr. Sanhueza 1', 'Plaza', 'Doñihue', -34.222825, -70.962149, 'Dr Sanhueza 551 referencia', true, 'Operativa', 'No aplica', 'No');

-- Plaza 14
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('14', 'Dr. Sanhueza 2', 'Plaza', 'Doñihue', -34.222262, -70.961639, 'Dr. Sanhueza con Av. Rancagua', true, 'Operativa', 'No aplica', 'No');

-- Plaza 15
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('15', 'Plaza 21 de Mayo', 'Plaza', 'Doñihue', -34.227596, -70.962602, 'Errazuriz con Estacion Carrera', true, 'Operativa', 'No aplica', 'No');

-- Plaza 16
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('16', 'Plaza 21 de Mayo interior', 'Plaza', 'Doñihue', -34.228240, -70.961847, 'Plaza 21 de Mayo Interior', true, 'Operativa', 'No aplica', 'No');

-- Plaza 17
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('17', 'Villa O''Higgins 1', 'Plaza', 'Doñihue', -34.224352, -70.970161, 'Calle Los Copihues con Psje. Los Claveles', true, 'Operativa', 'No aplica', 'No');

-- Plaza 18
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('18', 'Villa O''Higgins 2', 'Plaza', 'Doñihue', -34.224276, -70.971991, 'Calle Los Copihues entre Psje. Los Gladiolos y M. A. Roman (Norte)', true, 'Operativa', 'No aplica', 'No');

-- Plaza 19
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('19', 'Villa O''Higgins Multicancha', 'Plaza Dura', 'Doñihue', -34.224539, -70.971713, 'Calle Los Copihues entre Psje. Los Gladiolos y M. A. Roman (Sur)', true, 'Operativa', 'No aplica', 'No');

-- Plaza 20
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('20', 'Villa Valles de San Francisco 1', 'Plaza', 'Doñihue', -34.226262, -70.971823, 'Calle M. A. Roman con Rio Claro', true, 'Operativa', 'No aplica', 'No');

-- Plaza 21
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('21', 'Villa Valles de San Francisco Cancha', 'Plaza', 'Doñihue', -34.225757, -70.971254, 'Manuel Antonio Roman con Pje. Rio Damas', true, 'Operativa', 'No aplica', 'No');

-- Plaza 22
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('22', 'Villa Valles de San Francisco 2', 'Plaza Dura', 'Doñihue', -34.225323, -70.971915, 'Manuel Antonio Roman con Rio Damas', true, 'Operativa', 'No aplica', 'No');

-- Plaza 23
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('23', 'Villa Quimavida', 'Plaza', 'Doñihue', -34.222843, -70.970999, 'Calle Las Rosas Fte. 40', true, 'Operativa', 'No aplica', 'No');

-- Plaza 24
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('24', 'Villa Eusebia exterior', 'Plaza', 'Doñihue', -34.222367, -70.971171, 'Calle Las Rosas 656', true, 'Operativa', 'No aplica', 'No');

-- Plaza 25
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('25', 'Villa Eusebia', 'Plaza', 'Doñihue', -34.221980, -70.970954, 'Calle Las Rosas con Psje. Camarico', true, 'Operativa', 'No aplica', 'No');

-- Plaza 26
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('26', 'Villa Eusebia interior', 'Plaza', 'Doñihue', -34.221629, -70.971629, 'Psje. Camarico con Psje. La Manta', true, 'Operativa', 'No aplica', 'No');

-- Plaza 27
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('27', 'Valles de san Francisco 2', 'Plaza Dura', 'Doñihue', -34.225356, -70.969348, 'Calle Rio Cisne con Emilio Cuevas', true, 'Operativa', 'No aplica', 'No');

-- Plaza 28
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('28', 'Paradero 27 -San juan', 'Plaza', 'Doñihue', -34.254417, -70.991418, 'Psje. Donihue con Ruta H30 Paradero 27', true, 'Operativa', 'No aplica', 'No');

-- Plaza 29
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('29', 'Paradero 17 Cerrillos', 'Plaza', 'Doñihue', -34.241188, -70.984443, 'Av. Cachapoal con Cerrillos', true, 'Operativa', 'No aplica', 'No');

-- Plaza 30
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('30', 'Bandejon cruze coinco', 'Bandejon Central', 'Doñihue', -34.228822, -70.957422, 'Ruta H-30 con Ruta H-38', true, 'Operativa', 'No aplica', 'No');

-- Plaza 31
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('31', 'Tres Esquinas 1', 'Plaza', 'Doñihue', -34.222707, -70.968898, 'Av. Rancagua y Pablo VI 47', true, 'Operativa', 'No aplica', 'No');

-- Plaza 32
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('32', 'Tres Esquinas 2', 'Plaza', 'Doñihue', -34.222211, -70.952834, 'Av. Rancagua entre H-29 y Juan Pablo II', true, 'Operativa', 'No aplica', 'No');

-- Plaza 33
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('33', 'La plazuela Oratorio rinconada', 'Plaza Dura', 'Doñihue', -34.206661, -70.943489, 'H29 SN', true, 'Operativa', 'No aplica', 'No');

-- Plaza 34
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('34', 'Plazuela Villa Aautralia', 'Plaza', 'Doñihue', -34.220947, -70.954710, 'Pasaje Sidney Fte. 33', true, 'Operativa', 'No aplica', 'No');

-- Plaza 35
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('35', 'Plazuela Villa Sol Del Rey', 'Plaza', 'Doñihue', -34.221195, -70.955347, 'Max Jara Fte. 0045', true, 'Operativa', 'No aplica', 'No');

-- Plaza 36
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('36', 'Plazuela Villa Las Palmas', 'Plaza', 'Doñihue', -34.221284, -70.956358, 'Psje. Maiten Fte. 260', true, 'Operativa', 'No aplica', 'No');

-- Plaza 37
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('37', 'Area Verde Santa Catalina 4', 'Plaza Dura', 'Doñihue', -34.224242, -70.959398, 'Aliro Gonzales Fte. 171', true, 'Operativa', 'No aplica', 'No');

-- Plaza 38
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('38', 'Area Verde Santa Catalina 5', 'Plaza Dura', 'Doñihue', -34.224322, -70.958612, 'Psje. Hugo Ortiz Fte 211', true, 'Operativa', 'No aplica', 'No');

-- Plaza 39
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('39', 'Area Verde Santa Catalina 6', 'Plaza Dura', 'Doñihue', -34.223666, -70.959196, 'Aliro Gonzales con Victor Perez Perez', true, 'Operativa', 'No aplica', 'No');

-- Plaza 40
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('40', 'Plazuela De lomiranda', 'Plaza', 'Lo Miranda', -34.191435, -70.909985, 'H-76 Plazuela Lo Miranda', true, 'Operativa', 'No aplica', 'No');

-- Plaza 41
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('41', 'Villa Lagos Fenix A', 'Plaza', 'Lo Miranda', -34.210077, -70.901748, 'Calle Central con Lago Rapel', true, 'Operativa', 'No aplica', 'No');

-- Plaza 42
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('42', 'Villa Lagos Fenix B', 'Plaza', 'Lo Miranda', -34.210019, -70.902457, 'Psje. Lago Llanquihue con Central', true, 'Operativa', 'No aplica', 'No');

-- Plaza 43
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('43', 'Area verde Villa el arrayan A', 'Plaza', 'Lo Miranda', -34.210389, -70.903560, 'Psje. Manquehue con Central', true, 'Operativa', 'No aplica', 'No');

-- Plaza 44
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('44', 'Area verde Villa el arrayan B', 'Plaza', 'Lo Miranda', -34.209854, -70.903183, 'Calle Central Fte. 023', true, 'Operativa', 'No aplica', 'No');

-- Plaza 45
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('45', 'Area Verde Gabriela Mistral', 'Plaza', 'Lo Miranda', -34.208744, -70.901031, 'Camino Vecinal SN', true, 'Operativa', 'No aplica', 'No');

-- Plaza 46
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('46', 'Area Verde Paradero 4', 'Plaza', 'Lo Miranda', -34.205467, -70.885553, 'Bernardo O''Higgins entre Los Laureles y Los Condores', true, 'Operativa', 'No aplica', 'No');

-- Plaza 47
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('47', 'Bandejon Central Ruta H-30', 'Plaza Dura', 'Lo Miranda', -34.205342, -70.900615, 'H-30 con Bernardo O''Higgins', true, 'Operativa', 'No aplica', 'No');

-- Plaza 48
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('48', 'Area Verde Galvarino', 'Plaza', 'Lo Miranda', -34.203107, -70.885696, 'Cam. Antiguo con Los Tiuques, Las Aguilas y Los Condores', true, 'Operativa', 'No aplica', 'No');

-- Plaza 49
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('49', 'Area Verde Caupolicam', 'Plaza', 'Lo Miranda', -34.203540, -70.886797, 'El Roble entre El Canelo y Camino Antiguo', true, 'Operativa', 'No aplica', 'No');

-- Plaza 50
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('50', 'Plaza villa lomiranda A', 'Plaza', 'Lo Miranda', -34.198997, -70.887679, 'Entre Psje. Astorga y Psje. El Boldo', true, 'Operativa', 'No aplica', 'No');

-- Plaza 51
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('51', 'Plaza villa lomiranda B', 'Plaza', 'Lo Miranda', -34.199774, -70.887274, 'Psje. Las Golondrinas Fte. 303', true, 'Operativa', 'No aplica', 'No');

-- Plaza 52
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('52', 'Plaza villa Hermosa', 'Plaza', 'Lo Miranda', -34.201524, -70.887170, 'Calle El Canelo Fte. 44', true, 'Operativa', 'No aplica', 'No');

-- Plaza 53
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('53', 'Plaza Sor Teresa', 'Plaza', 'Lo Miranda', -34.198703, -70.890048, 'Las Carmelitas con Rinconada de Auco', true, 'Operativa', 'No aplica', 'No');

-- Plaza 54
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('54', 'Area verde el Pedregal', 'Plaza', 'Lo Miranda', -34.199851, -70.894191, 'Los Diamantes con Los Opalos', true, 'Operativa', 'No aplica', 'No');

-- Plaza 55
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('55', 'Area verde Villa el Esfuerzo', 'Plaza', 'Lo Miranda', -34.198541, -70.895089, 'calle la union con el progreso', true, 'Operativa', 'No aplica', 'No');

-- Plaza 56
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('56', 'Area verde los Conquistadores', 'Plaza', 'Lo Miranda', -34.202057, -70.896403, 'Av. Diego de Almagro con Psje. Isabel La Catolica', true, 'Operativa', 'No aplica', 'No');

-- Plaza 57
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('57', 'Plaza Villa El Bosque', 'Plaza', 'Lo Miranda', -34.196912, -70.887995, 'Av. Las Dalias con Psje. Las Camelias', true, 'Operativa', 'No aplica', 'No');

-- Plaza 58
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('58', 'Plaza Villa Ilusion', 'Plaza', 'Lo Miranda', -34.196256, -70.888508, 'Calle Concejal Eduardo Miranda con Psje. 4 y C.A.', true, 'Operativa', 'No aplica', 'No');

-- Plaza 59
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('59', 'Area Verde Dona Victoria', 'Plaza', 'Lo Miranda', -34.195873, -70.887740, 'Calle Concejal Eduardo Miranda con Psje. A. Carlos Valentin', true, 'Operativa', 'No aplica', 'No');

-- Plaza 60
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('60', 'Area verde villa el Milagro', 'Plaza Dura', 'Lo Miranda', -34.195301, -70.886291, 'Rosa Zuniga con Psje. Juanito y Delfina', true, 'Operativa', 'No aplica', 'No');

-- Plaza 61
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('61', 'Area Verde Tricahue 1', 'Plaza', 'Lo Miranda', -34.193237, -70.888389, 'Villa Tricahue', true, 'Operativa', 'No aplica', 'No');

-- Plaza 62
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('62', 'Area Verde Tricahue 2', 'Plaza', 'Lo Miranda', -34.193493, -70.505602, 'Villa Tricahue 2', true, 'Operativa', 'No aplica', 'No');

-- Plaza 63
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('63', 'Area verde villa los andes 1', 'Plaza', 'Lo Miranda', -34.192289, -70.889690, 'H-280 con calle Cordillera y calle Los Urales', true, 'Operativa', 'No aplica', 'No');

-- Plaza 64
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('64', 'Area verde villa los andes 1.1', 'Plaza Dura', 'Lo Miranda', -34.192523, -70.889362, 'Calle Los Urales Fte.', true, 'Operativa', 'No aplica', 'No');

-- Plaza 65
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('65', 'Area verde villa los andes 2', 'Plaza', 'Lo Miranda', -34.191988, -70.888203, 'Calle Cordillera con Calle Los Urales', true, 'Operativa', 'No aplica', 'No');

-- Plaza 66
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('66', 'Plaza poblacion lautaro', 'Plaza', 'Lo Miranda', -34.204217, -70.880795, 'Bdo. O''Higgins con A. Bello, 18 de Septiembre y 21 de Mayo', true, 'Operativa', 'No aplica', 'No');

-- Plaza 67
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('67', 'Bandejon central FERIA', 'Plaza Dura', 'Lo Miranda', -34.205391, -70.869558, 'Bernardo O''Higgins entre Los Condores y Arturo Prat', true, 'Operativa', 'No aplica', 'No');

-- Plaza 68
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('68', 'Area verde villa esperanza', 'Plaza', 'Lo Miranda', -34.202715, -70.875043, 'H-30 con Villa Esperanza y Psje. Sagrado Corazon', true, 'Operativa', 'No aplica', 'No');

-- Plaza 69
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('69', 'Area verde villa esperanza 1', 'Plaza Dura', 'Lo Miranda', -34.203172, -70.876275, 'Psje. Lo Miranda Oriente', true, 'Operativa', 'No aplica', 'No');

-- Plaza 70
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('70', 'Cancha Villa Esperanza', 'Plaza', 'Lo Miranda', -34.202365, -70.889785, 'Calle entre Psje. San Jorge y Psje. Sagrado Corazon', true, 'Operativa', 'No aplica', 'No');

-- Plaza 71
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('71', 'Area verde villa esperanza 2', 'Plaza', 'Lo Miranda', -34.201087, -70.875511, 'Psje. Villa Luna y Psje. La Florida', true, 'Operativa', 'No aplica', 'No');

-- Plaza 72
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('72', 'Area verde villa esperanza 3', 'Plaza', 'Lo Miranda', -34.200819, -70.875870, 'Entre Psje. Union Comunal y Psje. La Florida', true, 'Operativa', 'No aplica', 'No');

-- Plaza 73
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('73', 'Santa Catalina 3', 'Plaza Dura', 'Lo Miranda', -34.224075, -70.960386, 'Calle Los Robles con calle Ximena Meneses', true, 'Operativa', 'No aplica', 'No');

-- Plaza 74
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('74', 'Santa Catalina 2', 'Plaza', 'Doñihue', -34.223721, -70.960574, 'Calle Victor Perez Perez con calle Los Robles', true, 'Operativa', 'No aplica', 'No');

-- Plaza 75
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('75', 'Santa Catalina 2.1', 'Plaza', 'Doñihue', -34.223117, -70.960720, 'Psje. Los Nires con calle Los Robles', true, 'Operativa', 'No aplica', 'No');

-- Plaza 76
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('76', 'Plaza de cerrillos paradero 17 CANAL', 'Plaza', 'Doñihue', -34.241462, -70.984197, 'Calle Cerrillos costado acequia', true, 'Operativa', 'No aplica', 'No');

-- Plaza 77
INSERT INTO plazas (id, nombre, tipo, comuna, latitud, longitud, direccion, activo, estado, estado_areas_verdes, estado_urgencias)
VALUES ('77', 'Plaza villa ohiggins 3', 'Plaza', 'Doñihue', -34.224683, -70.969671, 'Psje. Las Violetas entre Los Copihues y Psje. Los Claveles', true, 'Operativa', 'No aplica', 'No');

-- PASO 4: Actualizar direcciones de las 3 plazas existentes (IDs 1-3)
-- ============================================================================

UPDATE plazas 
SET direccion = 'Delfin Carvallo con Subteniente Valenzuela'
WHERE id = '1';

UPDATE plazas 
SET direccion = 'Letras Turisticas Donihue en H-10 con H-286'
WHERE id = '2';

UPDATE plazas 
SET direccion = 'Cabo Moena entre H-286 y H-276'
WHERE id = '3';

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
-- Resultado esperado: 77 plazas con columna direccion poblada
-- ============================================================================
