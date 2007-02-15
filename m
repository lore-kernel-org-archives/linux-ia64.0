From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 15 Feb 2007 13:17:00 +0000
Subject: Re: fault-injection framework on ia64
Message-Id: <20070215051700.5827fa43.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
In-Reply-To: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 15 Feb 2007 21:44:34 +0900 "Akinobu Mita" <akinobu.mita@gmail.com> wrote:

> 2007/2/15, Andrew Morton <akpm@linux-foundation.org>:
> >
> > lib/built-in.o(.text+0x2c192): In function `should_fail':
> > : undefined reference to `save_stack_trace'
> >
> > We could disable the feature on ia64, but then they wouldn't be able to
> > inject faults.
> 
> I couldn't understand this build error happend.
> (I might misunderstand something)
> Because IA64 config always disable CONFIG_STACKTRACE, so
> should_fail() doesn't use save_stack_trace() in fail_stacktrace().

OK.  Maybe this patch broke things:


From: "Paolo 'Blaisorblade' Giarrusso" <blaisorblade@yahoo.it>

There is no prompt for STACKTRACE, so it is enabled only when 'select'ed. 
FAULT_INJECTION depends on it, while LOCKDEP selects it.  So
FAULT_INJECTION becomes visible in Kconfig only when LOCKDEP is enabled.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Cc: <stable@kernel.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 lib/Kconfig.debug |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN lib/Kconfig.debug~kconfig-fault_injection-can-be-selected-only-if-lockdep-is-enabled lib/Kconfig.debug
--- a/lib/Kconfig.debug~kconfig-fault_injection-can-be-selected-only-if-lockdep-is-enabled
+++ a/lib/Kconfig.debug
@@ -400,7 +400,7 @@ config LKDTM
 config FAULT_INJECTION
 	bool "Fault-injection framework"
 	depends on DEBUG_KERNEL
-	depends on STACKTRACE
+	select STACKTRACE
 	select FRAME_POINTER
 	help
 	  Provide fault-injection framework.
_


