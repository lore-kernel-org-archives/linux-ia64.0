From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 08 Apr 2019 06:32:50 +0000
Subject: Re: [PATCH v4 0/6] normalize IOMMU dma mode boot options
Message-Id: <alpine.DEB.2.21.1904080829490.1840@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190407124147.13576-1-thunder.leizhen@huawei.com> <b20fd8a6-88ce-7d26-8eb0-ed9f095988a6@huawei.com> <5CAABD03.9000301@huawei.com>
In-Reply-To: <5CAABD03.9000301@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Cc: Hanjun Guo <guohanjun@huawei.com>, Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

On Mon, 8 Apr 2019, Leizhen (ThunderTown) wrote:
> > 
> > This will break systems using boot options as now, and I think
> > this is unacceptable. If you want to do so, just introduce iommu.dma_mode
> > on top of those iommu boot options with dma mode boot options unchanged,
> > and iommu.dma_mode is for all archs but compatible with them.
> 
> I just changed the boot options name, but keep the function no change. I added
> all related maintainers/supporters in the "to=" list, maybe we can disuss this.

Changing the name _IS_ the problem. Think about unattended updates.

> Should I add some "obsoleted" warnings for old options and keep them for a while?

No, just keep the old options around for backwards compatibilty sake. We
just do not add new arch specific options in the future. New options need
to use the generic iommu.dma_mode name space.

Thanks,

	tglx
