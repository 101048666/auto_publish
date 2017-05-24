-- MySQL dump 10.13  Distrib 5.6.21, for Linux (x86_64)
--
-- Host: localhost    Database: auto_publish
-- ------------------------------------------------------
-- Server version	5.6.21-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `auto_publish`
--

/*!40000 DROP DATABASE IF EXISTS `auto_publish`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `auto_publish` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `auto_publish`;

--
-- Table structure for table `app_logs`
--

DROP TABLE IF EXISTS `app_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `app_logs` (
  `id` int(11) NOT NULL,
  `phy_m_ip` varchar(45) DEFAULT NULL,
  `vm_m_name` varchar(45) DEFAULT NULL,
  `vm_ctl_port` varchar(45) DEFAULT NULL,
  `vm_app_port` varchar(45) DEFAULT NULL,
  `ctl_time` int(11) DEFAULT NULL,
  `ctl_cmd` varchar(45) DEFAULT NULL,
  `app_version` varchar(45) DEFAULT NULL,
  `app_type` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='记录程序发布的日志，物理机ip，虚拟机名称，虚拟机管理端口，虚拟机服务端口，管理动作时间，管理命令，程序版本，程序类型等。';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_logs`
--

LOCK TABLES `app_logs` WRITE;
/*!40000 ALTER TABLE `app_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_project`
--

DROP TABLE IF EXISTS `app_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `app_project` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_name` varchar(45) DEFAULT NULL COMMENT '发布的项目名称',
  `publish_dir` varchar(1000) DEFAULT NULL COMMENT '应用的发布路径',
  `start_cmd` varchar(45) DEFAULT NULL COMMENT '启动命令',
  `stop_cmd` varchar(45) DEFAULT NULL COMMENT '停止命令',
  `restart_cmd` varchar(45) DEFAULT NULL COMMENT '重启命令',
  `online_time` varchar(45) DEFAULT NULL COMMENT '上线时间',
  `app_version` varchar(45) DEFAULT NULL COMMENT '应用程序当前的版本',
  `app_type` int(11) NOT NULL COMMENT '应用程序的发布软件类型',
  `virtual_machine_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8 COMMENT='应用程序属性表，包含应用名称，发布路径，启动命令，停止命令，重启命令，上线时间，应用程序版本，应用类型，虚拟机的id。';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_project`
--

LOCK TABLES `app_project` WRITE;
/*!40000 ALTER TABLE `app_project` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_project` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_type`
--

DROP TABLE IF EXISTS `app_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `app_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `is_use` int(11) DEFAULT NULL,
  `create_time` int(11) DEFAULT NULL,
  `app_typecol` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='应用类型，包括名称，是否启用，创建时间，类型主要是，httpd，tomcat，java，weblogic等等。';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_type`
--

LOCK TABLES `app_type` WRITE;
/*!40000 ALTER TABLE `app_type` DISABLE KEYS */;
INSERT INTO `app_type` VALUES (1,'tomcat',1,1495507502,NULL),(2,'httpd',1,1495507565,NULL),(3,'pureftp',1,1495507583,NULL),(4,'sshd',1,1495528639,NULL);
/*!40000 ALTER TABLE `app_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phy_machine`
--

DROP TABLE IF EXISTS `phy_machine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phy_machine` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `ip` varchar(45) NOT NULL COMMENT '物理机ip地址',
  `name` varchar(45) NOT NULL COMMENT '物理机名称',
  `machine_user` varchar(45) NOT NULL DEFAULT 'root' COMMENT '物理机管理用户',
  `machine_pass` varchar(45) NOT NULL DEFAULT '0' COMMENT '物理机管理用户的密码',
  `ssh_port` int(11) NOT NULL DEFAULT '22' COMMENT '物理机管理端口',
  `is_use` int(11) NOT NULL DEFAULT '1' COMMENT '是否启用（是否加入生产序列）',
  `vm_type` int(11) DEFAULT '0' COMMENT '虚拟化类型0 没有虚拟化，1 docker 其他暂不支持，等待后续版本。',
  `online_time` bigint(20) NOT NULL COMMENT '服务器上线时间（加入生产序列的时间）',
  `project_lib_dir` varchar(1000) NOT NULL COMMENT '本地转存的程序库地址',
  `rsync_port` int(11) DEFAULT NULL COMMENT 'rsync用于接收远程程序库同步的端口',
  `remote_lib_dir` varchar(1000) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ip_UNIQUE` (`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COMMENT='物理机的基本属性，包括ip地址，物理机名称，管理用户名，密码，是否启用，虚拟化方式，上线时间，远程程序库的地址，本地程序库地址。';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phy_machine`
--

LOCK TABLES `phy_machine` WRITE;
/*!40000 ALTER TABLE `phy_machine` DISABLE KEYS */;
/*!40000 ALTER TABLE `phy_machine` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `virtual_machine`
--

DROP TABLE IF EXISTS `virtual_machine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_machine` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(45) NOT NULL COMMENT '虚拟机名称',
  `app_port` int(11) DEFAULT NULL COMMENT '应用监听的端口',
  `ip` varchar(45) DEFAULT NULL COMMENT '虚拟机的ip地址（桥接的话，一般使用NAT，本列为空）',
  `username` varchar(45) DEFAULT NULL COMMENT '虚拟机管理用户名',
  `password` varchar(45) DEFAULT NULL COMMENT '虚拟机管理密码',
  `ctl_port` int(11) DEFAULT NULL COMMENT '虚拟机管理端口',
  `phy_machine_id` int(11) NOT NULL COMMENT '宿主物理机的id，关联物理机主键',
  `online_time` bigint(20) NOT NULL COMMENT '上线时间',
  `publish_dir` varchar(1000) NOT NULL COMMENT '虚拟机的app发布路径',
  `vir_machine_code` varchar(45) DEFAULT NULL,
  `structure_parameter` varchar(20000) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8 COMMENT='虚拟机的属性，包括虚拟机名称，应用端口，IP地址，管理用户名，管理密码，控制端口，所属物理机Id，上线时间，应用程序库地址，物理机';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `virtual_machine`
--

LOCK TABLES `virtual_machine` WRITE;
/*!40000 ALTER TABLE `virtual_machine` DISABLE KEYS */;
/*!40000 ALTER TABLE `virtual_machine` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `virtual_type`
--

DROP TABLE IF EXISTS `virtual_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_type` (
  `id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL COMMENT '虚拟类型的名称',
  `is_use` int(11) DEFAULT NULL COMMENT '此类型是否已启用',
  `create_time` int(11) DEFAULT NULL COMMENT '类型创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='主机的虚拟类型，包括名称，是否启用，创建时间，类型主要有目前主流的各种虚拟化方式，比如docker，kvm等等。';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `virtual_type`
--

LOCK TABLES `virtual_type` WRITE;
/*!40000 ALTER TABLE `virtual_type` DISABLE KEYS */;
INSERT INTO `virtual_type` VALUES (1,'docker',1,1493779244),(2,'kvm',0,1493779274),(3,'xen',0,1493779366),(4,'openvz',0,1493779388),(5,'VirtualBox',0,1493779404);
/*!40000 ALTER TABLE `virtual_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'auto_publish'
--

--
-- Dumping routines for database 'auto_publish'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-05-24 12:52:53
