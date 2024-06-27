<?php
return [
    'db' => [
        'connection' => [
            'default' => [
                'host' => 'localhost',
                'dbname' => 'magento2',
                'username' => 'testdbuser',
                'password' => 'mydbpassword',
                'active' => '1',
            ],
        ],
    ],
    ...
    'cache' => [
        'frontend' => [
            'default' => [
                'backend' => 'Cm_Cache_Backend_Redis',
                'backend_options' => [
                    'server' => '127.0.0.1',
                    'database' => '0',
                    'port' => '6379',
                ],
            ],
        ],
    ],
];