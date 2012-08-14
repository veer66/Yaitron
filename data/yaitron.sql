-- MySQL dump 10.13  Distrib 5.1.63, for apple-darwin11.4.0 (i386)
--
-- Host: localhost    Database: yaitron
-- ------------------------------------------------------
-- Server version	5.1.62

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES UTF8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `yaitron_en_li`
--

DROP TABLE IF EXISTS `yaitron_en_li`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yaitron_en_li` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `LI` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pos` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `LI` (`LI`),
  KEY `yaitron_en_li_li` (`LI`)
) ENGINE=InnoDB AUTO_INCREMENT=168653 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `yaitron_en_th`
--

DROP TABLE IF EXISTS `yaitron_en_th`;
/*!50001 DROP VIEW IF EXISTS `yaitron_en_th`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `yaitron_en_th` (
  `id` int(11),
  `li` varchar(255),
  `pos` varchar(32),
  `gloss` varchar(255),
  `occurrence_count` int(11)
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `yaitron_th_gloss`
--

DROP TABLE IF EXISTS `yaitron_th_gloss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yaitron_th_gloss` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `li_ID` int(11) DEFAULT NULL,
  `gloss` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `occurrence_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `li_ID` (`li_ID`),
  KEY `yaitron_th_gloss_occur_count` (`occurrence_count`),
  CONSTRAINT `yaitron_th_gloss_ibfk_1` FOREIGN KEY (`li_ID`) REFERENCES `yaitron_en_li` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=221304 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Final view structure for view `yaitron_en_th`
--

/*!50001 DROP TABLE IF EXISTS `yaitron_en_th`*/;
/*!50001 DROP VIEW IF EXISTS `yaitron_en_th`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `yaitron_en_th` AS select `yaitron_en_li`.`id` AS `id`,`yaitron_en_li`.`LI` AS `li`,`yaitron_en_li`.`pos` AS `pos`,`yaitron_th_gloss`.`gloss` AS `gloss`,`yaitron_th_gloss`.`occurrence_count` AS `occurrence_count` from (`yaitron_en_li` join `yaitron_th_gloss` on((`yaitron_en_li`.`id` = `yaitron_th_gloss`.`li_ID`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-08-14 13:48:35
