From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 16 Apr 2004 05:56:14 +0000
Subject: RE: hugetlb demand paging patch part [2/3]
Message-Id: <200404160556.i3G5uFF14323@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040416044917.GB26707@zax>
References: <200404132322.i3DNMuF21215@unix-os.sc.intel.com>
In-Reply-To: <200404132322.i3DNMuF21215@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net, raybry@sgi.com, 'Andy Whitcroft' <apw@shadowen.org>, 'Andrew Morton' <akpm@osdl.org>

David Gibson wrote on Thursday, April 15, 2004 9:49 PM
> > > If we could get rid of follow_hugetlb_pages() it would remove an ugly
> > > function from every arch, which would be nice.
> >
> > I hope the goal here is not to trim code for existing prefaulting scheme.
> > That function has to go for demand paging, and demand paging comes with
> > a performance price most people don't realize.  If the goal here is to
> > make the code prettier, I vote against that.
>
> Well, I'm attempting to understand the hugepage code across all the
> archs, so that I can try to implement copy-on-write with a minimum of
> arch specific gunk.  Simplifying and consolidating the existing code
> across archs would be a helpful first step, if possible.

Looks like everyone has their own agenda, COW is related to demand paging,
and has it's own set of characteristics to deal with.  I would hope do one
thing at a time.

- Ken


