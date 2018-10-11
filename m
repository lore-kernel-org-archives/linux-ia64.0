From: Firoz Khan <firoz.khan@linaro.org>
Date: Thu, 11 Oct 2018 04:36:55 +0000
Subject: [PATCH v3 7/7] ia64: wire up system calls
Message-Id: <1539231895-4118-8-git-send-email-firoz.khan@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1539231895-4118-1-git-send-email-firoz.khan@linaro.org>
In-Reply-To: <1539231895-4118-1-git-send-email-firoz.khan@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>
Cc: y2038@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, deepa.kernel@gmail.com, marcin.juszkiewicz@linaro.org, firoz.khan@linaro.org

wire up perf_event_open, seccomp, pkey_mprotect, pkey_alloc,
pkey_free, statx, io_pgetevents and rseq system calls

This require an architecture specific implementation as it not
present now.

Signed-off-by: Firoz Khan <firoz.khan@linaro.org>
---
 arch/ia64/kernel/syscalls/syscall.tbl | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/ia64/kernel/syscalls/syscall.tbl b/arch/ia64/kernel/syscalls/syscall.tbl
index 6b64f60..1f42b60 100644
--- a/arch/ia64/kernel/syscalls/syscall.tbl
+++ b/arch/ia64/kernel/syscalls/syscall.tbl
@@ -335,3 +335,19 @@
 323     common  copy_file_range                 sys_copy_file_range
 324     common  preadv2                         sys_preadv2
 325     common  pwritev2                        sys_pwritev2
+# perf_event_open requires an architecture specific implementation
+326	common	perf_event_open			sys_perf_event_open
+# seccomp requires an architecture specific implementation
+327	common	seccomp				sys_seccomp
+# pkey_mprotect requires an architecture specific implementation
+328	common	pkey_mprotect			sys_pkey_mprotect
+# pkey_alloc requires an architecture specific implementation
+329	common	pkey_alloc			sys_pkey_alloc
+# pkey_free requires an architecture specific implementation
+330	common	pkey_free			sys_pkey_free
+# statx requires an architecture specific implementation
+331	common	statx				sys_statx
+# io_pgetevents requires an architecture specific implementation
+332	common	io_pgetevents			sys_io_pgetevents
+# rseq requires an architecture specific implementation
+333	common	rseq				sys_rseq
-- 
1.9.1
