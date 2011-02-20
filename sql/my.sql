CREATE TABLE `job` (
  `job_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `r_file` varchar(255) NOT NULL,
  `r_return` varchar(255) NOT NULL,
  PRIMARY KEY (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `job_args` (
  `job_id` bigint(20) unsigned NOT NULL,
  `arg` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  PRIMARY KEY (`job_id`,`arg`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `job_return` (
  `job_id` bigint(20) unsigned NOT NULL,
  `log` text,
  PRIMARY KEY (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
