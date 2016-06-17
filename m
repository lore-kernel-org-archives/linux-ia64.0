From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 17 Jun 2016 14:48:17 +0000
Subject: [PATCH] ia64: efi: use timespec64 for persistent clock
Message-Id: <20160617144920.3511152-1-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: y2038@lists.linaro.org, Arnd Bergmann <arnd@arndb.de>, Matt Fleming <matt@codeblueprint.co.uk>, Ingo Molnar <mingo@kernel.org>, Toshi Kani <toshi.kani@hpe.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

We have a generic read_persistent_clock64 interface now, and can
change the ia64 implementation to provide that instead of
read_persistent_clock.

The main point of this is to avoid the use of struct timespec
in the global efi.h, which would cause build errors as soon
as we want to build a kernel without 'struct timespec' defined
on 32-bit architectures.

Aside from this, we get a little closer to removing the
__weak read_persistent_clock() definition, which relies on
converting all architectures to provide read_persistent_clock64
instead.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/kernel/efi.c  | 4 ++--
 arch/ia64/kernel/time.c | 2 +-
 include/linux/efi.h     | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 3b7a60e40e8a..121295637d0d 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -236,7 +236,7 @@ STUB_GET_NEXT_HIGH_MONO_COUNT(virt, id)
 STUB_RESET_SYSTEM(virt, id)
 
 void
-efi_gettimeofday (struct timespec *ts)
+efi_gettimeofday (struct timespec64 *ts)
 {
 	efi_time_t tm;
 
@@ -245,7 +245,7 @@ efi_gettimeofday (struct timespec *ts)
 		return;
 	}
 
-	ts->tv_sec = mktime(tm.year, tm.month, tm.day,
+	ts->tv_sec = mktime64(tm.year, tm.month, tm.day,
 			    tm.hour, tm.minute, tm.second);
 	ts->tv_nsec = tm.nanosecond;
 }
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index c8dbe2acd735..6f892b94e906 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -355,7 +355,7 @@ static struct irqaction timer_irqaction = {
 	.name =		"timer"
 };
 
-void read_persistent_clock(struct timespec *ts)
+void read_persistent_clock64(struct timespec64 *ts)
 {
 	efi_gettimeofday(ts);
 }
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 9a53a557acff..dca8810d6b49 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -937,7 +937,7 @@ extern void efi_init (void);
 extern void *efi_get_pal_addr (void);
 extern void efi_map_pal_code (void);
 extern void efi_memmap_walk (efi_freemem_callback_t callback, void *arg);
-extern void efi_gettimeofday (struct timespec *ts);
+extern void efi_gettimeofday (struct timespec64 *ts);
 extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual mode, if possible */
 #ifdef CONFIG_X86
 extern void efi_late_init(void);
-- 
2.9.0

