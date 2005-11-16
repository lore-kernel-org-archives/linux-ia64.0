From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Nov 2005 23:05:15 +0000
Subject: RE: [PATCH] RFC : Page table macros
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04F97253@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051116050037.GF2440@cse.unsw.EDU.AU>
In-Reply-To: <20051116050037.GF2440@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The 4 level page table case where things have been left as
> (4*PAGE_SHIFT - 9) I think shows that abstracting to think about
> things as entries rather than as pointers is useful.

This is perhaps a good point.  If someone ever wants to get 4-level
page tables running with 64K pagesize, they will want to allocate
less than a full page at one (or more) levels (since 13+13+13+13+16
is 68 ... more bits than we need).  So expressions like
       (4*PAGE_SHIFT - 9)
will reveal even more hidden assumptions.

However, I can't quite imagine a structure where the entries in
the _upper_ levels are anything except pointers (unless h/w is
walking the upper levels and imposes some other structure ... but
this is not the case for ia64).

-Tony
