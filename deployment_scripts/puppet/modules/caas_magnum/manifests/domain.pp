#
# Copyright (C) 2016 AT&T Inc, Services.
#
# Author: Shaik Apsar
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# caas_magnum::domain
#
# TODO(shaikapsar): workaround for bugfix https://bugs.launchpad.net/puppet-magnum/+bug/1581372
class caas_magnum::domain (
  $domain_id ,
  $domain_admin_id ,
  ) {

  magnum_config {

    'trust/trustee_domain_id':
      value => $domain_id;

    'trust/trustee_domain_admin_id':
      value => $domain_admin_id;
  }

}
