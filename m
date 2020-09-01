From: Christoph Hellwig <hch@lst.de>
Date: Tue, 01 Sep 2020 09:11:05 +0000
Subject: Re: [RESEND][PATCH 0/7] Avoid overflow at boundary_size
Message-Id: <20200901091105.GA4959@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200831203811.8494-1-nicoleotsuka@gmail.com> <20200901073623.GA30418@lst.de> <20200901075401.GA5667@Asurada-Nvidia>
In-Reply-To: <20200901075401.GA5667@Asurada-Nvidia>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicolin Chen <nicoleotsuka@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, tony.luck@intel.com, fenghua.yu@intel.com, schnelle@linux.ibm.com, gerald.schaefer@linux.ibm.com, hca@linux.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, sfr@canb.auug.org.au, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org

On Tue, Sep 01, 2020 at 12:54:01AM -0700, Nicolin Chen wrote:
> Hi Christoph,
> 
> On Tue, Sep 01, 2020 at 09:36:23AM +0200, Christoph Hellwig wrote:
> > I really don't like all the open coded smarts in the various drivers.
> > What do you think about a helper like the one in the untested patch
> 
> A helper function will be actually better. I was thinking of
> one yet not very sure about the naming and where to put it.
> 
> > below (on top of your series).  Also please include the original
> > segment boundary patch with the next resend so that the series has
> > the full context.
> 
> I will use your change instead and resend with the ULONG_MAX
> change. But in that case, should I make separate changes for
> different files like this series, or just one single change
> like yours?
> 
> Asking this as I was expecting that those changes would get
> applied by different maintainers. But now it feels like you
> will merge it to your tree at once?

I guess one patch is fine.  I can queue it up in the dma-mapping
tree as a prep patch for the default boundary change.
