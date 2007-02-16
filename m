From: Blaisorblade <blaisorblade@yahoo.it>
Date: Fri, 16 Feb 2007 18:38:16 +0000
Subject: Kconfig bug (was: Re: fault-injection framework on ia64)
Message-Id: <200702161938.17340.blaisorblade@yahoo.it>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 16 February 2007 18:30, Akinobu Mita wrote:
> > But if STACKTRACE depends on STACKTRACE_SUPPORT, which isn't defined on
> > ia64, kconfig should disable FAULT_INJECTION altogether with my patch (as
> > it did before it). I don't think that FAULT_INJECTION could be enabled
> > before my patch, right?
> >
> > _BUT_ probably STACKTRACE_SUPPORT should be defined, with default n and
> > no prompt, on ia64, or Kconfig gets confused (it should output a warning,
> > like 'undefined symbol STACKTRACE_SUPPORT'). We on UML used to get
> > warning when INPUT was used but not defined. Hmmm....
>
> Really? I intentionaly removed the STACKTRACE_SUPPORT in x86_64 Kconfig,
> then I did make menuconfig. But I didn't get such warning.
Well, I got that warning, and I don't get it on STACKTRACE_SUPPORT. Strange. 
But it was time ago...

However, more important, if I remove STACKTRACE_SUPPORT, or if I make 
it 'default n', FAULT_INJECTION can still be enabled, even if it selects 
STACKTRACE which has a failed dependency (tested on UML). Which is a Kconfig 
bug - if A selects B and B depends on C, no dependency of A on C is deduced. 
Right Roman?

This Kconfig bug explains how your bug could surface.

This also means that my patch cannot to go -stable because it would cause 
problems on IA64 and any arch without STACKTRACE_SUPPORT.
See if yours can, Akinobu.
-- 
Inform me of my mistakes, so I can add them to my list!
Paolo Giarrusso, aka Blaisorblade
http://www.user-mode-linux.org/~blaisorblade
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 
