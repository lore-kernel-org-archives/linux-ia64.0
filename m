From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 Mar 2005 04:40:00 +0000
Subject: RE: recent fix for pgd_addr_end
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0319B2BC@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Tony> Peter, Dave, and anyone else following along: How does this look
>Tony> (ignoring for the moment the usage of pgd_addr_end() in the
>Tony> vmalloc() code path for region 5 ... I'll deal with that next,
>Tony> but for the moment it is only a theoretical problem as we don't
>Tony> map anywhere close to enough things in region 5 to trigger the
>Tony> IA64_PGD_OVERFLOW path in this code).
>
>I think it's good.  It even boots :-)

Booting is no guarantee of correctness (the last version booted
too, and it was horribly wrong).

Thanks for testing (and for pointing out the problem).

-Tony
