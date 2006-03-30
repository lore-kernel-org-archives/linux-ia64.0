From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 30 Mar 2006 16:34:55 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <20060330163455.GA8654@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 30, 2006 at 10:42:00AM -0500, Prarit Bhargava wrote:
> Hello all,
> 
> >---
> > arch/ia64/kernel/gate.lds.S |    1 +
> > include/asm-ia64/asmmacro.h |    4 ++++
> > 2 files changed, 5 insertions(+)
> >
> 
> I applied this patch and compiled using gcc-4.1.0-3.
> 
> I now see hundreds of warnings like:
> 
> WARNING: drivers/atm/he.o - Section mismatch: reference to 
> .init.text:he_start from .text after 'he_init_one' (at offset 0x81a2)
> WARNING: drivers/block/cpqarray.o - Section mismatch: reference to 
> .init.text:cpqarray_init_one from .data.rel.local between 
> 'cpqarray_pci_driver' (at offset 0x20) and 'smart1_access'
> 

Where did they come from?


H.J.
