From: Robin Holt <holt@sgi.com>
Date: Fri, 04 Nov 2005 21:37:46 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051104213746.GA31491@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 04, 2005 at 10:51:07AM -0800, Chen, Kenneth W wrote:
> Luck, Tony wrote on Wednesday, November 02, 2005 8:31 AM
> > Good to hear that (though I must remember to specify what I mean
> > by "small memory" when talking to SGI ... there are ia64 boxes
> > with only 1G :-)
> > 
> > Ken: Any predictions on when a 4-level run might get to the
> > top of your queue for a run with an industry standard transaction
> > benchmark?
> 
> It turns out that we have measurable performance regression with
> 4-level page table running industry database benchmark, the penalty
> is ~0.2% (I thought the number would be smaller than 0.2%, but ...).
> Our resolution with this workload is typically 0.05%.

Can you point me at this benchmark?

Thanks,
Robin
