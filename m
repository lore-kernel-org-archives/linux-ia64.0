From: Joe Perches <joe@perches.com>
Date: Tue, 14 Sep 2010 04:23:46 +0000
Subject: [PATCH next 00/16] treewide: Use static const char * const where possible
Message-Id: <cover.1284435709.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com, linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org, linux-usb@vger.kernel.org, linux-watchdog@vger.kernel.org, linux-fsdevel@vger.kernel.org, alsa-devel@alsa-project.org

Convert the uses that should be const of
	char *foo[] = {"bar", "baz"};
to
	const char * const foo[] = {"bar", "baz"};
or
	static const char * const foo[] = {"bar", "baz"};

Joe Perches (16):
  arch/alpha: Use static const char * const where possible
  arch/ia64: Use static const char * const where possible
  arch/microblaze: Use static const char * const where possible
  arch/x86: Use static const char * const where possible
  drivers/gpu: Use static const char * const where possible
  drivers/isdn: Use static const char * const where possible
  drivers/net: Use static const char * const where possible
  drivers/net/pcmcia: Use static const char * const where possible
  drivers/net/wireless: Use static const char * const where possible
  drivers/scsi: Use static const char * const where possible
  drivers/staging: Use static const char * const where possible
  drivers/usb: Use static const char * const where possible
  drivers/watchdog: Use static const char * const where possible
  fs: Use static const char * const where possible
  net/irda: Use static const char * const where possible
  sound: Use static const char * const where possible

 arch/alpha/kernel/err_ev6.c                  |   12 +++++---
 arch/alpha/kernel/err_marvel.c               |   33 ++++++++++++------------
 arch/alpha/kernel/err_titan.c                |   35 ++++++++++++++-----------
 arch/alpha/kernel/osf_sys.c                  |    4 +-
 arch/ia64/kernel/palinfo.c                   |    2 +-
 arch/microblaze/kernel/heartbeat.c           |   10 +++---
 arch/microblaze/kernel/timer.c               |   12 ++++----
 arch/x86/kernel/smpboot.c                    |    2 +-
 arch/x86/kvm/mmu.c                           |    2 +-
 drivers/gpu/drm/ttm/ttm_page_alloc.c         |    4 ++-
 drivers/isdn/pcbit/edss1.c                   |    2 +-
 drivers/isdn/pcbit/edss1.h                   |    2 +-
 drivers/net/3c515.c                          |    4 ++-
 drivers/net/eth16i.c                         |    4 ++-
 drivers/net/pcmcia/3c589_cs.c                |    2 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c    |    2 +-
 drivers/scsi/bfa/rport.c                     |    4 ++-
 drivers/scsi/pcmcia/nsp_debug.c              |    2 +-
 drivers/scsi/qla2xxx/qla_nx.c                |    4 +-
 drivers/scsi/qla4xxx/ql4_nx.c                |    2 +-
 drivers/staging/ath6kl/os/linux/ar6000_drv.c |   14 +++++-----
 drivers/staging/bcm/Debug.c                  |    5 ++-
 drivers/usb/host/oxu210hp-hcd.c              |    2 +-
 drivers/watchdog/machzwd.c                   |    2 +-
 fs/binfmt_flat.c                             |    4 ++-
 include/net/irda/irlan_event.h               |    2 +-
 net/irda/irlan/irlan_event.c                 |    2 +-
 sound/core/misc.c                            |    5 +---
 sound/core/pcm_native.c                      |    2 +-
 29 files changed, 99 insertions(+), 83 deletions(-)

-- 
1.7.3.rc1

