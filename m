From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 31 Dec 2015 19:09:47 +0000
Subject: [PATCH v2 31/32] sh: support a 2-byte smp_store_mb
Message-Id: <1451572003-2440-32-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-1-git-send-email-mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

At the moment, xchg on sh only supports 4 and 1 byte values, so using it
from smp_store_mb means attempts to store a 2 byte value using this
macro fail.

And happens to be exactly what virtio drivers want to do.

Check size and fall back to a slower, but safe, WRITE_ONCE+smp_mb.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 arch/sh/include/asm/barrier.h | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/arch/sh/include/asm/barrier.h b/arch/sh/include/asm/barrier.h
index f887c64..0cc5735 100644
--- a/arch/sh/include/asm/barrier.h
+++ b/arch/sh/include/asm/barrier.h
@@ -32,7 +32,15 @@
 #define ctrl_barrier()	__asm__ __volatile__ ("nop;nop;nop;nop;nop;nop;nop;nop")
 #endif
 
-#define __smp_store_mb(var, value) do { (void)xchg(&var, value); } while (0)
+#define __smp_store_mb(var, value) do { \
+	if (sizeof(var) != 4 && sizeof(var) != 1) { \
+		 WRITE_ONCE(var, value); \
+		__smp_mb(); \
+	} else { \
+		(void)xchg(&var, value);  \
+	} \
+} while (0)
+
 #define smp_store_mb(var, value) __smp_store_mb(var, value)
 
 #include <asm-generic/barrier.h>
-- 
MST

