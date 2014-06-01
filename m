From: Yann Droneaud <ydroneaud@opteya.com>
Date: Sun, 01 Jun 2014 13:58:41 +0000
Subject: [PATCHv7 0/6] Getting rid of get_unused_fd() / enable close-on-exec
Message-Id: <cover.1401630396.git.ydroneaud@opteya.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-ia64@vger.kernel.org, Jeremy Kerr <jk@ozlabs.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, Richard Guy Briggs <rgb@redhat.com>, Eric Paris <eparis@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, trivial@kernel.org
Cc: Yann Droneaud <ydroneaud@opteya.com>, linux-kernel@vger.kernel.org, Ulrich Drepper <drepper@gmail.com>

TL;DR;

These are mostly obvious patches, easy to review, easy to apply:
you want them in the kernel. Now. And get_unused_fd() deserves to
die. Act today !

Hi,

Please find the seventh revision of my patchset to remove get_unused_fd()
macro in order to help subsystems to use get_unused_fd_flags() (or
anon_inode_getfd()) with flags either provided by the userspace or
set to O_CLOEXEC by default where appropriate.

Without get_unused_fd() macro, more subsystems are likely to use
get_unused_fd_flags() (or anon_inode_getfd()) and be taught to
provide an API that let userspace choose the opening flags
of the file descriptor.

Not allowing userspace to provide the "open" flags or not using O_CLOEXEC
by default should be considered bad practice from security point of view:
in most case O_CLOEXEC must be used to not leak file descriptor across
exec().

Not allowing userspace to atomically set close-on-exec flag and not using
O_CLOEXEC should be avoided to protect multi-threaded program
from race condition when it tried to set close-on-exec flag using
fcntl(fd, F_SETFD, FD_CLOEXEC) after opening the file descriptor.

Example:

    int fd;
    int ret;

    fd = open(filename, O_RDONLY);
    if (fd < 0) {
        perror("open");
        return -1;
    }

    /*
     * window opened for another thread to call fork(),
     * then the new process can call exec() at any time
     * and the file descriptor would be inherited
     */

    ret = fcntl(fd, F_SETFD, FD_CLOEXEC)
    if (ret < 0) {
        perror("fnctl()");
        close(fd);
        return -1;
    }

vs.:

    int fd;
    fd = open(filaneme, O_RDONLY | O_CLOEXEC);
    if (fd < 0) {
        perror("open");
        return -1;
    }

Using O_CLOEXEC by default when flags are not (eg. cannot be) provided
by userspace is the safest bet as it allows userspace to choose, if, when
and where the file descriptor is going to be inherited across exec():
userspace is free to call fcntl() to remove FD_CLOEXEC flag in the child
process that will call exec().

Unfortunately, O_CLOEXEC cannot be made the default for most existing system
calls as it's not the default behavior for POSIX / Unix. Reader interested
in this issue could have a look at "Ghosts of Unix past, part 2: Conflated
designs" [1] article by Neil Brown.

FAQ:

- Why do one want close-on-exec ?

Setting close-on-exec flag on file descriptor ensure it won't be inherited
silently by child, child of child, etc. when executing another program.

If the file descriptor is not closed, some kernel resources can be locked
until the last process with the opened file descriptor exit.

If the file descriptor is not closed, this can lead to a security issue,
eg. making resources available to a less privileged program allowing
information leak and/or deny of service.

- Why do one need atomic close-on-exec ?

Even if it's possible to set close-on-exec flag through call to fcntl()
as shown previously, it introduces a race condition in multi-threaded
process, where a thread call fork() / exec() while another thread
is between call to open() and fcntl().

Additionally, using close-on-exec free the programmer from tracking manually
which file descriptor is to close in a child before calling exec():
in a program using multiple third-party libraries, it's difficult to know
which file descriptor must be closed.
AFAIK, while there's a atexit(), pthread_atfork(), there's no atexec()
userspace function in libc to allow libraries to register a handler in
order to close its opened file descriptor before exec().

- Why default to close-on-exec ?

Some kernel interfaces don't allow userspace to pass a O_CLOEXEC-like
flag when creating a new file descriptor.

In such cases, if possible (see below), O_CLOEXEC must be made
the default so that userspace doesn't have to call fcntl()
which, as demonstrated previously, is open to race condition in
multi-threaded program.

- How to choose between flag 0 or O_CLOEXEC in call to
  get_unused_fd_flags() (or anon_inode_getfd()) ?

Short: Will it break existing application ? Will it break kernel ABI ?

       If answer is no, use O_CLOEXEC.
       If answer is yes, use 0.

Long: If userspace expect to retrieve a file descriptor with plain
      old Unix(tm) semantics, O_CLOEXEC must not be the default, as it
      could break some applications expecting that the file descriptor
      will be inherited across exec().

      But for some subsystems, such as InfiniBand, KVM, VFIO, it makes
      no sense to have file descriptors inherited across exec() since
      those are tied to resources that will vanish when a another program
      will replace the current one by mean of exec(), so it's safe to use
      O_CLOEXEC in such cases.

      For others, like XFS, the file descriptor is retrieved by one
      program and will be used by a different program, executed as a
      child. In this case, setting O_CLOEXEC would break existing
      application which do not expect to have to call fcntl(fd,
      F_SETFD, 0) to make it available across exec().

      If file descriptor created by a subsystem is not tied to the
      current process resources, it's likely legal to use it in a
      different process context, thus O_CLOEXEC must not be the default.

      If one, as a subsystem maintainer, cannot tell for sure that
      no userspace program ever rely current behavior, eg. file descriptor
      being inherited across exec(), then the default flag *must*
      be kept 0 to not break application.

- This subsystem cannot be turned to use O_CLOEXEC by default:

If O_CLOEXEC cannot be made the default, it would be interesting
to think to extend the API to have a (set of) function(s) taking
a flag parameter so that userspace can atomically request close-on-exec
if it need it (and it should need it).

- Background:

One might want to read "Secure File Descriptor Handling" [2] by
Ulrich Drepper who is responsible of adding O_CLOEXEC flag on open(),
and flags alike on other syscalls.

One might also want to read PEP-446 "Make newly created file descriptors
non-inheritable" [3] by Victor Stinner since it has lot more background
information on file descriptor leaking.

One also like to read "Excuse me son, but your code is leaking !!!" [4]
by Dan Walsh for advice.

[1] http://lwn.net/Articles/412131/
[2] http://udrepper.livejournal.com/20407.html
[3] http://www.python.org/dev/peps/pep-0446/
[4] http://danwalsh.livejournal.com/53603.html

- Statistics:

In linux-next tag next-20140530, they're currently:

- 32 calls to fd_install()
       with one call part of anon_inode_getfd()
- 25 calls to get_unused_fd_flags()
       with one call part of anon_inode_getfd()
       with another part of get_unused_fd() macro
- 11 calls to anon_inode_getfd()
-  9 calls to anon_inode_getfile()
       with one call part of anon_inode_getfd()
-  6 calls to get_unused_fd()

Changes from patchset v6 [PATCHSETv6]

- Rebased on top of latest -next
- Added Cc: trivial@kernel.org for the first trivials
  patches.

Changes from patchset v5 [PATCHSETv5]

- perf: introduce a flag to enable close-on-exec in perf_event_open()
  DROPPED: applied upstream, commit a21b0b354d4a.

Changes from patchset v4 [PATCHSETv4]:

- rewrote cover letter following discussion with perf maintainer.
  Thanks to Peter Zijlstra.

- modified a bit some commit messages.

- events: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: replaced by following patch.

- perf: introduce a flag to enable close-on-exec in perf_event_open()
  NEW: instead of hard coding the flags to 0, this patch
       allows userspace to specify close-on-exec flag.

- fanotify: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: replaced by following patch.

- fanotify: enable close-on-exec on events' fd when requested in
    fanotify_init()
  NEW: instead of hard coding the flags to 0, this patch
       enable close-on-exec if userspace request it.

Changes from patchset v3 [PATCHSETv3]:

- industrialio: use anon_inode_getfd() with O_CLOEXEC flag
  DROPPED: applied upstream, commit a646fbf0fd11.

Changes from patchset v2 [PATCHSETv2]:

- android/sw_sync: use get_unused_fd_flags(O_CLOEXEC) instead of get_unused_fd()
  DROPPED: applied upstream, commit 45acea57335e.

- android/sync: use get_unused_fd_flags(O_CLOEXEC) instead of get_unused_fd()
  DROPPED: applied upstream, commit 9c6cd3b39048.

- vfio: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: applied upstream, commit a5d550703d2c.
  Additionally subsystem maintainer applied another patch on top
  to set the flags to O_CLOEXEC, commit 5d042fbdbb2d.

- industrialio: use anon_inode_getfd() with O_CLOEXEC flag
  NEW: propose to use O_CLOEXEC as default flag.

Changes from patchset v1 [PATCHSETv1]:

- explicitly added subsystem maintainers as mail recepients.

- infiniband: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: subsystem maintainer applied another patch
           using get_unused_fd_flags(O_CLOEXEC) as suggested,
	   commit da183c7af844.

- android/sw_sync: use get_unused_fd_flags(0) instead of get_unused_fd()
  MODIFIED: use get_unused_fd_flags(O_CLOEXEC) as suggested.

- android/sync: use get_unused_fd_flags(0) instead of get_unused_fd()
  MODIFIED: use get_unused_fd_flags(O_CLOEXEC) as suggested.

- xfs: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: applied asis by subsystem maintainer, commit 862a62937e76.

- sctp: use get_unused_fd_flags(0) instead of get_unused_fd()
  DROPPED: applied asis by subsystem maintainer, commit 8a59bd3e9b29.

Links:

[PATCHSETv6]
  http://lkml.kernel.org/r/cover.1394532336.git.ydroneaud@opteya.com

[PATCHSETv5]
  http://lkml.kernel.org/r/cover.1388952061.git.ydroneaud@opteya.com

[PATCHSETv4]
  http://lkml.kernel.org/r/cover.1383121137.git.ydroneaud@opteya.com

[PATCHSETv3]
  http://lkml.kernel.org/r/cover.1378460926.git.ydroneaud@opteya.com

[PATCHSETv2]
  http://lkml.kernel.org/r/cover.1376327678.git.ydroneaud@opteya.com

[PATCHSETv1]
  http://lkml.kernel.org/r/cover.1372777600.git.ydroneaud@opteya.com

Yann Droneaud (6):
  ia64: use get_unused_fd_flags(0) instead of get_unused_fd()
  ppc/cell: use get_unused_fd_flags(0) instead of get_unused_fd()
  binfmt_misc: use get_unused_fd_flags(0) instead of get_unused_fd()
  file: use get_unused_fd_flags(0) instead of get_unused_fd()
  fanotify: enable close-on-exec on events' fd when requested in
    fanotify_init()
  file: remove macro get_unused_fd()

 arch/ia64/kernel/perfmon.c                | 2 +-
 arch/powerpc/platforms/cell/spufs/inode.c | 4 ++--
 fs/binfmt_misc.c                          | 2 +-
 fs/file.c                                 | 2 +-
 fs/notify/fanotify/fanotify_user.c        | 2 +-
 include/linux/file.h                      | 1 -
 6 files changed, 6 insertions(+), 7 deletions(-)

-- 
1.9.3

