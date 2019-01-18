From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 18 Jan 2019 16:18:10 +0000
Subject: [PATCH v2 04/29] alpha: wire up io_pgetevents system call
Message-Id: <20190118161835.2259170-5-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190118161835.2259170-1-arnd@arndb.de>
In-Reply-To: <20190118161835.2259170-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: y2038@lists.linaro.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, jcmvbkbc@gmail.com, deepa.kernel@gmail.com, hpa@zytor.com, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, mpe@ellerman.id.au, deller@gmx.de, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, geert@linux-m68k.org, benh@kernel.crashing.org, firoz.khan@linaro.org, mattst88@gmail.com, fenghua.yu@intel.com, Arnd Bergmann <arnd@arndb.de>, heiko.carstens@de.ibm.com, linux-fsdevel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, luto@kernel.org, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, monstr@monstr.eu, tony.luck@intel.com, linux-parisc@vger.kernel.org, netdev@vger.kernel.org, linux-mips@vger.kernel.org, stable@vger.kernel.org, paul.burton@mips.com, ebiederm@xmission.com, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, akpm@li

The io_pgetevents system call was added in linux-4.18 but has
no entry for alpha:

warning: #warning syscall io_pgetevents not implemented [-Wcpp]

Assign a the next system call number here.

Cc: stable@vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/alpha/kernel/syscalls/syscall.tbl | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/alpha/kernel/syscalls/syscall.tbl b/arch/alpha/kernel/syscalls/syscall.tbl
index 7b56a53be5e3..e09558edae73 100644
--- a/arch/alpha/kernel/syscalls/syscall.tbl
+++ b/arch/alpha/kernel/syscalls/syscall.tbl
@@ -451,3 +451,4 @@
 520	common	preadv2				sys_preadv2
 521	common	pwritev2			sys_pwritev2
 522	common	statx				sys_statx
+523	common	io_pgetevents			sys_io_pgetevents
-- 
2.20.0
