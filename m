From: Yann Droneaud <ydroneaud@opteya.com>
Date: Thu, 15 Aug 2013 13:10:50 +0000
Subject: [PATCH v2 00/10] Getting rid of get_unused_fd_flags()
Message-Id: <cover.1376327678.git.ydroneaud@opteya.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-ia64@vger.kernel.org, Jeremy Kerr <jk@ozlabs.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, John Stultz <john.stultz@linaro.org>, Erik Gilling <konkers@android.com>, devel@driverdev.osuosl.org, Alex Williamson <alex.williamson@redhat.com>, kvm@vger.kernel.org, linux-fsdevel@vger.kernel.org, Eric Paris <eparis@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: Yann Droneaud <ydroneaud@opteya.com>, linux-kernel@vger.kernel.org

Hi,

Macro get_unused_fd() is a shortcut to call function get_unused_fd_flags(),
to allocate a file descriptor.

The macro use 0 as flags, so the file descriptor is created
without O_CLOEXEC flag.

This can be seen as an unsafe default eg. in most case O_CLOEXEC
must be used to not leak file descriptor across exec().

Newer kernel code should use anon_inode_getfd() or get_unused_fd_flags()
with flags provided by userspace. If flags cannot be given by userspace,
O_CLOEXEC must be the default flag.

Using O_CLOEXEC by default allows userspace to choose, without race,
if the file descriptor is going to be inherited across exec().

They are two ways to achieve this:

- makes get_unused_fd() use O_CLOEXEC by default

  It's difficult to get it right: every code using of get_unused_fd()
  must take this change into account and be fixed as soon as
  macro get_unused_fd() do the switch. Non updated code will have
  unexpected behavor and it's likely going to break API contract.

- remove get_unused_fd()

  It's going to break some out of tree, not yet upstream kernel code,
  but it's easy to notice and fix. Anyway, newer code should use
  anon_inode_getfd() or get_unused_fd_flags().

The latter option was choosen to ensure no unexpected behavor
for out of tree, not yet upstream code. Removing the macro is the safest
choice: it's better to break build than trying to make get_unused_fd()
use O_CLOEXEC by default and get all user of get_unused_fd() update.

Additionnaly, removing the macro is not going to break modules ABI.

In linux-next tag 20130815, they're currently:

- 19 calls to get_unused_fd_flags()     (+4)
     not counting get_unused_fd() and anon_inode_getfd()
- 10 calls to get_unused_fd()           (-4)
- 11 calls to anon_inode_getfd()        (0)

The following patchset try to convert all calls to get_unused_fd()
to get_unused_fd_flags(0) before removing get_unused_fd() macro.

Without get_unused_fd() macro, more subsystems are likely to use
anon_inode_getfd() and be teached to provide an API that let userspace
choose the opening flags of the file descriptor.

Changes from v1 <http://lkml.kernel.org/r/cover.1372777600.git.ydroneaud@opteya.com>:

- explicitly added subsystem maintainers as mail recepients.

- infiniband: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: subsystem maintainer applied another patch using
           get_unused_fd_flags(O_CLOEXEC) as suggested.

- android/sw_sync: use get_unused_fd_flags(0) instead of get_unused_fd()
  MODIFIED: use get_unused_fd_flags(O_CLOEXEC) as suggested by
  <http://lkml.kernel.org/r/CACSP8SjXGMk2_kX_+RgzqqQwqKernvF1Wt3K5tw991W5dfAnCA@mail.gmail.com>

- android/sync: use get_unused_fd_flags(0) instead of get_unused_fd()
  MODIFIED: use get_unused_fd_flags(O_CLOEXEC) as suggested by
  <http://lkml.kernel.org/r/CACSP8SjZcpcpEtQHzcGYhf-MP7QGo0XpN7-uN7rmD=vNtopG=w@mail.gmail.com>

- xfs: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: applied asis by subsystem maintainer.

- sctp: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: applied asis by subsystem maintainer.

Yann Droneaud (10):
  ia64: use get_unused_fd_flags(0) instead of get_unused_fd()
  ppc/cell: use get_unused_fd_flags(0) instead of get_unused_fd()
  android/sw_sync: use get_unused_fd_flags(O_CLOEXEC) instead of
    get_unused_fd()
  android/sync: use get_unused_fd_flags(O_CLOEXEC) instead of
    get_unused_fd()
  vfio: use get_unused_fd_flags(0) instead of get_unused_fd()
  binfmt_misc: use get_unused_fd_flags(0) instead of get_unused_fd()
  file: use get_unused_fd_flags(0) instead of get_unused_fd()
  fanotify: use get_unused_fd_flags(0) instead of get_unused_fd()
  events: use get_unused_fd_flags(0) instead of get_unused_fd()
  file: remove get_unused_fd()

 arch/ia64/kernel/perfmon.c                | 2 +-
 arch/powerpc/platforms/cell/spufs/inode.c | 4 ++--
 drivers/staging/android/sw_sync.c         | 2 +-
 drivers/staging/android/sync.c            | 2 +-
 drivers/vfio/vfio.c                       | 2 +-
 fs/binfmt_misc.c                          | 2 +-
 fs/file.c                                 | 2 +-
 fs/notify/fanotify/fanotify_user.c        | 2 +-
 include/linux/file.h                      | 1 -
 kernel/events/core.c                      | 2 +-
 10 files changed, 10 insertions(+), 11 deletions(-)

-- 
1.8.3.1

