From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 09 Sep 2004 17:21:56 +0000
Subject: Re: [RFC 0/4] Add SN2 Special Memory driver.
Message-Id: <20040909182156.A12644@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040909163638.GA23178@lnx-holt.americas.sgi.com>
In-Reply-To: <20040909163638.GA23178@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 09, 2004 at 11:36:38AM -0500, Robin Holt wrote:
> 
> This driver provides three different devices for mmap'ing pages which
> are not visible to the kernel.
> 
> sgi_fetchops) atomic operations performed by the SN2 memory controller.
> 	These operations are performed using uncached memory
> 	references with an offset of the address specifying the
> 	operation (add, sub) to perform.
> 
> sgi_uncached) Provides a device which supports mapping pages which
> 	will only be referenced uncached.  These use the Intel ia64
> 	write combining feature.  These need to be in a separate
> 	granule from regular memory to prevent the FSB from having
> 	both a cached and an uncached reference to a memory location.
> 
> sgi_cached) Provides a device which support cached operations from the
> 	processor and uncached from processors outside the coherence
> 	domain.  This provides rapid read access to the 16 words in the
> 	cache line to data that was written uncached by remote processors.

From your description only the first two actually use special SGI hardware
features, or did I misread the descruption?  If so they should probably
have a separate driver that works on all ia64 hardware.

