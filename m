From: Grant Grundler <iod00d@hp.com>
Date: Tue, 22 Jun 2004 21:16:03 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <20040622211603.GB25952@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 22, 2004 at 09:59:11AM -0600, Bjorn Helgaas wrote:
> David saw this late last week on a 2.6.7 kernel compiled for UP,

This is for SMP

> and I reproduced it yesterday using the current linux-ia64-2.5
> BK bits.  I'm using a zx6000 with serial console (VGA also
> present, but unused).  No MCA records.  I collected info from
> an INIT, but haven't had a chance to look very far.  Something
> in the error records pointed to efi_memmap_walk(), so I added
> a printk there, and the problem disappeared.

*ugh*. 

> David mentioned the linker in Debian/testing as a possibility.
> I'm using ld 2.14.90.0.7 from Debian binutils 2.14.90.0.7-3.

Debian/testing is currently:
ii  binutils       2.14.90.0.7-8  The GNU assembler, linker and binary utiliti

I suppose that's a possibility. I have a TOC dump on the machine
and just need to "harvest" it, then see where it's spinning.
Probably get to that tomorrow.

thanks,
grant
