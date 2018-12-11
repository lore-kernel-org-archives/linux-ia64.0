From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Tue, 11 Dec 2018 20:25:12 +0000
Subject: [PATCH v2 0/8] net: y2038-safe socket timestamps
Message-Id: <20181211202520.16799-1-deepa.kernel@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org, arnd@arndb.de, y2038@lists.linaro.org, chris@zankel.net, deller@gmx.de, dhowells@redhat.com, fenghua.yu@intel.com, isdn@linux-pingi.de, jejb@parisc-linux.org, ralf@linux-mips.org, rth@twiddle.net, schwidefsky@de.ibm.com, tglx@linutronix.de, ubraun@linux.ibm.com, linux-afs@lists.infradead.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-xtensa@linux-xtensa.org, sparclinux@vger.kernel.org

The series introduces new socket timestamps that are
y2038 safe.

The time data types used for the existing socket timestamp
options: SO_TIMESTAMP, SO_TIMESTAMPNS and SO_TIMESTAMPING
are not y2038 safe. The series introduces SO_TIMESTAMP_NEW,
SO_TIMESTAMPNS_NEW and SO_TIMESTAMPING_NEW to replace these.
These new timestamps can be used on all architectures.

The alternative considered was to extend the sys_setsockopt()
by using the flags. We did not receive any strong opinions about
either of the approaches. Hence, this was chosen, as glibc folks
preferred this.

The series does not deal with updating the internal kernel socket
calls like rxrpc to make them y2038 safe. This will be dealt
with separately.

Note that the timestamps behavior already does not match the
man page specific behavior:
SIOCGSTAMP
    This ioctl should only be used if the socket option SO_TIMESTAMP
	is not set on the socket. Otherwise, it returns the timestamp of
	the last packet that was received while SO_TIMESTAMP was not set,
	or it fails if no such packet has been received,
	(i.e., ioctl(2) returns -1 with errno set to ENOENT).
	
The recommendation is to update the man page to remove the above statement.

The overview of the series is as below:
1. Delete asm specific socket.h when possible.
2. Support SO/SCM_TIMESTAMP* options only in userspace.
3. Rename current SO/SCM_TIMESTAMP* to SO/SCM_TIMESTAMP*_OLD.
3. Alter socket options so that SOCK_RCVTSTAMPNS does
   not rely on SOCK_RCVTSTAMP.
4. Introduce y2038 safe types for socket timestamp.
5. Introduce new y2038 safe socket options SO/SCM_TIMESTAMP*_NEW.

Changes since v1:
* Dropped the change to disentangle sock flags
* Renamed sock_timeval to __kernel_sock_timeval
* Updated a few comments
* Added documentation changes

Deepa Dinamani (8):
  arch: Use asm-generic/socket.h when possible
  sockopt: Rename SO_TIMESTAMP* to SO_TIMESTAMP*_OLD
  arch: sparc: Override struct __kernel_old_timeval
  socket: Use old_timeval types for socket timestamps
  socket: Add struct __kernel_sock_timeval
  socket: Add SO_TIMESTAMP[NS]_NEW
  socket: Add SO_TIMESTAMPING_NEW
  socket: Update timestamping Documentation

 Documentation/networking/timestamping.txt |  43 ++++++-
 arch/alpha/include/uapi/asm/socket.h      |  35 ++++--
 arch/ia64/include/uapi/asm/Kbuild         |   1 +
 arch/ia64/include/uapi/asm/socket.h       | 120 -------------------
 arch/mips/include/uapi/asm/socket.h       |  34 ++++--
 arch/parisc/include/uapi/asm/socket.h     |  34 ++++--
 arch/s390/include/uapi/asm/Kbuild         |   1 +
 arch/s390/include/uapi/asm/socket.h       | 117 ------------------
 arch/sparc/include/uapi/asm/posix_types.h |  10 ++
 arch/sparc/include/uapi/asm/socket.h      |  36 ++++--
 arch/x86/include/uapi/asm/Kbuild          |   1 +
 arch/x86/include/uapi/asm/socket.h        |   1 -
 arch/xtensa/include/asm/Kbuild            |   1 +
 arch/xtensa/include/uapi/asm/Kbuild       |   1 +
 arch/xtensa/include/uapi/asm/socket.h     | 122 -------------------
 drivers/isdn/mISDN/socket.c               |   2 +-
 include/linux/skbuff.h                    |  24 +++-
 include/linux/socket.h                    |   7 ++
 include/net/sock.h                        |   1 +
 include/uapi/asm-generic/socket.h         |  35 ++++--
 include/uapi/linux/errqueue.h             |   4 +
 include/uapi/linux/time.h                 |   7 ++
 net/bluetooth/hci_sock.c                  |   4 +-
 net/compat.c                              |  12 +-
 net/core/scm.c                            |  27 +++++
 net/core/sock.c                           | 138 ++++++++++++++--------
 net/ipv4/tcp.c                            |  82 ++++++++-----
 net/rds/af_rds.c                          |  10 +-
 net/rds/recv.c                            |  18 ++-
 net/rxrpc/local_object.c                  |   2 +-
 net/smc/af_smc.c                          |   3 +-
 net/socket.c                              |  64 +++++++---
 32 files changed, 478 insertions(+), 519 deletions(-)
 delete mode 100644 arch/ia64/include/uapi/asm/socket.h
 delete mode 100644 arch/s390/include/uapi/asm/socket.h
 delete mode 100644 arch/x86/include/uapi/asm/socket.h
 delete mode 100644 arch/xtensa/include/uapi/asm/socket.h


base-commit: b124b524bc97868cc2b5656e6ffa21a9b752b7e0
-- 
2.17.1

Cc: chris@zankel.net
Cc: deller@gmx.de
Cc: dhowells@redhat.com
Cc: fenghua.yu@intel.com
Cc: isdn@linux-pingi.de
Cc: jejb@parisc-linux.org
Cc: ralf@linux-mips.org
Cc: rth@twiddle.net
Cc: schwidefsky@de.ibm.com
Cc: tglx@linutronix.de
Cc: ubraun@linux.ibm.com

Cc: linux-afs@lists.infradead.org
Cc: linux-alpha@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-parisc@vger.kernel.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-s390@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: netdev@vger.kernel.org
Cc: sparclinux@vger.kernel.org
