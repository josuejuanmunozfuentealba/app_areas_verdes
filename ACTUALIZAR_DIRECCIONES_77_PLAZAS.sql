-- ============================================================================
-- ACTUALIZAR DIRECCIONES: 77 Plazas Existentes en Supabase
-- ============================================================================
-- Este script NO elimina ni inserta plazas, solo actualiza direcciones
-- Las 77 plazas YA EXISTEN con IDs '1' a '77'
-- Las 3 plazas con IDs automáticos (PLZ-xxx) NO se tocan
-- ============================================================================

-- PASO 1: Agregar columna direccion (si no existe)
-- ============================================================================
ALTER TABLE plazas 
ADD COLUMN IF NOT EXISTS direccion TEXT;

-- PASO 2: Actualizar direcciones de las 77 plazas existentes
-- ============================================================================

UPDATE plazas SET direccion = 'Delfin Carvallo con Subteniente Valenzuela' WHERE id = '1';
UPDATE plazas SET direccion = 'Letras Turisticas Donihue en H-10 con H-286' WHERE id = '2';
UPDATE plazas SET direccion = 'Cabo Moena entre H-286 y H-276' WHERE id = '3';
UPDATE plazas SET direccion = 'Monumento Portal Lo Miranda en H-30 con H-270' WHERE id = '4';
UPDATE plazas SET direccion = 'A. Estacion con Estacion Carrera' WHERE id = '5';
UPDATE plazas SET direccion = 'Pedro Jose Vial/Humberto Vega F' WHERE id = '6';
UPDATE plazas SET direccion = 'Bombero Vicente Carter con Emilio Cuevas' WHERE id = '7';
UPDATE plazas SET direccion = 'Av. Villar del Rio entre psje. Madrid y psje. Provincia de Soria' WHERE id = '8';
UPDATE plazas SET direccion = 'Av. Villar del Rio entre Maule y psje. Provincia de Soria' WHERE id = '9';
UPDATE plazas SET direccion = 'Daniel Carrasco referencia n 498' WHERE id = '10';
UPDATE plazas SET direccion = 'Daniel Carrasco con Psje. Cataluna' WHERE id = '11';
UPDATE plazas SET direccion = 'Maule entre psje. Navarra y psje. Cataluna' WHERE id = '12';
UPDATE plazas SET direccion = 'Dr Sanhueza 551 referencia' WHERE id = '13';
UPDATE plazas SET direccion = 'Dr. Sanhueza con Av. Rancagua' WHERE id = '14';
UPDATE plazas SET direccion = 'Errazuriz con Estacion Carrera' WHERE id = '15';
UPDATE plazas SET direccion = 'Plaza 21 de Mayo Interior' WHERE id = '16';
UPDATE plazas SET direccion = 'Calle Los Copihues con Psje. Los Claveles' WHERE id = '17';
UPDATE plazas SET direccion = 'Calle Los Copihues entre Psje. Los Gladiolos y M. A. Roman (Norte)' WHERE id = '18';
UPDATE plazas SET direccion = 'Calle Los Copihues entre Psje. Los Gladiolos y M. A. Roman (Sur)' WHERE id = '19';
UPDATE plazas SET direccion = 'Calle M. A. Roman con Rio Claro' WHERE id = '20';
UPDATE plazas SET direccion = 'Manuel Antonio Roman con Pje. Rio Damas' WHERE id = '21';
UPDATE plazas SET direccion = 'Manuel Antonio Roman con Rio Damas' WHERE id = '22';
UPDATE plazas SET direccion = 'Calle Las Rosas Fte. 40' WHERE id = '23';
UPDATE plazas SET direccion = 'Calle Las Rosas 656' WHERE id = '24';
UPDATE plazas SET direccion = 'Calle Las Rosas con Psje. Camarico' WHERE id = '25';
UPDATE plazas SET direccion = 'Psje. Camarico con Psje. La Manta' WHERE id = '26';
UPDATE plazas SET direccion = 'Calle Rio Cisne con Emilio Cuevas' WHERE id = '27';
UPDATE plazas SET direccion = 'Psje. Donihue con Ruta H30 Paradero 27' WHERE id = '28';
UPDATE plazas SET direccion = 'Av. Cachapoal con Cerrillos' WHERE id = '29';
UPDATE plazas SET direccion = 'Ruta H-30 con Ruta H-38' WHERE id = '30';
UPDATE plazas SET direccion = 'Av. Rancagua y Pablo VI 47' WHERE id = '31';
UPDATE plazas SET direccion = 'Av. Rancagua entre H-29 y Juan Pablo II' WHERE id = '32';
UPDATE plazas SET direccion = 'H29 SN' WHERE id = '33';
UPDATE plazas SET direccion = 'Pasaje Sidney Fte. 33' WHERE id = '34';
UPDATE plazas SET direccion = 'Max Jara Fte. 0045' WHERE id = '35';
UPDATE plazas SET direccion = 'Psje. Maiten Fte. 260' WHERE id = '36';
UPDATE plazas SET direccion = 'Aliro Gonzales Fte. 171' WHERE id = '37';
UPDATE plazas SET direccion = 'Psje. Hugo Ortiz Fte 211' WHERE id = '38';
UPDATE plazas SET direccion = 'Aliro Gonzales con Victor Perez Perez' WHERE id = '39';
UPDATE plazas SET direccion = 'H-76 Plazuela Lo Miranda' WHERE id = '40';
UPDATE plazas SET direccion = 'Calle Central con Lago Rapel' WHERE id = '41';
UPDATE plazas SET direccion = 'Psje. Lago Llanquihue con Central' WHERE id = '42';
UPDATE plazas SET direccion = 'Psje. Manquehue con Central' WHERE id = '43';
UPDATE plazas SET direccion = 'Calle Central Fte. 023' WHERE id = '44';
UPDATE plazas SET direccion = 'Camino Vecinal SN' WHERE id = '45';
UPDATE plazas SET direccion = 'Bernardo O''Higgins entre Los Laureles y Los Condores' WHERE id = '46';
UPDATE plazas SET direccion = 'H-30 con Bernardo O''Higgins' WHERE id = '47';
UPDATE plazas SET direccion = 'Cam. Antiguo con Los Tiuques, Las Aguilas y Los Condores' WHERE id = '48';
UPDATE plazas SET direccion = 'El Roble entre El Canelo y Camino Antiguo' WHERE id = '49';
UPDATE plazas SET direccion = 'Entre Psje. Astorga y Psje. El Boldo' WHERE id = '50';
UPDATE plazas SET direccion = 'Psje. Las Golondrinas Fte. 303' WHERE id = '51';
UPDATE plazas SET direccion = 'Calle El Canelo Fte. 44' WHERE id = '52';
UPDATE plazas SET direccion = 'Las Carmelitas con Rinconada de Auco' WHERE id = '53';
UPDATE plazas SET direccion = 'Los Diamantes con Los Opalos' WHERE id = '54';
UPDATE plazas SET direccion = 'calle la union con el progreso' WHERE id = '55';
UPDATE plazas SET direccion = 'Av. Diego de Almagro con Psje. Isabel La Catolica' WHERE id = '56';
UPDATE plazas SET direccion = 'Av. Las Dalias con Psje. Las Camelias' WHERE id = '57';
UPDATE plazas SET direccion = 'Calle Concejal Eduardo Miranda con Psje. 4 y C.A.' WHERE id = '58';
UPDATE plazas SET direccion = 'Calle Concejal Eduardo Miranda con Psje. A. Carlos Valentin' WHERE id = '59';
UPDATE plazas SET direccion = 'Rosa Zuniga con Psje. Juanito y Delfina' WHERE id = '60';
UPDATE plazas SET direccion = 'Villa Tricahue' WHERE id = '61';
UPDATE plazas SET direccion = 'Villa Tricahue 2' WHERE id = '62';
UPDATE plazas SET direccion = 'H-280 con calle Cordillera y calle Los Urales' WHERE id = '63';
UPDATE plazas SET direccion = 'Calle Los Urales Fte.' WHERE id = '64';
UPDATE plazas SET direccion = 'Calle Cordillera con Calle Los Urales' WHERE id = '65';
UPDATE plazas SET direccion = 'Bdo. O''Higgins con A. Bello, 18 de Septiembre y 21 de Mayo' WHERE id = '66';
UPDATE plazas SET direccion = 'Bernardo O''Higgins entre Los Condores y Arturo Prat' WHERE id = '67';
UPDATE plazas SET direccion = 'H-30 con Villa Esperanza y Psje. Sagrado Corazon' WHERE id = '68';
UPDATE plazas SET direccion = 'Psje. Lo Miranda Oriente' WHERE id = '69';
UPDATE plazas SET direccion = 'Calle entre Psje. San Jorge y Psje. Sagrado Corazon' WHERE id = '70';
UPDATE plazas SET direccion = 'Psje. Villa Luna y Psje. La Florida' WHERE id = '71';
UPDATE plazas SET direccion = 'Entre Psje. Union Comunal y Psje. La Florida' WHERE id = '72';
UPDATE plazas SET direccion = 'Calle Los Robles con calle Ximena Meneses' WHERE id = '73';
UPDATE plazas SET direccion = 'Calle Victor Perez Perez con calle Los Robles' WHERE id = '74';
UPDATE plazas SET direccion = 'Psje. Los Nires con calle Los Robles' WHERE id = '75';
UPDATE plazas SET direccion = 'Calle Cerrillos costado acequia' WHERE id = '76';
UPDATE plazas SET direccion = 'Psje. Las Violetas entre Los Copihues y Psje. Los Claveles' WHERE id = '77';

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
-- Resultado: 77 plazas actualizadas con direcciones
-- Las 3 plazas con IDs automáticos (PLZ-xxx) permanecen intactas
-- Total en Supabase: 80 plazas (77 + 3)
-- ============================================================================
