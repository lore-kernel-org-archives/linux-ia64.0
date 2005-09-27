From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Sep 2005 00:03:09 +0000
Subject: RE: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F047E927D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161418.GW16066@localhost.localdomain>
In-Reply-To: <20050922161418.GW16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I'm assuming you refer to the config changes in arch/ia64/Kconfig. Well the
>new ones are documented in mm/Kconfig.  If that documentation is inadequate,
>then I can attempt to supply more.

There aren't any words in there about why I might want to use
sparsemem ... just a standard version of if you don't know what
to pick, go with the old discontig stuff.


>Should you think we won't get sufficient test converage without some default
>configuration files, then I'd suggest the two mentioned about be introduced.

This is definitely the prime issue ... config space on ia64
is already very fragmented, so testting of some combination
of options is rare to non-existant.  If SPARSEMEM isn't turned
on, then it won't be used by anyone that isn't already reading
the lhms list.  Coupled with the lack of sales pitch in the
Kconfig help files, it looks like this isn't going to be used
by anyone!

>Long term should SPARSEMEM become the default and DISCONTIG+VIRTUAL_MEM_MAP
>be obsoleted then we could remove the config files.

If benchmarks show no difference, then I'll consolidate the
configuration options.  I still think that VIRTUAL_MEM_MAP
has a great deal of elegance to it ... auto-sizing to just
about any degree of sparseness, but I think we need to
simplify.

-Tony
