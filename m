From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Oct 2004 07:44:59 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <16750.11899.109326.680893@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 13 Oct 2004 11:59:56 -0700, William Lee Irwin III <wli@holomorphy.com> said:

  William> On Wed, Oct 13, 2004 at 02:47:43PM -0400, Martin
  William> K. Petersen wrote:
  >> This patch makes the page table cache on IA-64 use the slab
  >> instead of standard page allocations.  It's based upon Bill
  >> Irwin's code for ppc64.  With this patch I got a significant
  >> improvement in page fault time.  Standard 2.4.x was about 700ns
  >> on average.  Generic 2.6.9rc4 is 3-4 usec, whereas the slabified
  >> pgtcache drops us back down to 600-700 ns.  Tested on zx1 and
  >> sn2.  The biggest caveat is that I've had to postpone setting up
  >> the gate page until the pgt slab has been initialized.  That
  >> wasn't an issue with the existing page-based allocation scheme.
  >> David - how do you prefer I handle this?

  William> Nice! I got reports that it would not be beneficial when I
  William> thought about going over this earlier. I suppose it's a
  William> small vindication of my methods to see the original
  William> objection contradicted here. =)

What was the original comment relative to?  2.4 or 2.6?  In 2.6 we
lost the PTE quick-list, which I think is where the big overhead came
from.  Right, Martin?

	--david
