From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Thu, 04 Jun 2009 12:41:59 +0000
Subject: [PATCH 2/6] headers_check fix: ia64, fpswa.h
Message-Id: <1244118599.5172.31.camel@ht.satnam>
List-Id: <linux-ia64.vger.kernel.org>
References: <1244118232.5172.26.camel@ht.satnam>
	 <1244118476.5172.29.camel@ht.satnam>
In-Reply-To: <1244118476.5172.29.camel@ht.satnam>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org


fix the following 'make headers_check' warning:

  usr/include/asm-ia64/fpswa.h:71: extern's make no sense in userspace

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 arch/ia64/include/asm/fpswa.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/fpswa.h b/arch/ia64/include/asm/fpswa.h
index 62edfce..797b064 100644
--- a/arch/ia64/include/asm/fpswa.h
+++ b/arch/ia64/include/asm/fpswa.h
@@ -68,6 +68,7 @@ typedef struct {
 	efi_fpswa_t	 fpswa;
 } fpswa_interface_t;
 
+#ifdef __KERNEL__
 extern fpswa_interface_t *fpswa_interface;
-
+#endif
 #endif /* _ASM_IA64_FPSWA_H */
-- 
1.6.0.6



