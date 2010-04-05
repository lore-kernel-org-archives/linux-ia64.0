From: Joe Perches <joe@perches.com>
Date: Mon, 05 Apr 2010 19:05:30 +0000
Subject: [PATCH 00/11] treewide: rename dev_info variables to something else
Message-Id: <cover.1270493677.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100304232928.2e45bdd1.akpm@linux-foundation.org>
In-Reply-To: <20100304232928.2e45bdd1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Mark Gross <mark.gross@intel.com>, Doug Thompson <dougthompson@xmission.com>, Mike Isely <isely@pobox.com>, Mauro Carvalho Chehab <mchehab@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Greg Kroah-Hartman <gregkh@suse.de>, David Vrabel <david.vrabel@csr.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, bluesmoke-devel@lists.sourceforge.net, linux-media@vger.kernel.org, linux-s390@vger.kernel.org, devel@driverdev.osuosl.org, linux-usb@vger.kernel.org, netdev@vger.kernel.org

There is a macro called dev_info that prints struct device specific
information.  Having variables with the same name can be confusing and
prevents conversion of the macro to a function.

Rename the existing dev_info variables to something else in preparation
to converting the dev_info macro to a function.

Joe Perches (11):
  arch/ia64/hp/common/sba_iommu.c: Rename dev_info to adi
  drivers/usb/host/hwa-hc.c: Rename dev_info to hdi
  drivers/usb/wusbcore/wusbhc.h: Remove unused dev_info from struct wusb_port
  drivers/s390/block/dcssblk.c: Rename dev_info to ddi
  drivers/edac/amd: Rename dev_info to adi
  drivers/edac/cpc925_edac.c: Rename dev_info to cdi
  drivers/edac/e7*_edac.c: Rename dev_info to edi
  drivers/staging/iio: Rename dev_info to idi
  pvrusb2-v4l2: Rename dev_info to pdi
  drivers/char/mem.c: Rename dev_info to bdi
  drivers/uwb: Rename dev_info to wdi

 arch/ia64/hp/common/sba_iommu.c            |    8 +-
 drivers/char/mem.c                         |    6 +-
 drivers/edac/amd8111_edac.c                |   88 ++++----
 drivers/edac/amd8131_edac.c                |   86 ++++----
 drivers/edac/cpc925_edac.c                 |  122 +++++-----
 drivers/edac/e752x_edac.c                  |   18 +-
 drivers/edac/e7xxx_edac.c                  |    8 +-
 drivers/media/video/pvrusb2/pvrusb2-v4l2.c |   22 +-
 drivers/s390/block/dcssblk.c               |  328 ++++++++++++++--------------
 drivers/staging/iio/accel/lis3l02dq_core.c |    4 +-
 drivers/staging/iio/accel/lis3l02dq_ring.c |   20 +-
 drivers/staging/iio/accel/sca3000_core.c   |   24 +-
 drivers/staging/iio/adc/max1363_core.c     |   36 ++--
 drivers/staging/iio/adc/max1363_ring.c     |    6 +-
 drivers/staging/iio/chrdev.h               |    2 +-
 drivers/staging/iio/iio.h                  |   54 +++---
 drivers/staging/iio/industrialio-core.c    |  232 ++++++++++----------
 drivers/staging/iio/industrialio-ring.c    |   38 ++--
 drivers/staging/iio/industrialio-trigger.c |   34 ++--
 drivers/staging/iio/ring_generic.h         |    4 +-
 drivers/staging/iio/trigger_consumer.h     |   16 +-
 drivers/usb/host/hwa-hc.c                  |   18 +-
 drivers/usb/wusbcore/wusbhc.h              |   10 -
 drivers/uwb/i1480/i1480u-wlp/lc.c          |   16 +-
 drivers/uwb/wlp/messages.c                 |   40 ++--
 drivers/uwb/wlp/sysfs.c                    |   46 ++--
 drivers/uwb/wlp/wlp-lc.c                   |   12 +-
 27 files changed, 644 insertions(+), 654 deletions(-)

