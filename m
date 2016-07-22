From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 22 Jul 2016 21:41:59 +0000
Subject: Re: [RFC v3 05/13] sections.h: add sections header to collect all section info
Message-Id: <20160722214159.GK5537@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <1469222687-1600-6-git-send-email-mcgrof@kernel.org>
 <18139776.6i7V2bF6CR@radagast>
In-Reply-To: <18139776.6i7V2bF6CR@radagast>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Hogan <james.hogan@imgtec.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevche

On Fri, Jul 22, 2016 at 10:37:16PM +0100, James Hogan wrote:
> Hi Luis,
> 
> On Friday 22 July 2016 14:24:39 Luis R. Rodriguez wrote:
> >  arch/alpha/include/asm/sections.h     |   6 +
> >  arch/arm64/include/asm/sections.h     |   6 +
> >  arch/avr32/include/asm/sections.h     |   6 +
> >  arch/cris/include/asm/sections.h      |   6 +
> >  arch/h8300/include/asm/sections.h     |   6 +
> >  arch/hexagon/include/asm/sections.h   |   6 +
> >  arch/m32r/include/asm/sections.h      |   6 +
> >  arch/m68k/include/asm/sections.h      |   6 +
> >  arch/metag/include/asm/sections.h     |   6 +
> >  arch/mips/include/asm/sections.h      |   6 +
> >  arch/mn10300/include/asm/sections.h   |   6 +
> >  arch/nios2/include/asm/sections.h     |   6 +
> >  arch/openrisc/include/asm/sections.h  |   6 +
> >  arch/score/include/asm/sections.h     |   6 +
> >  arch/unicore32/include/asm/sections.h |   6 +
> >  arch/xtensa/include/asm/sections.h    |   6 +
> 
> > diff --git a/arch/alpha/include/asm/sections.h b/arch/alpha/include/asm/sections.h
> > new file mode 100644
> > index 000000000000..e58fc679fe15
> > --- /dev/null
> > +++ b/arch/alpha/include/asm/sections.h
> > @@ -0,0 +1,6 @@
> > +#ifndef _ASM_ALPHA_SECTIONS_H
> > +#define _ASM_ALPHA_SECTIONS_H
> > +
> > +#include <asm-generic/sections.h>
> > +
> > +#endif /* _ASM_ALPHA_SECTIONS_H */
> 
> Any particular reason not to use generic-y in the Kbuild files for
> sections.h, ranges.h, and tables.h?

I was just not aware of that, thanks, will do this in the next iteration!

  Luis
