From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 17 Mar 2004 16:53:01 +0000
Subject: Re: pgd_free, pmd_free, and pte_free trapping memory.
Message-Id: <20040317165301.A15751@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040316112424.GA20203@lnx-holt>
In-Reply-To: <20040316112424.GA20203@lnx-holt>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 17, 2004 at 10:20:16AM -0600, Jack Steiner wrote:
> The test harness ensures that the timing is done with warm TLBs & cold 
> cache (data not in cpu caches):
> 
> 	 3.1 usec 16K node local memory
> 	 6.1 usec 16K remote memory
> 
> 	12.5 usec 64K node local memory
> 	24.5 usec 64K remote memory
> 
> I ran this on Itanium 2 1300MHz cpus. However, processor core speed does
> not significantly affect timings since most time is spent waiting for 
> off chip memory access.

Well, pages on the per-cpu list are supposed to be still cache hot..

