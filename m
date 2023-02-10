From: Brian Cain <bcain@quicinc.com>
Date: Fri, 10 Feb 2023 02:59:41 +0000
Subject: RE: [PATCH 02/10] hexagon: fix livelock in uaccess
Message-Id: <SN6PR02MB4205D40B41246B41EA8FD069B8DE9@SN6PR02MB4205.namprd02.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV> <Y9l0LyAA3zAGeT51@ZenIV>
In-Reply-To: <Y9l0LyAA3zAGeT51@ZenIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@zeniv.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>
Cc: "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

> -----Original Message-----
> From: Al Viro <viro@ftp.linux.org.uk> On Behalf Of Al Viro
> Sent: Tuesday, January 31, 2023 2:04 PM
> To: linux-arch@vger.kernel.org
> Cc: linux-alpha@vger.kernel.org; linux-ia64@vger.kernel.org; linux-
> hexagon@vger.kernel.org; linux-m68k@lists.linux-m68k.org; Michal Simek
> <monstr@monstr.eu>; Dinh Nguyen <dinguyen@kernel.org>;
> openrisc@lists.librecores.org; linux-parisc@vger.kernel.org; linux-
> riscv@lists.infradead.org; sparclinux@vger.kernel.org; Linus Torvalds
> <torvalds@linux-foundation.org>
> Subject: [PATCH 02/10] hexagon: fix livelock in uaccess
> 
> WARNING: This email originated from outside of Qualcomm. Please be wary of
> any links or attachments, and do not enable macros.
> 
> hexagon equivalent of 26178ec11ef3 "x86: mm: consolidate
> VM_FAULT_RETRY handling"
> If e.g. get_user() triggers a page fault and a fatal signal is caught, we might
> end up with handle_mm_fault() returning VM_FAULT_RETRY and not doing
> anything
> to page tables.  In such case we must *not* return to the faulting insn -
> that would repeat the entire thing without making any progress; what we
> need
> instead is to treat that as failed (user) memory access.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  arch/hexagon/mm/vm_fault.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
> index f73c7cbfe326..4b578d02fd01 100644
> --- a/arch/hexagon/mm/vm_fault.c
> +++ b/arch/hexagon/mm/vm_fault.c
> @@ -93,8 +93,11 @@ void do_page_fault(unsigned long address, long cause,
> struct pt_regs *regs)
> 
>         fault = handle_mm_fault(vma, address, flags, regs);
> 
> -       if (fault_signal_pending(fault, regs))
> +       if (fault_signal_pending(fault, regs)) {
> +               if (!user_mode(regs))
> +                       goto no_context;
>                 return;
> +       }
> 
>         /* The fault is fully completed (including releasing mmap lock) */
>         if (fault & VM_FAULT_COMPLETED)
> --
> 2.30.2

Acked-by: Brian Cain <bcain@quicinc.com>
