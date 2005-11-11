From: Jack Steiner <steiner@sgi.com>
Date: Fri, 11 Nov 2005 00:24:06 +0000
Subject: Re: [Patch 1/1] 4-level page tables v4.
Message-Id: <20051111002406.GB3767@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
In-Reply-To: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 10, 2005 at 04:13:02PM -0800, Chen, Kenneth W wrote:
> Robin Holt wrote on Thursday, November 10, 2005 2:39 PM
> > I am going to attach the dispersal analysis the modified objdump that
> > Jack has produced.
> 
> >  5c:    8 S                   cmp.eq p6,p7=5,r17
> >  60:    8         [MII]       nop.m 0x0
> >  66:    8                     shr.u r18=r22,36;;
> 
> Hmm, I think the dispersal analysis software is buggy.  At least for
> the above instance.  Immediate form of shr is pseudo-op'ed to extr.
> It should count the above bundle with 2 cycles instead of one cycle.

Very possible. The tool is very old & non-supported. We have used it 
several times and had good luck. It seems to point out ares of code
that stall unexpectedlt. Eliminating the stalls usually improved
performance. However, I would be surprised if there were no
bugs in the code.

I would like to see a standard tool that gives dispersal analysis.
There was a discussion on the IA64 list ~ month ago but so far, no
takers.

> 
> - Ken
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


