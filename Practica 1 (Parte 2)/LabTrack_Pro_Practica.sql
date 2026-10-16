-- ============================================================
-- LabTrack Pro - Gestión de Equipos del Laboratorio de Cómputo
-- UPEM | Bases de Datos Relacionales | Grupo 7°A Vespertino
-- Alumno: Rodrigo Sanchez Elisea
-- Profesor: Ing. Roberto Carlos Hurtado Torres
-- Compatible con MySQL 8.0+ / MySQL Workbench
-- ============================================================

-- NOTA: DROP DATABASE está comentado para evitar borrar datos por accidente.
-- Si deseas reiniciar la práctica, descomenta la siguiente línea:
-- DROP DATABASE IF EXISTS LabTrackDB;

CREATE DATABASE IF NOT EXISTS LabTrackDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE LabTrackDB;

-- ------------------------------------------------------------
-- Tabla: ALUMNOS
-- Registra a los alumnos autorizados para solicitar préstamos.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Alumnos (
    id_alumno INT AUTO_INCREMENT PRIMARY KEY,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    carrera VARCHAR(100) NOT NULL,
    correo VARCHAR(120) UNIQUE,
    fecha_registro DATE NOT NULL DEFAULT (CURRENT_DATE),
    activo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabla: EQUIPO_LAB
-- Inventario de PCs, monitores, proyectores y equipos de red.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Equipo_Lab (
    id_equipo INT AUTO_INCREMENT PRIMARY KEY,
    num_inventario VARCHAR(30) NOT NULL UNIQUE,
    tipo ENUM('PC','Monitor','Proyector','Switch','Laptop','Otro') NOT NULL,
    marca VARCHAR(60) NOT NULL,
    modelo VARCHAR(80) NOT NULL,
    estado ENUM('Disponible','Prestado','En mantenimiento','Baja')
        NOT NULL DEFAULT 'Disponible',
    ubicacion VARCHAR(100) NOT NULL DEFAULT 'Laboratorio de cómputo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabla: PRESTAMOS
-- fecha_devolucion_real queda NULL mientras el equipo siga prestado.
-- Se conservan los préstamos como historial: no se permite borrar
-- alumnos o equipos que tengan movimientos relacionados.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Prestamos (
    id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
    fecha_prestamo DATE NOT NULL DEFAULT (CURRENT_DATE),
    fecha_limite DATE NOT NULL,
    fecha_devolucion_real DATE NULL,
    observaciones VARCHAR(255),
    id_equipo INT NOT NULL,
    id_alumno INT NOT NULL,
    CONSTRAINT fk_prestamo_equipo
        FOREIGN KEY (id_equipo) REFERENCES Equipo_Lab(id_equipo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prestamo_alumno
        FOREIGN KEY (id_alumno) REFERENCES Alumnos(id_alumno)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_fechas_prestamo
        CHECK (fecha_limite >= fecha_prestamo),
    CONSTRAINT chk_fecha_devolucion
        CHECK (fecha_devolucion_real IS NULL
               OR fecha_devolucion_real >= fecha_prestamo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Tabla: MANTENIMIENTO
-- Guarda el historial de mantenimiento de cada equipo.
-- RESTRICT protege el historial ante borrados accidentales.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Mantenimiento (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    costo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    tipo_mantenimiento ENUM('Preventivo','Correctivo') NOT NULL DEFAULT 'Preventivo',
    id_equipo INT NOT NULL,
    CONSTRAINT fk_mantenimiento_equipo
        FOREIGN KEY (id_equipo) REFERENCES Equipo_Lab(id_equipo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_costo_mantenimiento CHECK (costo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DATOS DE PRUEBA: 4 o más registros por tabla principal
-- ============================================================

INSERT INTO Alumnos (matricula, nombre, carrera, correo) VALUES
('UPEM2024001', 'Daniel Hernández', 'Ingeniería en Sistemas Computacionales', 'daniel.hernandez@upem.edu.mx'),
('UPEM2024002', 'Fernanda Morales', 'Ingeniería en Sistemas Computacionales', 'fernanda.morales@upem.edu.mx'),
('UPEM2023003', 'Luis Ramírez', 'Ingeniería Industrial', 'luis.ramirez@upem.edu.mx'),
('UPEM2022004', 'Mariana Cruz', 'Administración', 'mariana.cruz@upem.edu.mx');

INSERT INTO Equipo_Lab (num_inventario, tipo, marca, modelo, estado, ubicacion) VALUES
('LAB-PC-001', 'PC', 'Dell', 'OptiPlex 7090', 'Prestado', 'Laboratorio A'),
('LAB-MON-001', 'Monitor', 'HP', 'P24h G5', 'Disponible', 'Laboratorio A'),
('LAB-PRO-001', 'Proyector', 'Epson', 'PowerLite X49', 'Prestado', 'Aula multimedia'),
('LAB-SW-001', 'Switch', 'Cisco', 'CBS250-24T', 'En mantenimiento', 'Gabinete de red'),
('LAB-PC-002', 'PC', 'Lenovo', 'ThinkCentre M70s', 'Disponible', 'Laboratorio B'),
('LAB-MON-002', 'Monitor', 'Samsung', 'S24R350', 'Disponible', 'Laboratorio B');

-- Los préstamos con fecha_devolucion_real NULL son los préstamos actuales.
INSERT INTO Prestamos
(fecha_prestamo, fecha_limite, fecha_devolucion_real, observaciones, id_equipo, id_alumno) VALUES
('2026-10-01', '2026-10-02', NULL, 'Práctica de programación', 1, 1),
('2026-10-03', '2026-10-03', '2026-10-03', 'Uso en exposición', 3, 2),
('2026-09-10', '2026-09-12', '2026-09-12', 'Práctica de redes', 5, 1),
('2026-09-20', '2026-09-21', '2026-09-21', 'Actividad de laboratorio', 2, 1),
('2026-10-10', '2026-10-11', NULL, 'Presentación de proyecto', 3, 3),
('2026-08-15', '2026-08-16', '2026-08-16', 'Préstamo de prueba ya cerrado', 6, 4);

INSERT INTO Mantenimiento
(fecha, descripcion, costo, tipo_mantenimiento, id_equipo) VALUES
('2026-08-02', 'Limpieza interna y revisión de ventiladores', 350.00, 'Preventivo', 1),
('2026-08-12', 'Cambio de lámpara del proyector', 1850.00, 'Correctivo', 3),
('2026-09-01', 'Actualización de firmware del switch', 600.00, 'Preventivo', 4),
('2026-09-15', 'Reemplazo de fuente de poder', 1250.00, 'Correctivo', 5),
('2026-09-25', 'Diagnóstico y ajuste de monitor', 150.00, 'Correctivo', 2);

-- ============================================================
-- SECCIÓN D: OPERACIONES DML
-- Ejecutar cada sentencia una vez. Los UPDATE son demostrativos.
-- ============================================================

-- UPDATE 1: modifica un solo registro usando la PK.
UPDATE Alumnos
SET correo = 'daniel.hdez@upem.edu.mx'
WHERE id_alumno = 1;

-- UPDATE 2: modifica varios registros que cumplen el filtro.
UPDATE Equipo_Lab
SET ubicacion = 'Laboratorio de cómputo - Zona de monitores'
WHERE tipo = 'Monitor';

-- DELETE seguro: elimina únicamente un préstamo de prueba ya devuelto.
-- No se elimina el equipo ni el alumno; el historial de mantenimiento queda intacto.
DELETE FROM Prestamos
WHERE id_prestamo = 6
  AND fecha_devolucion_real IS NOT NULL
  AND observaciones = 'Préstamo de prueba ya cerrado';

-- SELECT simple con WHERE.
SELECT id_equipo, num_inventario, tipo, marca, modelo, estado
FROM Equipo_Lab
WHERE estado = 'Disponible';

-- SELECT simple con ORDER BY.
SELECT matricula, nombre, carrera
FROM Alumnos
ORDER BY nombre ASC;

-- ============================================================
-- SECCIÓN E: RETOS DE CONSULTAS DML
-- ============================================================

-- Reto 1: equipos prestados actualmente, con nombre y matrícula del alumno.
SELECT e.num_inventario, e.tipo, e.marca, e.modelo,
       a.nombre AS alumno, a.matricula, p.fecha_prestamo, p.fecha_limite
FROM Prestamos p
INNER JOIN Equipo_Lab e ON p.id_equipo = e.id_equipo
INNER JOIN Alumnos a ON p.id_alumno = a.id_alumno
WHERE p.fecha_devolucion_real IS NULL;

-- Reto 2: equipos que nunca han sido prestados.
SELECT e.id_equipo, e.num_inventario, e.tipo, e.marca, e.modelo
FROM Equipo_Lab e
LEFT JOIN Prestamos p ON e.id_equipo = p.id_equipo
WHERE p.id_prestamo IS NULL;

-- Reto 3: cantidad de préstamos realizados por cada alumno, incluso cero.
SELECT a.id_alumno, a.nombre, a.matricula,
       COUNT(p.id_prestamo) AS total_prestamos
FROM Alumnos a
LEFT JOIN Prestamos p ON a.id_alumno = p.id_alumno
GROUP BY a.id_alumno, a.nombre, a.matricula
ORDER BY total_prestamos DESC, a.nombre ASC;

-- Reto 4: costo total de mantenimientos por tipo de equipo.
SELECT e.tipo, SUM(m.costo) AS costo_total_mantenimiento
FROM Equipo_Lab e
INNER JOIN Mantenimiento m ON e.id_equipo = m.id_equipo
GROUP BY e.tipo
ORDER BY costo_total_mantenimiento DESC;

-- Reto 5: alumnos con más de dos préstamos.
SELECT a.nombre, a.matricula, COUNT(p.id_prestamo) AS total_prestamos
FROM Alumnos a
INNER JOIN Prestamos p ON a.id_alumno = p.id_alumno
GROUP BY a.id_alumno, a.nombre, a.matricula
HAVING COUNT(p.id_prestamo) > 2;

-- Reto 6: equipo que tiene el mantenimiento más costoso.
SELECT e.num_inventario, e.tipo, e.marca, e.modelo,
       m.descripcion, m.costo, m.fecha
FROM Mantenimiento m
INNER JOIN Equipo_Lab e ON m.id_equipo = e.id_equipo
ORDER BY m.costo DESC
LIMIT 1;

-- Consultas opcionales para verificar tablas y relaciones.
SELECT * FROM Alumnos;
SELECT * FROM Equipo_Lab;
SELECT * FROM Prestamos;
SELECT * FROM Mantenimiento;
