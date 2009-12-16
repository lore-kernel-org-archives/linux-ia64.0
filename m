From: David Woodhouse <david.woodhouse@intel.com>
Date: Wed, 16 Dec 2009 17:29:59 +0000
Subject: RE: [PATCH] implement early_io{re,un}map for ia64
Message-Id: <1260984599.18156.2.camel@macbook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <89khjo$e5tirq@orsmga002.jf.intel.com>
In-Reply-To: <89khjo$e5tirq@orsmga002.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2009-12-16 at 17:18 +0000, Luck, Tony wrote:
> > I'll push it, thanks. That keeps it very close to the commit which broke
> > it, so bisection isn't hard.
> 
> Too late ... I bundled it with a pull request to Linus yesterday ...

So did I :)

>  so he will probably do the pull and get it into 2.6.33-rc1 (which
> will keep it ahead of when Chris' iommu fix hits mainline).

That doesn't necessarily help for bisection.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

