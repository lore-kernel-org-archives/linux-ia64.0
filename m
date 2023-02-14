From: Christoph Hellwig <hch@lst.de>
Date: Tue, 14 Feb 2023 14:11:42 +0000
Subject: Re: [PATCH] dma-mapping: no need to pass a bus_type into get_arch_dma_ops()
Message-Id: <20230214141142.GA14060@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230214140121.131859-1-gregkh@linuxfoundation.org>
In-Reply-To: <20230214140121.131859-1-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux.dev, linux-arch@vger.kernel.org

On Tue, Feb 14, 2023 at 03:01:21PM +0100, Greg Kroah-Hartman wrote:
> The get_arch_dma_ops() arch-specific function never does anything with
> the struct bus_type that is passed into it, so remove it entirely as it
> is not needed.

Yes.  (and eventually get_arch_dma_ops should go away entirely, but that's
a separate story).

> Note: Unless someone objects, I would like to take this through the
> driver-core tree, as further bus_type cleanups depend on it, and it's
> stand-alone from everyone else's tree at the moment from what I can
> determine.

Please do!

Acked-by: Christoph Hellwig <hch@lst.de>
