From: David Woodhouse <david.woodhouse@intel.com>
Date: Wed, 16 Dec 2009 02:45:05 +0000
Subject: Re: [PATCH] implement early_io{re,un}map for ia64
Message-Id: <1260931505.11159.59.camel@macbook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <89khjo$e5tirq@orsmga002.jf.intel.com>
In-Reply-To: <89khjo$e5tirq@orsmga002.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2009-12-14 at 20:00 +0000, Luck, Tony wrote:
> 
> David: Do you want to run it through your iommu tree, or should
> I just pre-emptively push it in via the ia64 tree? 

I'll push it, thanks. That keeps it very close to the commit which broke
it, so bisection isn't hard.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

