From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 20 Oct 2005 21:47:53 +0000
Subject: RE: [PATCH 0/1] ia64:  numa emulation
Message-Id: <200510202148.j9KLmBg26310@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1129840588.6182.36.camel@localhost.localdomain>
In-Reply-To: <1129840588.6182.36.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Lee Schermerhorn wrote on Thursday, October 20, 2005 1:59 PM
> > > Back around 2.6.10, I recall seeing discussion of dynamically
> > > sizing hugetlbfs based on max order.  I haven't tracked this
> > > to see if it went in.  But, if it did, one could reenable
> > > hugetlbfs and adapted to the reduced max order automatically.
> > 
> > I have a patch does better than that.  We can change the hugetlb
> > page size at run time.  I will clean up my patch and post it.
> > 
> 
> Cool.  Sounds like a generic [!just ia64] patch, right?


Well, the patch is ia64 only since x86 and x86_64 doesn't offer
multiple page size for hugetlb page.  In any case, this probably
should be arch specific, since it uses arch specific API to find
out supported page size.

- Ken

