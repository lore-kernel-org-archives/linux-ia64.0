From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 10 Jan 2019 16:24:24 +0000
Subject: [PATCH 04/15] alpha: wire up io_pgetevents system call
Message-Id: <20190110162435.309262-5-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190110162435.309262-1-arnd@arndb.de>
In-Reply-To: <20190110162435.309262-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: y2038@lists.linaro.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, geert@linux-m68k.org, monstr@monstr.eu, paul.burton@mips.com, deller@gmx.de, mpe@ellerman.id.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, dalias@libc.org, davem@davemloft.net, luto@kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, jcmvbkbc@gmail.com, firoz.khan@linaro.org, ebiederm@xmission.com, deepa.kernel@gmail.com, linux@dominikbrodowski.net, akpm@linux-foundation.org, dave@stgolabs.net, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-paris

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
