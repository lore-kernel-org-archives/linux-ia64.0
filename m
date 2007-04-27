From: Daniel Walker <dwalker@mvista.com>
Date: Fri, 27 Apr 2007 15:35:58 +0000
Subject: Re: [PATCH 1/3] ia64: convert to use clocksource code
Message-Id: <1177688158.12796.125.camel@imap.mvista.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
	 <1177621673.12796.121.camel@imap.mvista.com>  <46320ACD.6090704@hp.com>
In-Reply-To: <46320ACD.6090704@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Keilty <peter.keilty@hp.com>
Cc: linux-ia64@vger.kernel.org, John Stultz <johnstul@us.ibm.com>, Eric Whitney <eric.whitney@hp.com>, linux-kernel@vger.kernel.org

On Fri, 2007-04-27 at 10:38 -0400, Peter Keilty wrote:
> Daniel Walker wrote:
> 
> >On Thu, 2007-04-26 at 16:26 -0400, Peter Keilty wrote:
> >
> >  
> >
> >>+        .mask           = (1LL << 40) - 1,
> >>+        .mult           = 0, /*to be caluclated*/
> >>+        .shift          = 16,
> >>+        .is_continuous  = 1,
> >> };
> >>    
> >>
> >
> >You should use CLOCKSOURCE_MASK() here ..
> >
> >  
> >
> It is correct in patch 3, I believe.

There's another spot that should use CLOCKSOURE_MASK() in the hpet I
think .

> >  
> >
> >> 
> >>diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
> >>index daa4940..a20b4d6 100644
> >>--- a/include/linux/clocksource.h
> >>+++ b/include/linux/clocksource.h
> >>@@ -61,6 +61,9 @@ struct clocksource {
> >> 	u32 shift;
> >> 	unsigned long flags;
> >> 	cycle_t (*vread)(void);
> >>+#ifdef CONFIG_IA64
> >>+	void *fsys_mmio_ptr;	/* used by fsyscall asm code */
> >>+#endif
> >>    
> >>
> >
> >Could you explain in detail why this is needed?
> >  
> >
> This ptr is needed to hold the mmio address to read the cycle value.
> The fast ia64 path utilizies a special gate page which can allow user
> code to execute small amount of kernel code, normal calling a function
> not done and so the address is need. The fast syscall path executes on
> user stack, between user/kernel state. And if the the fast path has to 
> fallback
> to the slow syscall code the vread will be needed and used.

There is a read(), and a vread() did you modify the slow syscall path to
use the vread()?

Daniel

