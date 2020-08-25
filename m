From: Nicolin Chen <nicoleotsuka@gmail.com>
Date: Tue, 25 Aug 2020 23:19:00 +0000
Subject: Re: [RFT][PATCH 0/7] Avoid overflow at boundary_size
Message-Id: <20200825231900.GA4726@Asurada-Nvidia>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200820231923.23678-1-nicoleotsuka@gmail.com>
 <4321af30-9554-6897-5281-05afd88f2631@linux.ibm.com>
In-Reply-To: <4321af30-9554-6897-5281-05afd88f2631@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Niklas Schnelle <schnelle@linux.ibm.com>
Cc: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, tony.luck@intel.com, fenghua.yu@intel.com, gerald.schaefer@linux.ibm.com, hca@linux.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, sfr@canb.auug.org.au, hch@lst.de, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org

Hi Niklas,

On Tue, Aug 25, 2020 at 12:16:27PM +0200, Niklas Schnelle wrote:
> On 8/21/20 1:19 AM, Nicolin Chen wrote:
> > We are expending the default DMA segmentation boundary to its
> > possible maximum value (ULONG_MAX) to indicate that a device
> > doesn't specify a boundary limit. So all dma_get_seg_boundary
> > callers should take a precaution with the return values since
> > it would easily get overflowed.
> > 
> > I scanned the entire kernel tree for all the existing callers
> > and found that most of callers may get overflowed in two ways:
> > either "+ 1" or passing it to ALIGN() that does "+ mask".
> > 
> > According to kernel defines:
> >     #define ALIGN_MASK(x, mask) (((x) + (mask)) & ~(mask))
> >     #define ALIGN(x, a)	ALIGN_MASK(x, (typeof(x))(a) - 1)
> > 
> > We can simplify the logic here:
> >   ALIGN(boundary + 1, 1 << shift) >> shift
> > = ALIGN_MASK(b + 1, (1 << s) - 1) >> s
> > = {[b + 1 + (1 << s) - 1] & ~[(1 << s) - 1]} >> s
> > = [b + 1 + (1 << s) - 1] >> s
> > = [b + (1 << s)] >> s
> > = (b >> s) + 1
> > 
> > So this series of patches fix the potential overflow with this
> > overflow-free shortcut.
 
> haven't seen any other feedback from other maintainers,

I am wondering this too...whether I sent correctly or not.

> so I guess you will resend this?

Do I need to? Though I won't mind doing so if it's necessary..

> On first glance it seems to make sense.
> I'm a little confused why it is only a "potential overflow"
> while this part
> 
> "We are expending the default DMA segmentation boundary to its
>  possible maximum value (ULONG_MAX) to indicate that a device
>  doesn't specify a boundary limit"
> 
> sounds to me like ULONG_MAX is actually used, does that
> mean there are currently no devices which do not specify a
> boundary limit?

Sorry for the confusion. We actually applied ULONG_MAX change
last week but reverted it right after, due to a bug report at
one of these "potential" overflows. So at this moment the top
of the tree doesn't set default boundary to ULONG_MAX yet.

Thanks
Nic
