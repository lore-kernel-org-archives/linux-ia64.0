From: Hugo Kohmann <hugo@dolphinics.no>
Date: Thu, 20 Jan 2005 13:43:26 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <Pine.LNX.4.61.0501200907540.29432@boss.dolphinics.no>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


FYI:


X86 and X86_64 kernels rely on MTRR to enable writecombining. X86 and 
X86_64 systems supports WriteCombining using the PAT bit in the PTE, but 
this is not yet supported by Linux kernels. ( There are no PAGE_PAT bit 
defiend and the PAT MSR power on value does not include support for the WC 
attribute.) After changing the PAT MSR to enable WC, I can do:

#define _PAGE_PAT  0x80 /* for AMD64 and X86 */
  pgprot_val(vma->vm_page_prot) = pgprot_val(vma->vm_page_prot) |=  _PAGE_PAT;

to set up a user space write combine map ( using mmmap())

and

__ioremap(ioaddr, size, _PAGE_PAT);

To set up a kernel space write combine map.

I can send the code to change the PAT MSR if anybody needs it - but I 
guess this is the wrong interest group (As this only works for 
x86/x86_64)

Best regards

Hugo


On Wed, 19 Jan 2005, David Mosberger wrote:

>Date: Wed, 19 Jan 2005 14:20:21 -0800
>From: David Mosberger <davidm@napali.hpl.hp.com>
>Reply-To: davidm@hpl.hp.com
>To: Jesse Barnes <jbarnes@sgi.com>
>Cc: davidm@hpl.hp.com, Jim Hull <jim.hull@hp.com>, linux-ia64@vger.kernel.org,
>    'Tony Luck' <tony.luck@intel.com>
>Subject: Re: pgprot_writecombine & shub 1.x
>
>>>>>> On Wed, 19 Jan 2005 14:16:28 -0800, Jesse Barnes <jbarnes@sgi.com> said:
>
>  Jesse> No, it still depends on pgprot_writecombined, which is ia64
>  Jesse> specific.
>
> Not exactly ia64-specific, but yeah, I see x86 doesn't have it (I
> thought it did).
>
>  Jesse> x86 has its own way to set the wc bit and afaik doesn't have
>  Jesse> the same aliasing issues that ia64 has.
>
> In my opinion, an EFI-based system should respect the
> attribute-restrictions specified in the memory-map.
>
> 	--david
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


============================================Hugo Kohmann                           |
Dolphin Interconnect Solutions AS      | E-mail:
P.O. Box 150 Oppsal                    | hugo@dolphinics.com
N-0619 Oslo, Norway                    | Web:
Tel:+47 23 16 71 83                    | http://www.dolphinics.com
Fax:+47 23 16 71 80                    | 
Visiting Address: Olaf Helsets vei 6   |
