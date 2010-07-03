From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 03 Jul 2010 22:15:04 +0000
Subject: [PATCH 0/6] kill .ioctl file_operation
Message-Id: <1278195310-25590-1-git-send-email-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: John Kacur <jkacur@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Arnd Bergmann <arnd@arndb.de>, alsa-devel@alsa-project.org, Al Viro <viro@zeniv.linux.org.uk>, autofs@linux.kernel.org, Cris <linux-cris-kernel@axis.com>, "H. Peter Anvin" <hpa@zytor.com>, Ian Kent <raven@themaw.net>, Jaroslav Kysela <perex@perex.cz>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-ia64@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Takashi Iwai <tiwai@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>

This removes the .ioctl file operation from all the
remaining users that are in today's linux-next
tree.

I'd like to have this added to linux-next to make
sure we don't get any new users and we can seamlessly
apply the final patches for this in 2.6.36.

The intention behind removing the .ioctl operation
is to be able to remove the big kernel lock (BKL)
from the ioctl system call.

Ideally, maintainers of the code in question should
just apply the respective patches to their -next
tree so we can simply apply the final patch removing
the definition of .ioctl.

	Arnd

Cc: alsa-devel@alsa-project.org
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: autofs@linux.kernel.org
Cc: Cris <linux-cris-kernel@axis.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ian Kent <raven@themaw.net>
Cc: Jaroslav Kysela <perex@perex.cz>
Cc: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: John Kacur <jkacur@redhat.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Mikael Starvik <starvik@axis.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>

Arnd Bergmann (5):
  ia64/perfmon: convert to unlocked_ioctl
  sound/oss: convert to unlocked_ioctl
  autofs/autofs4: move compat_ioctl handling into fs
  v4l: convert v4l2-dev to unlocked_ioctl
  bkl: remove locked .ioctl file operation

Frederic Weisbecker (1):
  cris: Pushdown the bkl from ioctl

 Documentation/filesystems/Locking         |    8 +---
 Documentation/filesystems/vfs.txt         |    6 +--
 arch/cris/arch-v10/drivers/gpio.c         |   30 +++++++++----
 arch/cris/arch-v10/drivers/i2c.c          |   24 ++++++++---
 arch/cris/arch-v10/drivers/sync_serial.c  |   32 +++++++++----
 arch/cris/arch-v32/drivers/cryptocop.c    |   24 ++++++++---
 arch/cris/arch-v32/drivers/mach-a3/gpio.c |   28 ++++++++----
 arch/cris/arch-v32/drivers/mach-fs/gpio.c |   29 ++++++++----
 arch/cris/arch-v32/drivers/sync_serial.c  |   30 +++++++++----
 arch/ia64/kernel/perfmon.c                |   22 +++++-----
 drivers/media/video/v4l2-dev.c            |   52 ++++++----------------
 fs/autofs/root.c                          |   67 +++++++++++++++++++++++++++-
 fs/autofs4/root.c                         |   49 +++++++++++++++++++++
 fs/bad_inode.c                            |    7 ---
 fs/compat_ioctl.c                         |   39 +----------------
 fs/ioctl.c                                |   18 ++------
 fs/proc/inode.c                           |   17 ++------
 include/linux/auto_fs.h                   |    1 +
 include/linux/fs.h                        |    5 +-
 sound/oss/au1550_ac97.c                   |   54 +++++++++++++++---------
 sound/oss/dmasound/dmasound_core.c        |   35 ++++++++++++---
 sound/oss/msnd_pinnacle.c                 |   15 ++++--
 sound/oss/sh_dac_audio.c                  |   18 ++++++-
 sound/oss/swarm_cs4297a.c                 |   25 +++++++++--
 sound/oss/vwsnd.c                         |   24 ++++++-----
 25 files changed, 410 insertions(+), 249 deletions(-)

