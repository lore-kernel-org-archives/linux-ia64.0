From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Sat, 02 Feb 2019 15:34:42 +0000
Subject: [PATCH net-next v5 00/12] net: y2038-safe socket timestamps
Message-Id: <20190202153454.7121-1-deepa.kernel@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org, arnd@arndb.de, y2038@lists.linaro.org, ccaulfie@redhat.com, chris@zankel.net, cluster-devel@redhat.com, deller@gmx.de, dhowells@redhat.com, fenghua.yu@intel.com, isdn@linux-pingi.de, jejb@parisc-linux.org, linux-afs@lists.infradead.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-xtensa@linux-xtensa.org, paulus@samba.org, ralf@linux-mips.org, rth@twiddle.net, schwidefsky@de.ibm.com, sparclinux@vger.kernel.org, tglx@linutronix.de, ubraun@linux.ibm.com

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

The overview of the socket timestamp series is as below:
1. Delete asm specific socket.h when possible.
2. Support SO/SCM_TIMESTAMP* options only in userspace.
3. Rename current SO/SCM_TIMESTAMP* to SO/SCM_TIMESTAMP*_OLD.
3. Alter socket options so that SOCK_RCVTSTAMPNS does
   not rely on SOCK_RCVTSTAMP.
4. Introduce y2038 safe types for socket timestamp.
5. Introduce new y2038 safe socket options SO/SCM_TIMESTAMP*_NEW.
6. Intorduce new y2038 safe socket timeout options.

Changes since v4:
* Fixed the typo in calling sock_get_timeout()

Changes since v3:
* Rebased onto net-next and fixups as per review comments
* Merged the socket timeout series
* Integrated Arnd's patch to simplify compat handling of timeout syscalls

Changes since v2:
* Removed extra functions to reduce diff churn as per code review

Changes since v1:
* Dropped the change to disentangle sock flags
* Renamed sock_timeval to __kernel_sock_timeval
* Updated a few comments
* Added documentation changes

Arnd Bergmann (1):
  socket: move compat timeout handling into sock.c

Deepa Dinamani (11):
  selftests: add missing include unistd
  arch: Use asm-generic/socket.h when possible
  sockopt: Rename SO_TIMESTAMP* to SO_TIMESTAMP*_OLD
  arch: sparc: Override struct __kernel_old_timeval
  socket: Use old_timeval types for socket timestamps
  socket: Add struct __kernel_sock_timeval
  socket: Add SO_TIMESTAMP[NS]_NEW
  socket: Add SO_TIMESTAMPING_NEW
  socket: Update timestamping Documentation
  socket: Rename SO_RCVTIMEO/ SO_SNDTIMEO with _OLD suffixes
  sock: Add SO_RCVTIMEO_NEW and SO_SNDTIMEO_NEW

 Documentation/networking/timestamping.txt     |  43 ++++-
 arch/alpha/include/uapi/asm/socket.h          |  47 ++++--
 arch/ia64/include/uapi/asm/Kbuild             |   1 +
 arch/ia64/include/uapi/asm/socket.h           | 122 --------------
 arch/mips/include/uapi/asm/socket.h           |  47 ++++--
 arch/parisc/include/uapi/asm/socket.h         |  46 ++++--
 arch/powerpc/include/uapi/asm/socket.h        |   4 +-
 arch/s390/include/uapi/asm/Kbuild             |   1 +
 arch/s390/include/uapi/asm/socket.h           | 119 --------------
 arch/sparc/include/uapi/asm/posix_types.h     |  10 ++
 arch/sparc/include/uapi/asm/socket.h          |  49 ++++--
 arch/x86/include/uapi/asm/Kbuild              |   1 +
 arch/x86/include/uapi/asm/socket.h            |   1 -
 arch/xtensa/include/asm/Kbuild                |   1 +
 arch/xtensa/include/uapi/asm/Kbuild           |   1 +
 arch/xtensa/include/uapi/asm/socket.h         | 124 --------------
 drivers/isdn/mISDN/socket.c                   |   2 +-
 fs/dlm/lowcomms.c                             |   4 +-
 include/linux/skbuff.h                        |  24 ++-
 include/linux/socket.h                        |   8 +
 include/net/sock.h                            |   1 +
 include/uapi/asm-generic/socket.h             |  48 ++++--
 include/uapi/linux/errqueue.h                 |   4 +
 include/uapi/linux/time.h                     |   7 +
 net/bluetooth/hci_sock.c                      |   4 +-
 net/compat.c                                  |  78 +--------
 net/core/scm.c                                |  27 ++++
 net/core/sock.c                               | 151 +++++++++++++-----
 net/ipv4/tcp.c                                |  61 ++++---
 net/rds/af_rds.c                              |  10 +-
 net/rds/recv.c                                |  18 ++-
 net/rxrpc/local_object.c                      |   2 +-
 net/smc/af_smc.c                              |   3 +-
 net/socket.c                                  |  50 ++++--
 net/vmw_vsock/af_vsock.c                      |   4 +-
 .../networking/timestamping/rxtimestamp.c     |   1 +
 36 files changed, 541 insertions(+), 583 deletions(-)
 delete mode 100644 arch/ia64/include/uapi/asm/socket.h
 delete mode 100644 arch/s390/include/uapi/asm/socket.h
 delete mode 100644 arch/x86/include/uapi/asm/socket.h
 delete mode 100644 arch/xtensa/include/uapi/asm/socket.h

-- 
2.17.1

Cc: ccaulfie@redhat.com
Cc: chris@zankel.net
Cc: cluster-devel@redhat.com
Cc: davem@davemloft.net
Cc: deller@gmx.de
Cc: dhowells@redhat.com
Cc: fenghua.yu@intel.com
Cc: isdn@linux-pingi.de
Cc: jejb@parisc-linux.org
Cc: linux-afs@lists.infradead.org
Cc: linux-alpha@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-mips@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-s390@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: netdev@vger.kernel.org
Cc: paulus@samba.org
Cc: ralf@linux-mips.org
Cc: rth@twiddle.net
Cc: schwidefsky@de.ibm.com
Cc: sparclinux@vger.kernel.org
Cc: tglx@linutronix.de
Cc: ubraun@linux.ibm.com
