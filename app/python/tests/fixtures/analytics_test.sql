-- MySQL Script generated by MySQL Workbench
-- Thu May 28 14:35:02 2015
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema analytics_test
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema analytics_test
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `analytics_test` DEFAULT CHARACTER SET utf8 ;
USE `analytics_test` ;

-- -----------------------------------------------------
-- Table `analytics_test`.`poller_sessions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`poller_sessions` (
  `sid` BINARY(16) NOT NULL COMMENT 'The unique identifier of the poll session',
  `account_id` INT(11) NOT NULL COMMENT 'clients.id reference',
  `env_id` INT(11) NOT NULL COMMENT 'client_environments.id reference',
  `dtime` DATETIME NOT NULL COMMENT 'The timestamp retrieved from the response',
  `platform` VARCHAR(20) NOT NULL COMMENT 'The ID of the Platform',
  `url` VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'Keystone endpoint',
  `cloud_location` VARCHAR(255) NULL COMMENT 'Cloud location ID',
  `cloud_account` VARCHAR(32) NULL,
  PRIMARY KEY (`sid`),
  INDEX `idx_dtime` (`dtime` ASC),
  INDEX `idx_platform` (`platform` ASC, `url` ASC, `cloud_location` ASC),
  INDEX `idx_cloud_id` (`account_id` ASC),
  INDEX `idx_account` (`account_id` ASC, `env_id` ASC))
ENGINE = InnoDB
COMMENT = 'Poller sessions';


-- -----------------------------------------------------
-- Table `analytics_test`.`managed`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`managed` (
  `sid` BINARY(16) NOT NULL COMMENT 'The identifier of the poll session',
  `server_id` BINARY(16) NOT NULL COMMENT 'scalr.servers.server_id ref',
  `instance_type` VARCHAR(45) NOT NULL COMMENT 'The type of the instance',
  `os` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0 - linux, 1 - windows',
  PRIMARY KEY (`sid`, `server_id`),
  INDEX `idx_server_id` (`server_id` ASC),
  INDEX `idx_instance_type` (`instance_type` ASC),
  CONSTRAINT `fk_managed_poller_sessions`
    FOREIGN KEY (`sid`)
    REFERENCES `analytics_test`.`poller_sessions` (`sid`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT)
ENGINE = InnoDB
COMMENT = 'The presence of the managed servers on cloud';


-- -----------------------------------------------------
-- Table `analytics_test`.`price_history`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`price_history` (
  `price_id` BINARY(16) NOT NULL COMMENT 'The ID of the price',
  `platform` VARCHAR(20) NOT NULL COMMENT 'Platform name',
  `url` VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'Keystone endpoint',
  `cloud_location` VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'The cloud location',
  `account_id` INT(11) NOT NULL DEFAULT 0 COMMENT 'The ID of the account',
  `applied` DATE NOT NULL COMMENT 'The date after which new prices are applied',
  `deny_override` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'It is used only with account_id = 0',
  PRIMARY KEY (`price_id`),
  UNIQUE INDEX `idx_unique` (`platform` ASC, `url` ASC, `cloud_location` ASC, `applied` ASC, `account_id` ASC),
  INDEX `idx_applied` (`applied` ASC),
  INDEX `idx_account_id` (`account_id` ASC))
ENGINE = InnoDB
COMMENT = 'The price changes';


-- -----------------------------------------------------
-- Table `analytics_test`.`prices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`prices` (
  `price_id` BINARY(16) NOT NULL COMMENT 'The ID of the revision',
  `instance_type` VARCHAR(45) NOT NULL COMMENT 'The type of the instance',
  `os` TINYINT(1) NOT NULL COMMENT '0 - linux, 1 - windows',
  `name` VARCHAR(45) NOT NULL DEFAULT '' COMMENT 'The display name',
  `cost` DECIMAL(9,6) UNSIGNED NOT NULL DEFAULT 0.0 COMMENT 'The hourly cost of usage (USD)',
  PRIMARY KEY (`price_id`, `instance_type`, `os`),
  INDEX `idx_instance_type` (`instance_type` ASC, `os` ASC),
  INDEX `idx_name` USING BTREE (`name`(3) ASC),
  CONSTRAINT `fk_prices_price_revisions`
    FOREIGN KEY (`price_id`)
    REFERENCES `analytics_test`.`price_history` (`price_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'The Cloud prices for specific revision';


-- -----------------------------------------------------
-- Table `analytics_test`.`tags`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`tags` (
  `tag_id` INT(11) UNSIGNED NOT NULL COMMENT 'The unique identifier of the tag',
  `name` VARCHAR(127) NOT NULL COMMENT 'The display name of the tag',
  PRIMARY KEY (`tag_id`))
ENGINE = InnoDB
COMMENT = 'Tags';


-- -----------------------------------------------------
-- Table `analytics_test`.`account_tag_values`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`account_tag_values` (
  `account_id` INT(11) NOT NULL COMMENT 'The ID of the account',
  `tag_id` INT(11) UNSIGNED NOT NULL COMMENT 'The ID of the tag',
  `value_id` VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'The unique identifier of the value for the associated tag',
  `value_name` VARCHAR(255) NULL COMMENT 'Display name for the tag value may be omitted.',
  PRIMARY KEY (`account_id`, `tag_id`, `value_id`),
  INDEX `idx_tag` (`tag_id` ASC, `value_id` ASC),
  CONSTRAINT `fk_account_tag_values_tags`
    FOREIGN KEY (`tag_id`)
    REFERENCES `analytics_test`.`tags` (`tag_id`)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Account level tag values';


-- -----------------------------------------------------
-- Table `analytics_test`.`usage_types`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`usage_types` (
  `id` BINARY(4) NOT NULL,
  `cost_distr_type` TINYINT NOT NULL COMMENT 'Cost distribution type',
  `name` VARCHAR(255) NOT NULL COMMENT 'The type of the usage',
  `display_name` VARCHAR(255) NULL COMMENT 'Display name',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_key` (`cost_distr_type` ASC, `name` ASC))
ENGINE = InnoDB
COMMENT = 'Usage types';


-- -----------------------------------------------------
-- Table `analytics_test`.`usage_items`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`usage_items` (
  `id` BINARY(4) NOT NULL,
  `usage_type` BINARY(4) NOT NULL COMMENT 'usage_types.id ref',
  `name` VARCHAR(255) NOT NULL COMMENT 'Item name',
  `display_name` VARCHAR(255) NULL COMMENT 'Display name',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_key` (`usage_type` ASC, `name` ASC),
  INDEX `idx_usage_type` (`usage_type` ASC),
  CONSTRAINT `fk_2d27e26ab76a`
    FOREIGN KEY (`usage_type`)
    REFERENCES `analytics_test`.`usage_types` (`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT)
ENGINE = InnoDB
COMMENT = 'Usage items';


-- -----------------------------------------------------
-- Table `analytics_test`.`usage_h`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`usage_h` (
  `usage_id` BINARY(16) NOT NULL COMMENT 'The unique identifier for the usage record',
  `account_id` INT(11) NOT NULL COMMENT 'clients.id reference',
  `dtime` DATETIME NOT NULL COMMENT 'Time in Y-m-d H:00:00',
  `platform` VARCHAR(20) NOT NULL COMMENT 'The cloud type',
  `url` VARCHAR(255) NOT NULL DEFAULT '',
  `cloud_location` VARCHAR(255) NOT NULL COMMENT 'The cloud location',
  `usage_item` BINARY(4) NOT NULL COMMENT 'usage_items ref',
  `os` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0 - linux, 1 - windows',
  `cc_id` BINARY(16) NULL COMMENT 'ID of cost centre',
  `project_id` BINARY(16) NULL COMMENT 'ID of the project',
  `env_id` INT(11) NULL COMMENT 'client_environments.id reference',
  `farm_id` INT(11) NULL COMMENT 'farms.id reference',
  `farm_role_id` INT(11) NULL COMMENT 'farm_roles.id reference',
  `role_id` INT(11) NULL COMMENT 'scalr.roles.id ref',
  `num` DECIMAL(8,2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT 'Usage quantity',
  `cost` DECIMAL(18,9) NOT NULL DEFAULT 0.000000000 COMMENT 'Cost of usage',
  PRIMARY KEY (`usage_id`),
  INDEX `idx_find` (`account_id` ASC, `dtime` ASC),
  INDEX `idx_platform` (`platform` ASC, `url` ASC, `cloud_location` ASC),
  INDEX `idx_cc_id` (`cc_id` ASC),
  INDEX `idx_project_id` (`project_id` ASC),
  INDEX `idx_farm_id` (`farm_id` ASC),
  INDEX `idx_env_id` (`env_id` ASC),
  INDEX `idx_farm_role_id` (`farm_role_id` ASC),
  INDEX `idx_dtime` (`dtime` ASC),
  INDEX `idx_role` (`role_id` ASC),
  INDEX `idx_usage_item` (`usage_item` ASC),
  CONSTRAINT `fk_75b88915ce5d`
    FOREIGN KEY (`usage_item`)
    REFERENCES `analytics_test`.`usage_items` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
COMMENT = 'Hourly usage';


-- -----------------------------------------------------
-- Table `analytics_test`.`notmanaged`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`notmanaged` (
  `sid` BINARY(16) NOT NULL COMMENT 'The ID of the poller session',
  `instance_id` VARCHAR(36) NOT NULL COMMENT 'The ID of the instance which is not managed by Scalr',
  `instance_type` VARCHAR(45) NOT NULL COMMENT 'The type of the instance',
  `os` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`sid`, `instance_id`),
  INDEX `idx_instance_id` (`instance_id` ASC),
  INDEX `idx_instance_type` (`instance_type` ASC),
  CONSTRAINT `fk_notmanaged_poller_sessions`
    FOREIGN KEY (`sid`)
    REFERENCES `analytics_test`.`poller_sessions` (`sid`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT)
ENGINE = InnoDB
COMMENT = 'The presence of the not managed nodes';


-- -----------------------------------------------------
-- Table `analytics_test`.`usage_h_tags`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`usage_h_tags` (
  `usage_id` BINARY(16) NOT NULL,
  `tag_id` INT(11) UNSIGNED NOT NULL,
  `value_id` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`usage_id`, `tag_id`, `value_id`),
  INDEX `idx_tag` (`tag_id` ASC, `value_id` ASC),
  CONSTRAINT `fk_usage_h_tags_usage_h`
    FOREIGN KEY (`usage_id`)
    REFERENCES `analytics_test`.`usage_h` (`usage_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_usage_h_tags_account_tag_values`
    FOREIGN KEY (`tag_id` , `value_id`)
    REFERENCES `analytics_test`.`account_tag_values` (`tag_id` , `value_id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
COMMENT = 'Hourly usage tags';


-- -----------------------------------------------------
-- Table `analytics_test`.`nm_usage_h`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`nm_usage_h` (
  `usage_id` BINARY(16) NOT NULL COMMENT 'ID of the usage',
  `dtime` DATETIME NOT NULL COMMENT 'Time in Y-m-d H:00:00',
  `platform` VARCHAR(20) NOT NULL COMMENT 'The type of the cloud',
  `url` VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'Keystone endpoint',
  `cloud_location` VARCHAR(255) NOT NULL COMMENT 'Cloud location',
  `instance_type` VARCHAR(45) NOT NULL COMMENT 'The type of the instance',
  `os` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0 - linux, 1 - windows',
  `num` DECIMAL(8,2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT 'Usage quantity',
  `cost` DECIMAL(18,9) NOT NULL DEFAULT 0.000000000 COMMENT 'The cost of the usage',
  PRIMARY KEY (`usage_id`),
  INDEX `idx_platform` (`platform` ASC, `url` ASC, `cloud_location` ASC),
  INDEX `idx_dtime` (`dtime` ASC))
ENGINE = InnoDB
COMMENT = 'Not managed servers hourly usage';


-- -----------------------------------------------------
-- Table `analytics_test`.`nm_subjects_h`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`nm_subjects_h` (
  `subject_id` BINARY(16) NOT NULL COMMENT 'ID of the subject',
  `env_id` INT(11) NOT NULL COMMENT 'client_environments.id reference',
  `cc_id` BINARY(16) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0' COMMENT 'ID of cost centre',
  `account_id` INT(11) NOT NULL COMMENT 'clients.id reference',
  PRIMARY KEY (`subject_id`, `env_id`),
  INDEX `idx_cc_id` (`cc_id` ASC),
  INDEX `idx_account_id` (`account_id` ASC),
  UNIQUE INDEX `idx_unique` (`env_id` ASC, `cc_id` ASC))
ENGINE = InnoDB
COMMENT = 'Subjects to associate with usage';


-- -----------------------------------------------------
-- Table `analytics_test`.`nm_usage_subjects_h`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`nm_usage_subjects_h` (
  `usage_id` BINARY(16) NOT NULL COMMENT 'ID of the usage',
  `subject_id` BINARY(16) NOT NULL COMMENT 'ID of the subject',
  PRIMARY KEY (`usage_id`, `subject_id`),
  INDEX `idx_subject_id` (`subject_id` ASC),
  CONSTRAINT `fk_nmusagesubjectsh_nmusageh`
    FOREIGN KEY (`usage_id`)
    REFERENCES `analytics_test`.`nm_usage_h` (`usage_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_nmusagesubjectsh_nmsubjectsh`
    FOREIGN KEY (`subject_id`)
    REFERENCES `analytics_test`.`nm_subjects_h` (`subject_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Subjects - Usages';


-- -----------------------------------------------------
-- Table `analytics_test`.`usage_servers_h`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`usage_servers_h` (
  `usage_id` BINARY(16) NOT NULL,
  `server_id` BINARY(16) NOT NULL COMMENT 'scalr.servers.server_id ref',
  `instance_id` VARCHAR(36) NOT NULL COMMENT 'cloud server id',
  PRIMARY KEY (`usage_id`, `server_id`),
  INDEX `idx_server_id` (`server_id` ASC),
  INDEX `idx_instance_id` (`instance_id` ASC),
  CONSTRAINT `fk_26ff9423b1bc`
    FOREIGN KEY (`usage_id`)
    REFERENCES `analytics_test`.`usage_h` (`usage_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Servers associated with usage';


-- -----------------------------------------------------
-- Table `analytics_test`.`nm_usage_servers_h`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`nm_usage_servers_h` (
  `usage_id` BINARY(16) NOT NULL,
  `instance_id` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`usage_id`, `instance_id`),
  INDEX `idx_instance_id` (`instance_id` ASC),
  CONSTRAINT `fk_22300db65385`
    FOREIGN KEY (`usage_id`)
    REFERENCES `analytics_test`.`nm_usage_h` (`usage_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Instances associated with usage';


-- -----------------------------------------------------
-- Table `analytics_test`.`usage_d`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`usage_d` (
  `date` DATE NOT NULL COMMENT 'UTC Date',
  `platform` VARCHAR(20) NOT NULL COMMENT 'Cloud platform',
  `cc_id` BINARY(16) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0' COMMENT 'ID of the CC',
  `project_id` BINARY(16) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0' COMMENT 'ID of the project',
  `farm_id` INT(11) NOT NULL DEFAULT 0 COMMENT 'ID of the farm',
  `cost` DECIMAL(18,9) NOT NULL DEFAULT 0.000000000 COMMENT 'Daily usage',
  `env_id` INT(11) NOT NULL DEFAULT 0 COMMENT 'ID of the environment',
  PRIMARY KEY (`date`, `farm_id`, `platform`, `cc_id`, `project_id`),
  INDEX `idx_farm_id` (`farm_id` ASC),
  INDEX `idx_project_id` (`project_id` ASC),
  INDEX `idx_cc_id` (`cc_id` ASC),
  INDEX `idx_platform` (`platform` ASC),
  INDEX `idx_env_id` (`env_id` ASC))
ENGINE = InnoDB
COMMENT = 'Daily usage';


-- -----------------------------------------------------
-- Table `analytics_test`.`settings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`settings` (
  `id` VARCHAR(64) NOT NULL COMMENT 'setting ID',
  `value` TEXT NULL COMMENT 'The value',
  PRIMARY KEY (`id`))
ENGINE = InnoDB
COMMENT = 'system settings';


-- -----------------------------------------------------
-- Table `analytics_test`.`quarterly_budget`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`quarterly_budget` (
  `year` SMALLINT NOT NULL COMMENT 'The year [2014]',
  `subject_type` TINYINT NOT NULL COMMENT '1 - CC, 2 - Project',
  `subject_id` BINARY(16) NOT NULL COMMENT 'ID of the CC or Project',
  `quarter` TINYINT NOT NULL COMMENT 'Quarter [1-4]',
  `budget` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Budget dollar amount',
  `final` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Final spent',
  `spentondate` DATETIME NULL COMMENT 'Final spent on date',
  `cumulativespend` DECIMAL(18,9) NOT NULL DEFAULT 0.000000000 COMMENT 'Cumulative spend',
  PRIMARY KEY (`year`, `subject_type`, `subject_id`, `quarter`),
  INDEX `idx_year` (`year` ASC, `quarter` ASC),
  INDEX `idx_quarter` (`quarter` ASC),
  INDEX `idx_subject_type` (`subject_type` ASC, `subject_id` ASC),
  INDEX `idx_subject_id` (`subject_id` ASC))
ENGINE = InnoDB
COMMENT = 'Quarterly budget'
PACK_KEYS = Default;


-- -----------------------------------------------------
-- Table `analytics_test`.`nm_usage_d`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`nm_usage_d` (
  `date` DATE NOT NULL COMMENT 'UTC Date',
  `platform` VARCHAR(20) NOT NULL COMMENT 'Cloud platform',
  `cc_id` BINARY(16) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0' COMMENT 'ID of Cost centre',
  `env_id` INT(11) NOT NULL COMMENT 'ID of Environment',
  `cost` DECIMAL(18,9) NOT NULL DEFAULT 0.000000000 COMMENT 'Daily usage',
  PRIMARY KEY (`date`, `platform`, `cc_id`, `env_id`),
  INDEX `idx_cc_id` (`cc_id` ASC),
  INDEX `idx_env_id` (`env_id` ASC),
  INDEX `idx_platform` (`platform` ASC))
ENGINE = InnoDB
COMMENT = 'Not managed daily usage';


-- -----------------------------------------------------
-- Table `analytics_test`.`notifications`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`notifications` (
  `uuid` BINARY(16) NOT NULL COMMENT 'unique identifier',
  `subject_type` TINYINT NOT NULL COMMENT '1- CC, 2 - Project',
  `subject_id` BINARY(16) NULL,
  `notification_type` TINYINT NOT NULL COMMENT 'Type of the notification',
  `threshold` DECIMAL(12,2) NOT NULL,
  `recipient_type` TINYINT NOT NULL DEFAULT 1 COMMENT '1 - Leads 2 - Emails',
  `emails` TEXT NULL COMMENT 'Comma separated recipients',
  `status` TINYINT NOT NULL,
  PRIMARY KEY (`uuid`),
  INDEX `idx_notification_type` (`notification_type` ASC),
  INDEX `idx_subject_type` (`subject_type` ASC),
  INDEX `idx_recipient_type` (`recipient_type` ASC))
ENGINE = InnoDB
COMMENT = 'Notifications';


-- -----------------------------------------------------
-- Table `analytics_test`.`timeline_events`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`timeline_events` (
  `uuid` BINARY(16) NOT NULL COMMENT 'UUID',
  `event_type` TINYINT UNSIGNED NOT NULL COMMENT 'The type of the event',
  `dtime` DATETIME NOT NULL COMMENT 'The time of the event',
  `user_id` INT(11) NULL COMMENT 'User who triggered this event',
  `account_id` INT(11) NULL,
  `env_id` INT(11) NULL,
  `description` TEXT NOT NULL COMMENT 'Description',
  PRIMARY KEY (`uuid`),
  INDEX `idx_dtime` (`dtime` ASC),
  INDEX `idx_event_type` (`event_type` ASC),
  INDEX `idx_user_id` (`user_id` ASC),
  INDEX `idx_account_id` (`account_id` ASC),
  INDEX `idx_env_id` (`env_id` ASC))
ENGINE = InnoDB
COMMENT = 'Timeline events';


-- -----------------------------------------------------
-- Table `analytics_test`.`reports`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`reports` (
  `uuid` BINARY(16) NOT NULL COMMENT 'unique identifier',
  `subject_type` TINYINT NULL COMMENT '1- CC, 2 - Project, NULL - Summary',
  `subject_id` BINARY(16) NULL,
  `period` TINYINT NOT NULL COMMENT 'Period',
  `emails` TEXT NOT NULL COMMENT 'Comma separated recipients',
  `status` TINYINT NOT NULL,
  PRIMARY KEY (`uuid`),
  INDEX `idx_subject_type` (`subject_type` ASC),
  INDEX `idx_period` (`period` ASC))
ENGINE = InnoDB
COMMENT = 'Reports';


-- -----------------------------------------------------
-- Table `analytics_test`.`timeline_event_ccs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`timeline_event_ccs` (
  `event_id` BINARY(16) NOT NULL COMMENT 'timeline_events.uuid reference',
  `cc_id` BINARY(16) NOT NULL COMMENT 'scalr.ccs.cc_id reference',
  PRIMARY KEY (`event_id`, `cc_id`),
  INDEX `idx_cc_id` (`cc_id` ASC),
  CONSTRAINT `fk_2af56955167b`
    FOREIGN KEY (`event_id`)
    REFERENCES `analytics_test`.`timeline_events` (`uuid`)
    ON DELETE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `analytics_test`.`timeline_event_projects`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`timeline_event_projects` (
  `event_id` BINARY(16) NOT NULL COMMENT 'timeline_events.uuid ref',
  `project_id` BINARY(16) NOT NULL COMMENT 'scalr.projects.project_id ref',
  PRIMARY KEY (`event_id`, `project_id`),
  INDEX `idx_project_id` (`project_id` ASC),
  CONSTRAINT `fk_e0325ab740c9`
    FOREIGN KEY (`event_id`)
    REFERENCES `analytics_test`.`timeline_events` (`uuid`)
    ON DELETE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `analytics_test`.`report_payloads`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`report_payloads` (
  `uuid` BINARY(16) NOT NULL COMMENT 'UUID',
  `created` DATETIME NOT NULL COMMENT 'Creation timestamp (UTC)',
  `secret` BINARY(20) NOT NULL COMMENT 'Secret hash (SHA1)',
  `payload` MEDIUMTEXT NOT NULL COMMENT 'Payload',
  PRIMARY KEY (`uuid`),
  INDEX `idx_created` (`created` ASC))
ENGINE = InnoDB
COMMENT = 'Report payloads';


-- -----------------------------------------------------
-- Table `analytics_test`.`farm_usage_d`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`farm_usage_d` (
  `account_id` INT(11) NOT NULL COMMENT 'scalr.clients.id ref',
  `farm_role_id` INT(11) NOT NULL COMMENT 'scalr.farm_roles.id ref',
  `usage_item` BINARY(4) NOT NULL COMMENT 'usage_items.id ref',
  `cc_id` BINARY(16) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0' COMMENT 'scalr.ccs.cc_id ref',
  `project_id` BINARY(16) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0' COMMENT 'scalr.projects.project_id ref',
  `date` DATE NOT NULL COMMENT 'UTC Date',
  `platform` VARCHAR(20) NOT NULL COMMENT 'cloud platform',
  `cloud_location` VARCHAR(255) NOT NULL COMMENT 'cloud location',
  `env_id` INT(11) NOT NULL COMMENT 'scalr.client_account_environments.id ref',
  `farm_id` INT(11) NOT NULL COMMENT 'scalr.farms.id ref',
  `role_id` INT(11) NOT NULL COMMENT 'scalr.roles.id ref',
  `cost` DECIMAL(18,9) NOT NULL DEFAULT 0.000000000 COMMENT 'Total cost of the usage',
  `min_usage` DECIMAL(8,2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT 'min usage quantity',
  `max_usage` DECIMAL(8,2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT 'max usage quantity',
  `usage_hours` DECIMAL(8,2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT 'Total usage/hours for day',
  `working_hours` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'hours when farm is running',
  INDEX `idx_farm_role_id` (`farm_role_id` ASC),
  INDEX `idx_date` (`date` ASC),
  INDEX `idx_farm_id` (`farm_id` ASC),
  INDEX `idx_env_id` (`env_id` ASC),
  INDEX `idx_cloud_location` (`cloud_location` ASC),
  INDEX `idx_platform` (`platform` ASC),
  PRIMARY KEY (`account_id`, `farm_role_id`, `usage_item`, `cc_id`, `project_id`, `date`),
  INDEX `idx_role_id` (`role_id` ASC),
  INDEX `idx_project_id` (`project_id` ASC),
  INDEX `idx_usage_item` (`usage_item` ASC))
ENGINE = InnoDB
COMMENT = 'Farm daily usage' PARTITION BY HASH(account_id) PARTITIONS 100 ;


-- -----------------------------------------------------
-- Table `analytics_test`.`upgrades`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`upgrades` (
  `uuid` BINARY(16) NOT NULL COMMENT ' /* comment truncated */ /*Unique identifier of update*/',
  `released` DATETIME NOT NULL COMMENT ' /* comment truncated */ /*The time when upgrade script is issued*/',
  `appears` DATETIME NOT NULL COMMENT ' /* comment truncated */ /*The time when upgrade does appear*/',
  `applied` DATETIME NULL DEFAULT NULL COMMENT ' /* comment truncated */ /*The time when update is successfully applied*/',
  `status` TINYINT(4) NOT NULL COMMENT ' /* comment truncated */ /*Upgrade status*/',
  `hash` VARBINARY(20) NULL DEFAULT NULL COMMENT ' /* comment truncated */ /*SHA1 hash of the upgrade file*/',
  PRIMARY KEY (`uuid`),
  INDEX `idx_status` (`status` ASC),
  INDEX `idx_appears` (`appears` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `analytics_test`.`upgrade_messages`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `analytics_test`.`upgrade_messages` (
  `uuid` BINARY(16) NOT NULL COMMENT ' /* comment truncated */ /*upgrades.uuid reference*/',
  `created` DATETIME NOT NULL COMMENT ' /* comment truncated */ /*Creation timestamp*/',
  `message` TEXT NULL DEFAULT NULL COMMENT ' /* comment truncated */ /*Error messages*/',
  INDEX `idx_uuid` (`uuid` ASC),
  CONSTRAINT `upgrade_messages_ibfk_1`
    FOREIGN KEY (`uuid`)
    REFERENCES `analytics_test`.`upgrades` (`uuid`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `analytics_test`.`aws_billing_records`
-- -----------------------------------------------------
CREATE TABLE `aws_billing_records` (
  `record_id` varchar(32) NOT NULL,
  `date` date NOT NULL,
  PRIMARY KEY (`record_id`),
  KEY `idx_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- -----------------------------------------------------
-- Data for table `analytics_test`.`tags`
-- -----------------------------------------------------
START TRANSACTION;
USE `analytics_test`;
INSERT INTO `analytics_test`.`tags` (`tag_id`, `name`) VALUES (1, 'Environment');
INSERT INTO `analytics_test`.`tags` (`tag_id`, `name`) VALUES (2, 'Platform');
INSERT INTO `analytics_test`.`tags` (`tag_id`, `name`) VALUES (3, 'Role');
INSERT INTO `analytics_test`.`tags` (`tag_id`, `name`) VALUES (4, 'Farm');
INSERT INTO `analytics_test`.`tags` (`tag_id`, `name`) VALUES (5, 'Farm role');
INSERT INTO `analytics_test`.`tags` (`tag_id`, `name`) VALUES (6, 'User');
INSERT INTO `analytics_test`.`tags` (`tag_id`, `name`) VALUES (8, 'Cost centre');
INSERT INTO `analytics_test`.`tags` (`tag_id`, `name`) VALUES (9, 'Project');
INSERT INTO `analytics_test`.`tags` (`tag_id`, `name`) VALUES (7, 'Role behavior');
INSERT INTO `analytics_test`.`tags` (`tag_id`, `name`) VALUES (10, 'Farm owner');

COMMIT;


-- -----------------------------------------------------
-- Data for table `analytics_test`.`settings`
-- -----------------------------------------------------
START TRANSACTION;
USE `analytics_test`;
INSERT INTO `analytics_test`.`settings` (`id`, `value`) VALUES ('budget_days', '[\"01-01\",\"04-01\",\"07-01\",\"10-01\"]');

COMMIT;

