From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 29 Jul 2016 17:28:46 +0000
Subject: Re: [RFC v3 05/13] sections.h: add sections header to collect all section info
Message-Id: <20160729132846.00c154c4@gandalf.local.home>
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

On Fri, 22 Jul 2016 22:37:16 +0100
James Hogan <james.hogan@imgtec.com> wrote:


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

One of my TODOs is to simplify that process. That is, to get rid of the
having to add it to all archs and get rid of the Kbuild file altogether.

-- Steve
