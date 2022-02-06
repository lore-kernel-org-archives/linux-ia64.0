From: Walt Drummond <walt@drummond.us>
Date: Sun, 06 Feb 2022 15:48:51 +0000
Subject: [PATCH v2 0/3] vstatus: TTY status message request
Message-Id: <20220206154856.2355838-1-walt@drummond.us>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: agordeev@linux.ibm.com, arnd@arndb.de, benh@kernel.crashing.org, borntraeger@de.ibm.com, chris@zankel.net, davem@davemloft.net, gregkh@linuxfoundation.org, hca@linux.ibm.com, deller@gmx.de, ink@jurassic.park.msu.ru, James.Bottomley@HansenPartnership.com, jirislaby@kernel.org, mattst88@gmail.com, jcmvbkbc@gmail.com, mpe@ellerman.id.au, paulus@samba.org, rth@twiddle.net, dalias@libc.org, tsbogend@alpha.franken.de, gor@linux.ibm.com, ysato@users.osdn.me
Cc: linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, walt@drummond.us, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, ar@cs.msu.ru, linuxppc-dev@lists.ozlabs.org

This patchset adds TTY status message request feature to the n_tty
line dicipline.  This feature prints a brief message containing basic
system and process group information to a user's TTY in response to a
new control character in the line dicipline (default Ctrl-T) or the
TIOCSTAT ioctl.  The message contains the current system load, the
name and PID of an interesting process in the forground process group,
it's run time, percent CPU usage and RSS.  An example of this message
is:

  load: 0.31  cmd: sleep 3616843 [sleeping] 0.36r 0.00u 0.00s 0% 696k

This feature is in many other Unix systems, both current and
historical.  In other implementations, this feature would also send
SIGINFO to the process group; this implementation does not.

User API visible changes are limited to:
 - The addition of VSTATUS in termios.c_cc[]
 - The addition of NOKERNINFO bit in termios.l_cflags
 - The addition of the TIOCSTAT ioctl number

None of these changes break the existing kernel api as the termios
structure on all architectures has enough space in the control
character array (.c_cc) for the new character.

Walt Drummond (3):
  vstatus: Allow the n_tty line dicipline to write to a user tty
  status: Add user space API definitions for VSTATUS, NOKERNINFO and
    TIOCSTAT
  vstatus: Display an informational message when the VSTATUS character
    is pressed or TIOCSTAT ioctl is called.

 arch/alpha/include/asm/termios.h         |   4 +-
 arch/alpha/include/uapi/asm/ioctls.h     |   1 +
 arch/alpha/include/uapi/asm/termbits.h   |   2 +
 arch/ia64/include/asm/termios.h          |   4 +-
 arch/ia64/include/uapi/asm/termbits.h    |   2 +
 arch/mips/include/asm/termios.h          |   4 +-
 arch/mips/include/uapi/asm/ioctls.h      |   1 +
 arch/mips/include/uapi/asm/termbits.h    |   2 +
 arch/parisc/include/asm/termios.h        |   4 +-
 arch/parisc/include/uapi/asm/ioctls.h    |   1 +
 arch/parisc/include/uapi/asm/termbits.h  |   2 +
 arch/powerpc/include/asm/termios.h       |   4 +-
 arch/powerpc/include/uapi/asm/ioctls.h   |   2 +
 arch/powerpc/include/uapi/asm/termbits.h |   2 +
 arch/s390/include/asm/termios.h          |   4 +-
 arch/sh/include/uapi/asm/ioctls.h        |   1 +
 arch/sparc/include/uapi/asm/ioctls.h     |   1 +
 arch/sparc/include/uapi/asm/termbits.h   |   2 +
 arch/xtensa/include/uapi/asm/ioctls.h    |   1 +
 drivers/tty/Makefile                     |   2 +-
 drivers/tty/n_tty.c                      | 103 +++++++++----
 drivers/tty/n_tty_status.c               | 181 +++++++++++++++++++++++
 drivers/tty/tty_io.c                     |   2 +-
 include/asm-generic/termios.h            |   4 +-
 include/linux/tty.h                      |   7 +-
 include/uapi/asm-generic/ioctls.h        |   1 +
 include/uapi/asm-generic/termbits.h      |   2 +
 27 files changed, 301 insertions(+), 45 deletions(-)
 create mode 100644 drivers/tty/n_tty_status.c

-- 
2.30.2
