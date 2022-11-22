From: Nadav Amit <nadav.amit@gmail.com>
Date: Tue, 22 Nov 2022 19:53:29 +0000
Subject: [PATCH 3/3] compiler: inline does not imply notrace
Message-Id: <20221122195329.252654-4-namit@vmware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221122195329.252654-1-namit@vmware.com>
In-Reply-To: <20221122195329.252654-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-um@lists.infradead.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Nadav Amit <namit@vmware.com>

From: Nadav Amit <namit@vmware.com>

Functions that are marked as "inline" are currently also not tracable.
Apparently, this has been done to prevent differences between different
configs that caused different functions to be tracable on different
platforms.

Anyhow, this consideration is not very strong, and tying "inline" and
"notrace" does not seem very beneficial. The "inline" keyword is just a
hint, and many functions are currently not tracable due to this reason.

Disconnect "inline" from "notrace".

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 include/linux/compiler_types.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/compiler_types.h b/include/linux/compiler_types.h
index eb0466236661..36a99ef03a1a 100644
--- a/include/linux/compiler_types.h
+++ b/include/linux/compiler_types.h
@@ -158,7 +158,7 @@ struct ftrace_likely_data {
  * of extern inline functions at link time.
  * A lot of inline functions can cause havoc with function tracing.
  */
-#define inline inline __gnu_inline __inline_maybe_unused notrace
+#define inline inline __gnu_inline __inline_maybe_unused
 
 /*
  * gcc provides both __inline__ and __inline as alternate spellings of
-- 
2.25.1
