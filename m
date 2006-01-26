From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 26 Jan 2006 01:06:39 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05891BD3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Getting real close.  Now I'm down to nitpicking the format
of the e-mail :-)

Andrew Morton's perfect patch document:
 http://www.zipworld.com.au/~akpm/linux/patches/stuff/tpp.txt

says that the changelog comes first, and the random commentary
comes after the "---" line (see paragraph "g").  You have this
backwards, so git attempted to use the wrong bit of text as the
changelog.

> Signed-off-by: Brent Casavant <bcasavan@sgi.com>
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> Signed-off-by: Brent Casavant <bcasavan@sgi.com>

Perhaps a little presumptious to assume that Ken is ok with
the combined version of his part of this patch (ok, I checked
with Ken, and as it happens he is ok with it).  One signoff from
you would be sufficient.

And now an actual (albeit trivial) problem.  I see a couple of
warnings when building sn2/generic kernels from the new code
that you added:

arch/ia64/sn/kernel/sn2/sn2_smp.c:184: warning: initialization discards qualifiers from pointer target type
arch/ia64/sn/kernel/sn2/sn2_smp.c:185: warning: ISO C90 forbids mixed declarations and code

(compiling with gcc 3.4.3)

-Tony
