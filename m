From: Sebastian Ott <sebott@linux.ibm.com>
Date: Mon, 03 Jun 2019 11:51:02 +0000
Subject: Re: [PATCH v8 3/7] s390/pci: add support for IOMMU default DMA mode build options
Message-Id: <alpine.LFD.2.21.1906031350240.18543@schleppi>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190530034831.4184-1-thunder.leizhen@huawei.com> <20190530034831.4184-4-thunder.leizhen@huawei.com>
In-Reply-To: <20190530034831.4184-4-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zhen Lei <thunder.leizhen@huawei.com>
Cc: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>


On Thu, 30 May 2019, Zhen Lei wrote:
> The default DMA mode is LAZY on s390, this patch make it can be set to
> STRICT at build time. It can be overridden by boot option.
> 
> There is no functional change.
> 
> Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>

Acked-by: Sebastian Ott <sebott@linux.ibm.com>
