From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 29 Apr 2004 04:49:46 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <16528.35178.111833.357038@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 28 Apr 2004 10:52:58 -0500, Mario Smarduch <cms063@email.mot.com> said:

  Mario> But now that I look at it, it seems that TRs pin the kernel
  Mario> as well with cacheble attribute.

Yes, there are the pinned entries and, additionally, any address
that's accessed via region 7 (address 0xe000...) will get mapped by
the alternate TLB miss-handler with a granule-sized TLB entry.  The
size of a granule is given by IA64_GRANULE_SIZE and is normally 64MB
(but may be 16MB for machines that require it).

So if you map _anything_ uncachable, you need to reserve the _entire_
(naturally-aligned) granule (all 64/16MB of it) and then you'll be OK.

	--david
