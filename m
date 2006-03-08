From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Mar 2006 22:25:46 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05E8BAA7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Page migration is particular suitable for the creation of this race since
>it needs to remove and restore page table entries.

I'm trying to understand why we haven't seen this problem before page
migration was invented.  Surely in the swapout case we have the same
situation ... swapper does "*pte = 0 ... ptc" to zap the pte and nuke
the TLB (in that order), but there is a window in between where the
process might try to update the accessed/dirty bits.

Have we just been lucky?
Is the window much wider for the process migration case?

-Tony
