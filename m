From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 13 Oct 2004 18:59:56 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <20041013185956.GA9106@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 13, 2004 at 02:47:43PM -0400, Martin K. Petersen wrote:
> This patch makes the page table cache on IA-64 use the slab instead of
> standard page allocations.  It's based upon Bill Irwin's code for
> ppc64.
> With this patch I got a significant improvement in page fault time.
> Standard 2.4.x was about 700ns on average.  Generic 2.6.9rc4 is 3-4
> usec, whereas the slabified pgtcache drops us back down to 600-700 ns.
> Tested on zx1 and sn2.
> The biggest caveat is that I've had to postpone setting up the gate
> page until the pgt slab has been initialized.  That wasn't an issue
> with the existing page-based allocation scheme.  David - how do you
> prefer I handle this?

Nice! I got reports that it would not be beneficial when I thought
about going over this earlier. I suppose it's a small vindication
of my methods to see the original objection contradicted here. =)


-- wli
