From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Apr 2004 23:53:40 +0000
Subject: RE: cacheble to uncachble change
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F011E69EF@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>  Mario> I guess the question wasn't so much about attribute aliasing
>  Mario> but killing all intransit memory accesses and prefetch before
>  Mario> its safe to change the TLB attribute to uncacheble, with
>  Mario> assurance that all new mem refs/prefetch will come from
>  Mario> memory. I appreciate all your inputs.
>
>  David>Yes, but that's the _easy_ part, so to speak.

Buried in one of the e-mails on this thread was the fact that you must
allocate a whole granule (16MB or 64MB ... check your .config) to make
sure that you don't have a kernel cacheable mapping setup by the
Alt-DTLB
miss handler.

-Tony
