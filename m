From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 16 Feb 2005 19:10:56 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <yq0oeeknwvz.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>> I'm also not thrilled about mem.c being cloned into arch/ia64.
Tony> Looking more closely at what you did, things aren't as bad as I
Tony> first thought.  Strike that comment from the record.

Tony,

No problem. I really didn't want to do it, but it seems that the -mm
series already introduced this for Xen. It was that or 3 zillion
#ifdefs ;-(

Tony> But the PG_arch_1 dual usage issue remains.

Hmmm for some reason I had the impression PG_arch_1 was only used on
PPC/PPC64 for icache current status, but it looks like you're
right. Darn ;-(

Can't we just drop swiotlb and tell people to buy real hardware? ;-)))

Ok, I'll invent a new flag!

Thanks for the input!

Cheers,
Jes
