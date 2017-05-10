#!/bin/bash
sed -i 's|getBlock(\$callback\[0\])->\$callback\[1\]|getBlock(\$callback\[0\])->{\$callback\[1\]}|g' $1/app/code/core/Mage/Core/Model/Layout.php
