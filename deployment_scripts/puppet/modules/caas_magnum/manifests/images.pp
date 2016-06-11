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
# caas_magnum::images

class caas_magnum::images {

  notice('MODULAR: caas_magnum/images')

  $magnum          = hiera_hash('fuel-plugin-magnum', undef)
  $magnum_enabled  = pick($magnum['metadata']['enabled'], false)

  if ($magnum_enabled) {

    $glance_image_name    = pick($magnum['glance_image_name'], 'fedora-21-atomic-5')
    $glance_image_ensure  = pick($magnum['glance_image_ensure'], 'present')
    $glance_image_public  = pick($magnum['glance_image_public'], true)
    $glance_image_source  = pick($magnum['glance_image_source'], 'https://fedorapeople.org/groups/magnum/fedora-21-atomic-5.qcow2')

    glance_image { $glance_image_name :
      ensure           => $glance_image_ensure,
      name             => $glance_image_name,
      is_public        => $glance_image_public,
      container_format => 'bare',
      disk_format      => 'qcow2',
      source           => $glance_image_source,
      properties       => { 'os_distro'      => 'fedora-atomic' },
    }

  }
}
