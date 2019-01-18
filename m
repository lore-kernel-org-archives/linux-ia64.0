From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 18 Jan 2019 16:18:09 +0000
Subject: [PATCH v2 03/29] ia64: assign syscall numbers for perf and seccomp
Message-Id: <20190118161835.2259170-4-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190118161835.2259170-1-arnd@arndb.de>
In-Reply-To: <20190118161835.2259170-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: y2038@lists.linaro.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, jcmvbkbc@gmail.com, deepa.kernel@gmail.com, hpa@zytor.com, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, mpe@ellerman.id.au, deller@gmx.de, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, geert@linux-m68k.org, benh@kernel.crashing.org, firoz.khan@linaro.org, mattst88@gmail.com, fenghua.yu@intel.com, Arnd Bergmann <arnd@arndb.de>, heiko.carstens@de.ibm.com, linux-fsdevel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, luto@kernel.org, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, monstr@monstr.eu, tony.luck@intel.com, linux-parisc@vger.kernel.org, netdev@vger.kernel.org, linux-mips@vger.kernel.org, paul.burton@mips.com, ebiederm@xmission.com, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, akpm@linux-foundation.orglinu

Most architectures have assigned numbers for both seccomp and
perf_event_open, even when they do not implement either.

ia64 is an exception here, so for consistency lets add numbers for both
of them. Unless CONFIG_PERF_EVENTS and CONFIG_SECCOMP are implemented,
the system calls just return -ENOSYS.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/kernel/syscalls/syscall.tbl | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/ia64/kernel/syscalls/syscall.tbl b/arch/ia64/kernel/syscalls/syscall.tbl
index 52585281205b..2e93dbdcdb80 100644
--- a/arch/ia64/kernel/syscalls/syscall.tbl
+++ b/arch/ia64/kernel/syscalls/syscall.tbl
@@ -337,3 +337,5 @@
 325	common	pwritev2			sys_pwritev2
 326	common	statx				sys_statx
 327	common	io_pgetevents			sys_io_pgetevents
+328	common	perf_event_open			sys_perf_event_open
+329	common	seccomp				sys_seccomp
-- 
2.20.0
