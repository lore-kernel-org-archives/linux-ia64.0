From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 18 Jan 2019 16:18:08 +0000
Subject: [PATCH v2 02/29] ia64: add statx and io_pgetevents syscalls
Message-Id: <20190118161835.2259170-3-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190118161835.2259170-1-arnd@arndb.de>
In-Reply-To: <20190118161835.2259170-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: y2038@lists.linaro.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, jcmvbkbc@gmail.com, deepa.kernel@gmail.com, hpa@zytor.com, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, mpe@ellerman.id.au, deller@gmx.de, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, geert@linux-m68k.org, benh@kernel.crashing.org, firoz.khan@linaro.org, mattst88@gmail.com, fenghua.yu@intel.com, Arnd Bergmann <arnd@arndb.de>, heiko.carstens@de.ibm.com, linux-fsdevel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, luto@kernel.org, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, monstr@monstr.eu, tony.luck@intel.com, linux-parisc@vger.kernel.org, netdev@vger.kernel.org, linux-mips@vger.kernel.org, paul.burton@mips.com, ebiederm@xmission.com, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, akpm@linux-foundation.orglinu

All architectures should implement these two, so assign numbers
and hook them up on ia64.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/kernel/syscalls/syscall.tbl | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/ia64/kernel/syscalls/syscall.tbl b/arch/ia64/kernel/syscalls/syscall.tbl
index e97caf51be42..52585281205b 100644
--- a/arch/ia64/kernel/syscalls/syscall.tbl
+++ b/arch/ia64/kernel/syscalls/syscall.tbl
@@ -335,3 +335,5 @@
 323	common	copy_file_range			sys_copy_file_range
 324	common	preadv2				sys_preadv2
 325	common	pwritev2			sys_pwritev2
+326	common	statx				sys_statx
+327	common	io_pgetevents			sys_io_pgetevents
-- 
2.20.0
