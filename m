From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 20 Jan 2005 16:42:31 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <200501200842.32771.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, January 20, 2005 5:43 am, Hugo Kohmann wrote:
> X86 and X86_64 kernels rely on MTRR to enable writecombining. X86 and
> X86_64 systems supports WriteCombining using the PAT bit in the PTE, but
> this is not yet supported by Linux kernels. ( There are no PAGE_PAT bit
> defiend and the PAT MSR power on value does not include support for the WC
> attribute.) After changing the PAT MSR to enable WC, I can do:
>
> #define _PAGE_PAT  0x80 /* for AMD64 and X86 */
>   pgprot_val(vma->vm_page_prot) = pgprot_val(vma->vm_page_prot) |= 
> _PAGE_PAT;
>
> to set up a user space write combine map ( using mmmap())
>
> and
>
> __ioremap(ioaddr, size, _PAGE_PAT);
>
> To set up a kernel space write combine map.
>
> I can send the code to change the PAT MSR if anybody needs it - but I
> guess this is the wrong interest group (As this only works for
> x86/x86_64)

Yeah, I think this is the wrong list for that, but it definitely sounds 
useful.  You should send the code to Andi Kleen and see if he's interested in 
adding support for WC in the x86-64 codebase.

Jesse
