#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

echo "Running Superset initialization..."

# This command will create a default admin user and sync permissions.
# It's safe to run on every startup, as it will only add missing permissions.
superset init

# This command will apply any pending database migrations.
# It's crucial to run this after any Superset version upgrade.
superset db upgrade

echo "Initialization complete. Starting web server..."

# The 'exec' command is important, it replaces the script process with the gunicorn process.
# This allows gunicorn to receive signals correctly (like for graceful shutdowns).
exec "$@"
