From: Blaisorblade <blaisorblade@yahoo.it>
Date: Thu, 15 Feb 2007 19:43:51 +0000
Subject: Re: fault-injection framework on ia64
Message-Id: <200702152043.52259.blaisorblade@yahoo.it>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
In-Reply-To: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 15 February 2007 14:17, Andrew Morton wrote:
> On Thu, 15 Feb 2007 21:44:34 +0900 "Akinobu Mita" <akinobu.mita@gmail.com> 
wrote:
> > 2007/2/15, Andrew Morton <akpm@linux-foundation.org>:
> > > lib/built-in.o(.text+0x2c192): In function `should_fail':
> > > : undefined reference to `save_stack_trace'
> > >
> > > We could disable the feature on ia64, but then they wouldn't be able to
> > > inject faults.
> >
> > I couldn't understand this build error happend.
> > (I might misunderstand something)
> > Because IA64 config always disable CONFIG_STACKTRACE, so
> > should_fail() doesn't use save_stack_trace() in fail_stacktrace().
>
> OK.  Maybe this patch broke things:

But if STACKTRACE depends on STACKTRACE_SUPPORT, which isn't defined on ia64, 
kconfig should disable FAULT_INJECTION altogether with my patch (as it did 
before it). I don't think that FAULT_INJECTION could be enabled before my 
patch, right?

_BUT_ probably STACKTRACE_SUPPORT should be defined, with default n and no 
prompt, on ia64, or Kconfig gets confused (it should output a warning, 
like 'undefined symbol STACKTRACE_SUPPORT'). We on UML used to get warning 
when INPUT was used but not defined. Hmmm....

I'm interested in this because I also sent the patch to -stable, and Akinobu's 
patch would be worse to merge there.

> From: "Paolo 'Blaisorblade' Giarrusso" <blaisorblade@yahoo.it>
>
> There is no prompt for STACKTRACE, so it is enabled only when 'select'ed.
> FAULT_INJECTION depends on it, while LOCKDEP selects it.  So
> FAULT_INJECTION becomes visible in Kconfig only when LOCKDEP is enabled.
>
> Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
> Cc: <stable@kernel.org>
> Cc: Akinobu Mita <akinobu.mita@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  lib/Kconfig.debug |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff -puN
> lib/Kconfig.debug~kconfig-fault_injection-can-be-selected-only-if-lockdep-i
>s-enabled lib/Kconfig.debug ---
> a/lib/Kconfig.debug~kconfig-fault_injection-can-be-selected-only-if-lockdep
>-is-enabled +++ a/lib/Kconfig.debug
> @@ -400,7 +400,7 @@ config LKDTM
>  config FAULT_INJECTION
>  	bool "Fault-injection framework"
>  	depends on DEBUG_KERNEL
> -	depends on STACKTRACE
> +	select STACKTRACE
>  	select FRAME_POINTER
>  	help
>  	  Provide fault-injection framework.
> _

-- 
Inform me of my mistakes, so I can add them to my list!
Paolo Giarrusso, aka Blaisorblade
http://www.user-mode-linux.org/~blaisorblade

Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 
