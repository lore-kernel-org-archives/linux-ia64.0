From: Firoz Khan <firoz.khan@linaro.org>
Date: Wed, 02 Jan 2019 15:34:46 +0000
Subject: [PATCH 1/2] ia64: remove nargs from __SYSCALL
Message-Id: <1546442567-20637-2-git-send-email-firoz.khan@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1546442567-20637-1-git-send-email-firoz.khan@linaro.org>
In-Reply-To: <1546442567-20637-1-git-send-email-firoz.khan@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>, Kate Stewart <kstewart@linuxfoundation.org>
Cc: y2038@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, deepa.kernel@gmail.com, marcin.juszkiewicz@linaro.org, firoz.khan@linaro.org

The __SYSCALL macro's arguments are system call number,
system call entry name and number of arguments for the
system call.

Argument- nargs in __SYSCALL(nr, entry, nargs) is neither
calculated nor used anywhere. So it would be better to
keep the implementaion as  __SYSCALL(nr, entry). This will
unifies the implementation with some other architetures
too.

Signed-off-by: Firoz Khan <firoz.khan@linaro.org>
---
 arch/ia64/kernel/entry.S                | 2 +-
 arch/ia64/kernel/syscalls/syscalltbl.sh | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index a9992be..204b56d 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1426,7 +1426,7 @@ END(ftrace_stub)
 
 #endif /* CONFIG_FUNCTION_TRACER */
 
-#define __SYSCALL(nr, entry, nargs) data8 entry
+#define __SYSCALL(nr, entry)	data8 entry
 	.rodata
 	.align 8
 	.globl sys_call_table
diff --git a/arch/ia64/kernel/syscalls/syscalltbl.sh b/arch/ia64/kernel/syscalls/syscalltbl.sh
index 85d78d9..904b8e6 100644
--- a/arch/ia64/kernel/syscalls/syscalltbl.sh
+++ b/arch/ia64/kernel/syscalls/syscalltbl.sh
@@ -13,10 +13,10 @@ emit() {
 	t_entry="$3"
 
 	while [ $t_nxt -lt $t_nr ]; do
-		printf "__SYSCALL(%s, sys_ni_syscall, )\n" "${t_nxt}"
+		printf "__SYSCALL(%s,sys_ni_syscall)\n" "${t_nxt}"
 		t_nxt=$((t_nxt+1))
 	done
-	printf "__SYSCALL(%s, %s, )\n" "${t_nxt}" "${t_entry}"
+	printf "__SYSCALL(%s,%s)\n" "${t_nxt}" "${t_entry}"
 }
 
 grep -E "^[0-9A-Fa-fXx]+[[:space:]]+${my_abis}" "$in" | sort -n | (
-- 
1.9.1
