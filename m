From: Joe Perches <joe@perches.com>
Date: Tue, 25 Aug 2020 04:55:57 +0000
Subject: [PATCH 00/29] treewide: Convert comma separated statements
Message-Id: <cover.1598331148.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <trivial@kernel.org>, oprofile-list@lists.sf.net, linux-ide@vger.kernel.org, drbd-dev@lists.linbit.com, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, intel-gfx@lists.freedesktop.org, linux-hwmon@vger.kernel.org, linux-input@vger.kernel.org, linux-bcache@vger.kernel.org, netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, linux-fsdevel@vger.kernel.org, reiserfs-devel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org, linux-block@vger.kernel.org, linux-mtd@lists.infradead.org, linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org, linux-fbdev@vger.kernel.org, linux-pm@vger.kernel.org, linux-kselftest@vger.kernel.org

There are many comma separated statements in the kernel.
See:https://lore.kernel.org/lkml/alpine.DEB.2.22.394.2008201856110.2524@hadrien/

Convert the comma separated statements that are in if/do/while blocks
to use braces and semicolons.

Many comma separated statements still exist but those are changes for
another day.

Joe Perches (29):
  coding-style.rst: Avoid comma statements
  alpha: Avoid comma separated statements
  ia64: Avoid comma separated statements
  sparc: Avoid comma separated statements
  ata: Avoid comma separated statements
  drbd: Avoid comma separated statements
  lp: Avoid comma separated statements
  dma-buf: Avoid comma separated statements
  drm/gma500: Avoid comma separated statements
  drm/i915: Avoid comma separated statements
  hwmon: (scmi-hwmon): Avoid comma separated statements
  Input: MT - Avoid comma separated statements
  bcache: Avoid comma separated statements
  media: Avoid comma separated statements
  mtd: Avoid comma separated statements
  8390: Avoid comma separated statements
  fs_enet: Avoid comma separated statements
  wan: sbni: Avoid comma separated statements
  s390/tty3270: Avoid comma separated statements
  scai/arm: Avoid comma separated statements
  media: atomisp: Avoid comma separated statements
  video: fbdev: Avoid comma separated statements
  fuse: Avoid comma separated statements
  reiserfs: Avoid comma separated statements
  lib/zlib: Avoid comma separated statements
  lib: zstd: Avoid comma separated statements
  ipv6: fib6: Avoid comma separated statements
  sunrpc: Avoid comma separated statements
  tools: Avoid comma separated statements

 Documentation/process/coding-style.rst        |  17 +
 arch/alpha/kernel/pci_iommu.c                 |   8 +-
 arch/alpha/oprofile/op_model_ev4.c            |  22 +-
 arch/alpha/oprofile/op_model_ev5.c            |   8 +-
 arch/ia64/kernel/smpboot.c                    |   7 +-
 arch/sparc/kernel/smp_64.c                    |   7 +-
 drivers/ata/pata_icside.c                     |  21 +-
 drivers/block/drbd/drbd_receiver.c            |   6 +-
 drivers/char/lp.c                             |   6 +-
 drivers/dma-buf/st-dma-fence.c                |   7 +-
 drivers/gpu/drm/gma500/mdfld_intel_display.c  |  44 ++-
 drivers/gpu/drm/i915/gt/gen8_ppgtt.c          |   8 +-
 drivers/gpu/drm/i915/gt/intel_gt_requests.c   |   6 +-
 .../gpu/drm/i915/gt/selftest_workarounds.c    |   6 +-
 drivers/gpu/drm/i915/intel_runtime_pm.c       |   6 +-
 drivers/hwmon/scmi-hwmon.c                    |   6 +-
 drivers/input/input-mt.c                      |  11 +-
 drivers/md/bcache/bset.c                      |  12 +-
 drivers/md/bcache/sysfs.c                     |   6 +-
 drivers/media/i2c/msp3400-kthreads.c          |  12 +-
 drivers/media/pci/bt8xx/bttv-cards.c          |   6 +-
 drivers/media/pci/saa7134/saa7134-video.c     |   7 +-
 drivers/mtd/devices/lart.c                    |  10 +-
 drivers/net/ethernet/8390/axnet_cs.c          |  19 +-
 drivers/net/ethernet/8390/lib8390.c           |  14 +-
 drivers/net/ethernet/8390/pcnet_cs.c          |   6 +-
 .../ethernet/freescale/fs_enet/fs_enet-main.c |  11 +-
 drivers/net/wan/sbni.c                        | 101 +++---
 drivers/s390/char/tty3270.c                   |   6 +-
 drivers/scsi/arm/cumana_2.c                   |  19 +-
 drivers/scsi/arm/eesox.c                      |   9 +-
 drivers/scsi/arm/powertec.c                   |   9 +-
 .../media/atomisp/pci/atomisp_subdev.c        |   6 +-
 drivers/video/fbdev/tgafb.c                   |  12 +-
 fs/fuse/dir.c                                 |  24 +-
 fs/reiserfs/fix_node.c                        |  36 ++-
 lib/zlib_deflate/deftree.c                    |  49 ++-
 lib/zstd/compress.c                           | 120 ++++---
 lib/zstd/fse_compress.c                       |  24 +-
 lib/zstd/huf_compress.c                       |   6 +-
 net/ipv6/ip6_fib.c                            |  12 +-
 net/sunrpc/sysctl.c                           |   6 +-
 tools/lib/subcmd/help.c                       |  10 +-
 tools/power/cpupower/utils/cpufreq-set.c      |  14 +-
 tools/testing/selftests/vm/gup_benchmark.c    |  18 +-
 tools/testing/selftests/vm/userfaultfd.c      | 296 +++++++++++-------
 46 files changed, 694 insertions(+), 382 deletions(-)

-- 
2.26.0
