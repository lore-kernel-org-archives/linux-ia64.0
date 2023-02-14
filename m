From: "Arnd Bergmann" <arnd@arndb.de>
Date: Tue, 14 Feb 2023 14:12:29 +0000
Subject: Re: [PATCH] dma-mapping: no need to pass a bus_type into get_arch_dma_ops()
Message-Id: <4e57a5aa-fd7a-4cda-90e3-6a02cfeb04c0@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230214140121.131859-1-gregkh@linuxfoundation.org>
In-Reply-To: <20230214140121.131859-1-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org
Cc: Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux.dev, Linux-Arch <linux-arch@vger.kernel.org>

On Tue, Feb 14, 2023, at 15:01, Greg Kroah-Hartman wrote:
> The get_arch_dma_ops() arch-specific function never does anything with
> the struct bus_type that is passed into it, so remove it entirely as it
> is not needed.
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
> Note: Unless someone objects, I would like to take this through the
> driver-core tree, as further bus_type cleanups depend on it, and it's
> stand-alone from everyone else's tree at the moment from what I can
> determine.

Nice find!

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

It looks like the bus was last required in 2020 before commit
255a69a94b8c ("sparc32: use per-device dma_ops").

    Arnd
