From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 10 Mar 2004 18:45:43 +0000
Subject: Re: show_mem panic
Message-Id: <20040310184543.GA9355@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040310180923.GA9032@sgi.com>
In-Reply-To: <20040310180923.GA9032@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 10, 2004 at 10:09:23AM -0800, Jesse Barnes wrote:
> It's in the inner loop looking at the pages in the first node's
> node_mem_map.  I'm almost positive that this code worked in the past,
> Andreas, when you reproduced this on a tiger machine was it with
> CONFIG_VIRTUAL_MEM_MAP enabled?

Bjorn just informed me that John Marvin was taking a look at this.  It
looks like we need to make sure the page we're about to look at is
valid for the virtual mem map case.  And btw, it looks like the contig
version of show_mem should be fixed: total shouldn't include
non-existant pages (if we add pfn_valid checks to both the discontig and
contig versions that should be an easy fix).

Jesse
