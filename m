From: Yann Droneaud <ydroneaud@opteya.com>
Date: Fri, 06 Sep 2013 10:39:50 +0000
Subject: [PATCH v3 0/8] Getting rid of get_unused_fd() / use O_CLOEXEC
Message-Id: <cover.1378460926.git.ydroneaud@opteya.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-ia64@vger.kernel.org, Jeremy Kerr <jk@ozlabs.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, Eric Paris <eparis@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, Jonathan Cameron <jic23@cam.ac.uk>, linux-iio@vger.kernel.org
Cc: Yann Droneaud <ydroneaud@opteya.com>

Hi,

With help from subsystem maintainers, I've managed to get some of
get_unused_fd() calls converted to use get_unused_fd_flags(O_CLOEXEC)
instead. [ANDROID][IB][VFIO]

KVM subsystem maintainers helped me to change calls to anon_inode_getfd()
to use O_CLOEXEC by default. [KVM]

Some maintainers applied my patches to convert get_unused_fd() to
get_unused_fd_flags(0) were using O_CLOEXEC wasn't possible without breaking ABI.
[SCTP][XFS]

So, still in the hope to get rid of get_unused_fd(), please find a another
attempt to remove get_unused_fd() macro and encourage subsystems to use
get_unused_fd_flags(O_CLOEXEC) or anon_inode_getfd(O_CLOEXEC) by default
were appropriate.

The patchset convert all calls to get_unused_fd()
to get_unused_fd_flags(0) before removing get_unused_fd() macro.

Without get_unused_fd() macro, more subsystems are likely to use
anon_inode_getfd() and be teached to provide an API that let userspace
choose the opening flags of the file descriptor.

Additionally I'm suggesting Industrial IO (IIO) subsystem to use
anon_inode_getfd(O_CLOEXEC): it's the only subsystem using anon_inode_getfd()
with a fixed set of flags not including O_CLOEXEC.

Not using O_CLOEXEC by default or not letting userspace provide the "open" flags
should be considered bad practice from security point of view:
in most case O_CLOEXEC must be used to not leak file descriptor across exec().
Using O_CLOEXEC by default when flags are not provided by userspace allows it
to choose, without race, if the file descriptor is going to be inherited
across exec().

Status:

In linux-next tag 20130906, they're currently:

- 22 calls to get_unused_fd_flags()     (+3)
     not counting get_unused_fd() and anon_inode_getfd()
-  7 calls to get_unused_fd()           (-3)
- 11 calls to anon_inode_getfd()        (0)

Changes from patchset v2 [PATCHSETv2]:

- android/sw_sync: use get_unused_fd_flags(O_CLOEXEC) instead of get_unused_fd()
  DROPPED: applied upstream

- android/sync: use get_unused_fd_flags(O_CLOEXEC) instead of get_unused_fd()
  DROPPED: applied upstream

- vfio: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: applied upstream.
  Additionally subsystem maintainer applied another patch on top
  to set the flags to O_CLOEXEC.

- industrialio: use anon_inode_getfd() with O_CLOEXEC flag
  NEW: propose to use O_CLOEXEC as default flag.

Links:

[ANDROID]
  http://lkml.kernel.org/r/CACSP8SjXGMk2_kX_+RgzqqQwqKernvF1Wt3K5tw991W5dfAnCA@mail.gmail.com
  http://lkml.kernel.org/r/CACSP8SjZcpcpEtQHzcGYhf-MP7QGo0XpN7-uN7rmD=vNtopG=w@mail.gmail.com

[IB]
  http://lkml.kernel.org/r/CAL1RGDXV1_BjSLrQDFdVQ1_D75+bMtOtikHOUp8VBiy_OJUf=w@mail.gmail.com

[VFIO]
  http://lkml.kernel.org/r/20130822171744.1297.13711.stgit@bling.home

[KVM]
  http://lkml.kernel.org/r/5219A8FC.8090307@redhat.com
  http://lkml.kernel.org/r/3557EF65-4327-4DAE-999A-B0EE13C433F5@suse.de
  http://lkml.kernel.org/r/20130826102023.GA8218@redhat.com

[SCTP]
  http://lkml.kernel.org/r/51D312E8.6090702@gmail.com
  http://lkml.kernel.org/r/20130702.161428.1703028286206350504.davem@davemloft.net

[XFS]
  http://lkml.kernel.org/r/20130709205321.GV20932@sgi.com

[PATCHSETv2]
  http://lkml.kernel.org/r/cover.1376327678.git.ydroneaud@opteya.com

Yann Droneaud (8):
  ia64: use get_unused_fd_flags(0) instead of get_unused_fd()
  ppc/cell: use get_unused_fd_flags(0) instead of get_unused_fd()
  binfmt_misc: use get_unused_fd_flags(0) instead of get_unused_fd()
  file: use get_unused_fd_flags(0) instead of get_unused_fd()
  fanotify: use get_unused_fd_flags(0) instead of get_unused_fd()
  events: use get_unused_fd_flags(0) instead of get_unused_fd()
  file: remove get_unused_fd()
  industrialio: use anon_inode_getfd() with O_CLOEXEC flag

 arch/ia64/kernel/perfmon.c                | 2 +-
 arch/powerpc/platforms/cell/spufs/inode.c | 4 ++--
 drivers/iio/industrialio-event.c          | 2 +-
 fs/binfmt_misc.c                          | 2 +-
 fs/file.c                                 | 2 +-
 fs/notify/fanotify/fanotify_user.c        | 2 +-
 include/linux/file.h                      | 1 -
 kernel/events/core.c                      | 2 +-
 8 files changed, 8 insertions(+), 9 deletions(-)

-- 
1.8.3.1

