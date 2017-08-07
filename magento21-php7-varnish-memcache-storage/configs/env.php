<?php
return array (
  'backend' =>
  array (
    'frontName' => 'admin',
  ),
  'install' =>
  array (
    'date' => 'Tue, 22 Mar 2016 23:34:20 +0000',
  ),
  'crypt' =>
  array (
    'key' => 'f0a297d1f49450646ff5564e8698db5f',
  ),
  'session' =>
  array (
    'save' => 'memcache',
    'save_path' => 'tcp://MEMCACHED_1:11211, tcp://MEMCACHED_2:11211'
  ),
  'db' =>
  array (
    'table_prefix' => '',
    'connection' =>
    array (
      'default' =>
      array (
        'host' => 'DB_1',
        'dbname' => 'magento',
        'username' => 'DB_USER',
        'password' => 'DB_PASS',
        'active' => '1',
      ),
    ),
  ),
  'resource' =>
  array (
    'default_setup' =>
    array (
      'connection' => 'default',
    ),
  ),
  'x-frame-options' => 'SAMEORIGIN',
  'MAGE_MODE' => 'production',
  'cache_types' =>
  array (
    'config' => 1,
    'layout' => 1,
    'block_html' => 1,
    'collections' => 1,
    'reflection' => 1,
    'db_ddl' => 1,
    'eav' => 1,
    'config_integration' => 1,
    'config_integration_api' => 1,
    'full_page' => 1,
    'translate' => 1,
    'config_webservice' => 1,
  ),
);
