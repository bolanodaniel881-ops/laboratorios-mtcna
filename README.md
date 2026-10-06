LABORATORIO 2


   Segmentación Corporativa con VLANs y DHCP en RouterOS v7

   Descripción

Este laboratorio práctico simula la infraestructura de red de una mediana empresa utilizando **VLAN Filtering** sobre un único Bridge en MikroTik RouterOS v7 [ROS]. El objetivo es segmentar el tráfico de tres departamentos diferenciados para aislar la red de Invitados de los datos sensibles de Administración y Técnicos.

  Topología y Conexiones en GNS3

Internet/WAN (ether1): Conectado a `Cloud1` (IP asignada dinámicamente por el router doméstico).

Enlace Troncal / Trunk (ether2):** Conexión directa del router al `Switch1` transportando las VLANs etiquetadas.

Segmentos de Red (VPCS):
      
PC1 (Administración):** Conectado al puerto 2 del Switch ➔ **VLAN 10
PC2 (Técnicos):** Conectado al puerto 3 del Switch ➔ **VLAN 20
PC3 (Invitados):** Conectado al puerto 4 del Switch ➔ **VLAN 30

        Plan de Direccionamiento IP

| Departamento | ID de VLAN | Subred IP | Puerta de Enlace (Gateway) | Rango de Pool DHCP |

Administración | 10 | `10.10.10.0/24` | `10.10.10.1` | `10.10.10.10 - 10.10.10.254` |
Técnicos | 20 | `10.10.20.0/24` | `10.10.20.1` | `10.10.20.10 - 10.10.20.254` |
Invitados | 30 | `10.10.30.0/24` | `10.10.30.1` | `10.10.30.10 - 10.10.30.254` |

---

  Tareas de Troubleshooting y Aprendizaje (Resolución de Problemas)
      
Fallo de asignación DHCP en VLANs (VPCS):** Al lanzar el comando `ip dhcp` en los ordenadores virtuales, el sistema enviaba los paquetes de descubrimiento pero el router no respondía (`Can't find dhcp server`).
      
Causa:** El switch básico de GNS3 no gestiona etiquetas de VLAN de forma nativa, por lo que los paquetes llegaban huérfanos al MikroTik.
    • 
Solución:** Se configuró el puerto físico `ether2` dentro del menú `Bridge > Ports` con un PVID=10. Esto forzó al router a inyectar la etiqueta de la VLAN 10 a todo el tráfico saliente de ese puerto hacia el switch. Finalmente, se activó la casilla `VLAN Filtering` en las propiedades del bridge para habilitar el procesado y etiquetado estricto de las VLANs de RouterOS v7 [ROS]. El PC Administración obtuvo la IP **`10.10.10.254`** con éxito.

---

  Script de Configuración de Capa 2 y DHCP (`vlans_dhcp_config.rsc`)

Este script contiene las reglas de Bridge, subinterfaces VLAN y servidores DHCP dinámicos configurados de forma visual a través de WinBox [ROS]:


# 1. Creación del Bridge y asignación del puerto de acceso con PVID
      
/interface bridge add name=bridge-VLAN vlan-filtering=no
/interface bridge port add bridge=bridge-VLAN interface=ether2 pvid=10

# 2. Creación de las subinterfaces lógicas de VLAN
      
/interface vlan add name=vlan10-admin vlan-id=10 interface=bridge-VLAN
/interface vlan add name=vlan20-tecnicos vlan-id=20 interface=bridge-VLAN
/interface vlan add name=vlan30-invitados vlan-id=30 interface=bridge-VLAN

# 3. Direccionamiento IP de las Puertas de Enlace (Gateways)
      
/ip address add address=10.10.10.1/24 interface=vlan10-admin
/ip address add address=10.10.20.1/24 interface=vlan20-tecnicos
/ip address add address=10.10.30.1/24 interface=vlan30-invitados

# 4. Creación de Pools y Servidores DHCP
      
/ip pool add name=pool-admin ranges=10.10.10.10-10.10.10.254
/ip pool add name=pool-tecnicos ranges=10.10.20.10-10.10.20.254
/ip pool add name=pool-invitados ranges=10.10.30.10-10.10.30.254

/ip dhcp-server add name=dhcp-admin interface=vlan10-admin address-pool=pool-admin disabled=no
/ip dhcp-server add name=dhcp-tecnicos interface=vlan20-tecnicos address-pool=pool-tecnicos disabled=no
/ip dhcp-server add name=dhcp-invitados interface=vlan30-invitados address-pool=pool-invitados disabled=no

/ip dhcp-server network add address=10.10.10.0/24 gateway=10.10.10.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.10.20.0/24 gateway=10.10.20.1 dns-server=8.8.8.8
/ip dhcp-server network add address=10.10.30.0/24 gateway=10.10.30.1 dns-server=8.8.8.8

# 5. Activación global del filtrado de seguridad del Bridge
      
/interface bridge set bridge-VLAN vlan-filtering=yes
```

 
