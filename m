From: Al Viro <viro@zeniv.linux.org.uk>
Date: Tue, 28 Feb 2023 17:34:52 +0000
Subject: Re: [PATCH 08/10] parisc: fix livelock in uaccess
Message-Id: <Y/47PMmpLDX5lPWx@ZenIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV>
 <Y9l0w4M91DwYLO3N@ZenIV>
 <84b1c2e4-c096-ed19-9701-472b54a4890c@gmx.de>
In-Reply-To: <84b1c2e4-c096-ed19-9701-472b54a4890c@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Helge Deller <deller@gmx.de>
Cc: linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Feb 06, 2023 at 05:58:02PM +0100, Helge Deller wrote:
> Hi Al,
> 
> On 1/31/23 21:06, Al Viro wrote:
> > parisc equivalent of 26178ec11ef3 "x86: mm: consolidate VM_FAULT_RETRY handling"
> > If e.g. get_user() triggers a page fault and a fatal signal is caught, we might
> > end up with handle_mm_fault() returning VM_FAULT_RETRY and not doing anything
> > to page tables.  In such case we must *not* return to the faulting insn -
> > that would repeat the entire thing without making any progress; what we need
> > instead is to treat that as failed (user) memory access.
> > 
> > Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> > ---
> >   arch/parisc/mm/fault.c | 5 ++++-
> >   1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
> > index 869204e97ec9..bb30ff6a3e19 100644
> > --- a/arch/parisc/mm/fault.c
> > +++ b/arch/parisc/mm/fault.c
> > @@ -308,8 +308,11 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
> > 
> >   	fault = handle_mm_fault(vma, address, flags, regs);
> > 
> > -	if (fault_signal_pending(fault, regs))
> > +	if (fault_signal_pending(fault, regs)) {
> > +		if (!user_mode(regs))
> > +			goto no_context;
> >   		return;
> > +	}
> 
> The testcase in
>   https://lore.kernel.org/lkml/20170822102527.GA14671@leverpostej/
>   https://lore.kernel.org/linux-arch/20210121123140.GD48431@C02TD0UTHF1T.local/
> does hang with and without above patch on parisc.
> It does not consume CPU in that state and can be killed with ^C.
> 
> Any idea?

	Still trying to resurrect the parisc box to test on it...
FWIW, right now I've locally confirmed that mainline has the bug
in question and that patch fixes it for alpha, sparc32 and sparc64;
hexagon, m68k and riscv got acks from other folks; microblaze,
nios2 and openrisc I can't test at all (no hardware, no qemu setup);
same for parisc64.  Itanic and parisc32 I might be able to test,
if I manage to resurrect the hardware.

	Just to confirm: your "can be killed with ^C" had been on the
mainline parisc kernel (with userfaultfd enable, of course, or it wouldn't
hang up at all), right?  Was it 32bit or 64bit kernel?
