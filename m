From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 17 Mar 2005 23:37:20 +0000
Subject: RE: Recent fix for pgd_addr_end
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0319B0C2@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>That's the IA64 architecture defined unimplemented bits, which are
>sign extended from the most significant implemented bit other than the
>region ID in the virtual address.  Go onto the next page:
>
>       http://www.phptr.com/articles/article.asp?p)961&seqNum=3
>
>and look for figure 4.21 and its commentary.

You are right ... I got the implemented bits confused how Linux uses
this stuff.

Thanks.

-Tony
