From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 Feb 2005 18:05:42 +0000
Subject: RE: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02F17D6A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
In-Reply-To: <16923.193.128608.607599@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@wildopensource.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Matthew Wilcox <matthew@wil.cx>

>On Tue, Feb 22, 2005 at 09:41:04AM -0500, Jes Sorensen wrote:
>> >> + if (page->flags & PG_uncached)
>> 
>> Andrew> dude.  That ain't gonna work ;)
>> 
>> Pardon my lack of clue, but why not?
>
>I think you're supposed to always use test_bit() to check page flags

You defined PG_uncached as "20" ... so either:

	if (page->flags & (1<<PG_uncached))

or (much better) to use:

	test_bit(PG_uncached, &page->flags).

-Tony
