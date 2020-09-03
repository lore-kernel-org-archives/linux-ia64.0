From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Thu, 03 Sep 2020 10:57:39 +0000
Subject: Re: [PATCH 1/2] dma-mapping: introduce dma_get_seg_boundary_nr_pages()
Message-Id: <CAHp75VcVJBSnPQ6NfdF8FdEDfM+oQ=Sr+cH5VGX4SrAqrgpf-g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200901221646.26491-1-nicoleotsuka@gmail.com> <20200901221646.26491-2-nicoleotsuka@gmail.com>
In-Reply-To: <20200901221646.26491-2-nicoleotsuka@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicolin Chen <nicoleotsuka@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "open list:LINUX FOR POWERPC PA SEMI PWRFICIENT" <linuxppc-dev@lists.ozlabs.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, rth@twiddle.net, ink@jurassic.park.msu.ru, Matt Turner <mattst88@gmail.com>, linux-alpha@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, schnelle@linux.ibm.com, gerald.schaefer@linux.ibm.com, hca@linux.ibm.com, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-s390@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, linux-parisc@vger.kernel.org

On Wed, Sep 2, 2020 at 1:20 AM Nicolin Chen <nicoleotsuka@gmail.com> wrote:
>
> We found that callers of dma_get_seg_boundary mostly do an ALIGN
> with page mask and then do a page shift to get number of pages:
>     ALIGN(boundary + 1, 1 << shift) >> shift
>
> However, the boundary might be as large as ULONG_MAX, which means
> that a device has no specific boundary limit. So either "+ 1" or
> passing it to ALIGN() would potentially overflow.
>
> According to kernel defines:
>     #define ALIGN_MASK(x, mask) (((x) + (mask)) & ~(mask))
>     #define ALIGN(x, a) ALIGN_MASK(x, (typeof(x))(a) - 1)
>
> We can simplify the logic here into a helper function doing:
>   ALIGN(boundary + 1, 1 << shift) >> shift
> = ALIGN_MASK(b + 1, (1 << s) - 1) >> s
> = {[b + 1 + (1 << s) - 1] & ~[(1 << s) - 1]} >> s
> = [b + 1 + (1 << s) - 1] >> s
> = [b + (1 << s)] >> s
> = (b >> s) + 1
>
> This patch introduces and applies dma_get_seg_boundary_nr_pages()
> as an overflow-free helper for the dma_get_seg_boundary() callers
> to get numbers of pages. It also takes care of the NULL dev case
> for non-DMA API callers.

...

> +static inline unsigned long dma_get_seg_boundary_nr_pages(struct device *dev,
> +               unsigned int page_shift)
> +{
> +       if (!dev)
> +               return (U32_MAX >> page_shift) + 1;
> +       return (dma_get_seg_boundary(dev) >> page_shift) + 1;

Can it be better to do something like
  unsigned long boundary = dev ? dma_get_seg_boundary(dev) : U32_MAX;

  return (boundary >> page_shift) + 1;

?

> +}

-- 
With Best Regards,
Andy Shevchenko
