From: Yann Droneaud <ydroneaud@opteya.com>
Date: Wed, 30 Oct 2013 19:47:40 +0000
Subject: [PATCH v4 0/7] Getting rid of get_unused_fd()
Message-Id: <cover.1383121137.git.ydroneaud@opteya.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-ia64@vger.kernel.org, Jeremy Kerr <jk@ozlabs.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, Eric Paris <eparis@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: Yann Droneaud <ydroneaud@opteya.com>, linux-kernel@vger.kernel.org

Hi,

Please find the fourth revision of my patchset to remove get_unused_fd()
macro in order to encourage subsystems to use get_unused_fd_flags() or
anon_inode_getfd() with open flags set to O_CLOEXEC were appropriate.

The patchset convert all calls to get_unused_fd() to
get_unused_fd_flags(0) before removing get_unused_fd() macro.

Without get_unused_fd() macro, more subsystems are likely to use
anon_inode_getfd() and be teached to provide an API that let userspace
choose the opening flags of the file descriptor.

Not using O_CLOEXEC by default or not letting userspace provide the
"open" flags should be considered bad practice from security point
of view: in most case O_CLOEXEC must be used to not leak file descriptor
across exec().

Using O_CLOEXEC by default when flags are not provided by userspace
allows userspace to set, using fcntl(), without any risk of race, 
if the file descriptor is going to be inherited or not across exec().

Status:

In linux-next tag 20131029, they're currently:

- 32 calls to fd_install()
- 23 calls to get_unused_fd_flags()
- 11 calls to anon_inode_getfd()
-  7 calls to get_unused_fd()

Changes from patchset v3 [PATCHSETv3]:

- industrialio: use anon_inode_getfd() with O_CLOEXEC flag
  DROPPED: applied upstream

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

Changes from patchset v1 [PATCHSETv1]:

- explicitly added subsystem maintainers as mail recepients.

- infiniband: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: subsystem maintainer applied another patch
           using get_unused_fd_flags(O_CLOEXEC) as suggested.

- android/sw_sync: use get_unused_fd_flags(0) instead of get_unused_fd()
  MODIFIED: use get_unused_fd_flags(O_CLOEXEC) as suggested

- android/sync: use get_unused_fd_flags(0) instead of get_unused_fd()
  MODIFIED: use get_unused_fd_flags(O_CLOEXEC) as suggested

- xfs: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: applied asis by subsystem maintainer.

- sctp: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: applied asis by subsystem maintainer.

Links:

[PATCHSETv3]
  http://lkml.kernel.org/r/cover.1378460926.git.ydroneaud@opteya.com

[PATCHSETv2]
  http://lkml.kernel.org/r/cover.1376327678.git.ydroneaud@opteya.com

[PATCHSETv1]
  http://lkml.kernel.org/r/cover.1372777600.git.ydroneaud@opteya.com

Yann Droneaud (7):
  ia64: use get_unused_fd_flags(0) instead of get_unused_fd()
  ppc/cell: use get_unused_fd_flags(0) instead of get_unused_fd()
  binfmt_misc: use get_unused_fd_flags(0) instead of get_unused_fd()
  file: use get_unused_fd_flags(0) instead of get_unused_fd()
  fanotify: use get_unused_fd_flags(0) instead of get_unused_fd()
  events: use get_unused_fd_flags(0) instead of get_unused_fd()
  file: remove get_unused_fd()

 arch/ia64/kernel/perfmon.c                | 2 +-
 arch/powerpc/platforms/cell/spufs/inode.c | 4 ++--
 fs/binfmt_misc.c                          | 2 +-
 fs/file.c                                 | 2 +-
 fs/notify/fanotify/fanotify_user.c        | 2 +-
 include/linux/file.h                      | 1 -
 kernel/events/core.c                      | 2 +-
 7 files changed, 7 insertions(+), 8 deletions(-)

-- 
1.8.3.1

