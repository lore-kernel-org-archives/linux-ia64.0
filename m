From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Oct 2004 19:07:17 +0000
Subject: RE: [RFC] Convert pgtable cache to slab
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F022BFC13@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>With this patch I got a significant improvement in page fault time.
>Standard 2.4.x was about 700ns on average.  Generic 2.6.9rc4 is 3-4
>usec, whereas the slabified pgtcache drops us back down to 600-700 ns.

What was the benchmark you were running when you measured these?

>Tested on zx1 and sn2.

How does this scale on big sn2 systems? I assume that the answers are
going to be just fine as the slab allocator per-cpu lists should be
just as nice as local quicklists, but it would be nice to see some
data.

>The biggest caveat is that I've had to postpone setting up the gate
>page until the pgt slab has been initialized.  That wasn't an issue
>with the existing page-based allocation scheme.  David - how do you
>prefer I handle this?

I don't see the code for this postponement in this patch.

>Comments?

Overall looks nice ... less code, and goes faster too, what more
could we ask for!

Perhaps "zero_cache" isn't as descriptive a name as it might be (not
that I have any better suggestions :-(

-Tony
