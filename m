From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 13 Oct 2004 18:57:30 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <200410131357.30958.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, October 13, 2004 1:47 pm, Martin K. Petersen wrote:
> This patch makes the page table cache on IA-64 use the slab instead of
> standard page allocations.  It's based upon Bill Irwin's code for
> ppc64.
>
> With this patch I got a significant improvement in page fault time.
> Standard 2.4.x was about 700ns on average.  Generic 2.6.9rc4 is 3-4
> usec, whereas the slabified pgtcache drops us back down to 600-700 ns.
>
> Tested on zx1 and sn2.
>
> The biggest caveat is that I've had to postpone setting up the gate
> page until the pgt slab has been initialized.  That wasn't an issue
> with the existing page-based allocation scheme.  David - how do you
> prefer I handle this?
>
> Comments?

Looks really nice, it's good to see a diffstat with "5 files changed, 50 
insertions(+), 125 deletions(-)" that actually speeds things up and makes the 
code more sensible.

Jesse
