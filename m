From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 20 Oct 2005 20:58:57 +0000
Subject: RE: [PATCH 0/1] ia64:  numa emulation
Message-Id: <1129841937.6182.49.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1129840588.6182.36.camel@localhost.localdomain>
In-Reply-To: <1129840588.6182.36.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-10-20 at 13:52 -0700, Chen, Kenneth W wrote:
> Lee Schermerhorn wrote on Thursday, October 20, 2005 1:36 PM
> > Also, because of interaction of max order and huge tlb fs [hard
> > coded HPAGE_SHIFT_DEFAULT], I disable hugetlbfs when numa emulation
> > is configured.
> 
> Hugetlbfs can still be safely enabled.  The only downside is system
> won't be able to reserve any hugetlb page with the default size. Maybe
> it is senseless, but no harm is done here by enabling it.

OK.  I wasn't sure, and didn't have need for hugetlbfs at the time, so I
just disabled it by default when emulation selected.  One could always
override that default.

> 
> 
> > Back around 2.6.10, I recall seeing discussion of dynamically sizing
> > hugetlbfs based on max order.  I haven't tracked this to see if it
> > went in.  But, if it did, one could reenable hugetlbfs and adapted
> > to the reduced max order automatically.
> 
> I have a patch does better than that.  We can change the hugetlb page
> size at run time.  I will clean up my patch and post it.
> 

Cool.  Sounds like a generic [!just ia64] patch, right?

Lee

