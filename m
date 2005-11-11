From: Robin Holt <holt@sgi.com>
Date: Fri, 11 Nov 2005 02:11:16 +0000
Subject: Re: [Patch 1/1] 4-level page tables v4.
Message-Id: <20051111021116.GA14122@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
In-Reply-To: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 10, 2005 at 06:06:43PM -0800, Chen, Kenneth W wrote:
> Robin Holt wrote on Thursday, November 10, 2005 5:20 PM
> > Here is another go.  I removed the p9 check.  It all fits fairly
> > nicely under a #ifdef.
> 
> Oh, p9 is introduced to remove some of the #ifdef, which is what
> people are grumbling about for readability and maintainability.
> I thought it's a neat idea.  Apparently not so from your view?

I am not sure this adds that much to readability since the setting of
p9 happens fairly early in vhtp_miss and the use of it is fairly late.
The #ifdef just makes it clearer to me.  I will put it back if that
makes this more pallatable.

I am more concerned about the slowdown I am seeing now.  lmbench is now
showing a small slowdown on fork and your touch a lot of pages test is
considerably slower (guess approx 0.5% slower on average of 25 runs).
It used to have samples all over the spectrum but now they all tend to
be at the high side of the noise of the 3-level run.

Any suggestions?

Thanks,
Robin
