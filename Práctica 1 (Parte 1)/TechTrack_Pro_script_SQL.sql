CREATE DATABASE IF NOT EXISTS TechTrackDB
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE TechTrackDB;

-- Usuarios de la empresa
CREATE TABLE Usuarios (
 id_usuario INT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 departamento VARCHAR(50),
 email VARCHAR(100) UNIQUE,
 fecha_alta DATE DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

-- Inventario de activos
CREATE TABLE Equipos (
 id_equipo INT AUTO_INCREMENT PRIMARY KEY,
 num_serie VARCHAR(50) NOT NULL UNIQUE,
 modelo VARCHAR(80) NOT NULL,
 tipo ENUM('Laptop','Desktop','Servidor','Periferico','Otro') NOT NULL DEFAULT 'Laptop',
 estado ENUM('Disponible','Asignado','En Mantenimiento','Baja') DEFAULT 'Disponible',
 id_usuario INT NULL,
 CONSTRAINT fk_usuario_equipo FOREIGN KEY (id_usuario)
 REFERENCES Usuarios(id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Historial de mantenimiento
CREATE TABLE Mantenimientos (
 id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
 fecha DATE NOT NULL,
 descripcion TEXT,
 costo DECIMAL(10,2) DEFAULT 0.00,
 tipo_mant ENUM('Preventivo','Correctivo') DEFAULT 'Correctivo',
 id_equipo INT NOT NULL,
 CONSTRAINT fk_equipo_manto FOREIGN KEY (id_equipo)
 REFERENCES Equipos(id_equipo) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

INSERT INTO Usuarios (nombre, departamento, email) VALUES
('Ana López','Sistemas','ana.lopez@empresa.com'),
('Carlos Ruiz','Contabilidad','carlos.ruiz@empresa.com'),
('María Torres','Recursos Humanos','maria.torres@empresa.com');

INSERT INTO Equipos (num_serie, modelo, tipo, estado, id_usuario) VALUES
('SN-998877','Dell Latitude 5420','Laptop','Asignado',1),
('SN-112233','HP ProDesk 400','Desktop','Asignado',2),
('SN-445566','Dell PowerEdge R740','Servidor','Disponible',NULL),
('SN-778899','Lenovo ThinkPad X1','Laptop','Asignado',1);

INSERT INTO Mantenimientos (fecha, descripcion, costo, tipo_mant, id_equipo) VALUES
('2025-03-15','Cambio de disco SSD',85.00,'Correctivo',1),
('2025-06-01','Limpieza preventiva y actualización BIOS',0.00,'Preventivo',1),
('2025-08-20','Reemplazo de fuente de poder',120.50,'Correctivo',3);

INSERT INTO Equipos (num_serie, modelo, tipo, estado, id_usuario)
VALUES ('SN-554433','Apple MacBook Pro 14','Laptop','Asignado',3);
UPDATE Usuarios SET departamento='Sistemas' WHERE id_usuario=2;
DELETE FROM Mantenimientos WHERE id_mantenimiento=1;
SELECT * FROM Equipos;
SELECT num_serie, modelo, estado FROM Equipos WHERE tipo='Laptop';
SELECT nombre, departamento, email FROM Usuarios ORDER BY departamento ASC, nombre ASC;
SELECT e.num_serie, e.modelo, e.tipo, u.nombre AS asignado_a
FROM Equipos e INNER JOIN Usuarios u ON e.id_usuario=u.id_usuario;
SELECT m.fecha, e.modelo, m.descripcion, m.costo, m.tipo_mant
FROM Mantenimientos m JOIN Equipos e ON m.id_equipo=e.id_equipo
WHERE m.costo>100;
SELECT u.departamento, COUNT(e.id_equipo) AS total_equipos
FROM Usuarios u LEFT JOIN Equipos e ON u.id_usuario=e.id_usuario
GROUP BY u.departamento;
SELECT e.num_serie, e.modelo, e.tipo
FROM Equipos e LEFT JOIN Mantenimientos m ON e.id_equipo=m.id_equipo
WHERE m.id_mantenimiento IS NULL;