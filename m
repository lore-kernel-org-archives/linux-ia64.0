From: Smarduch Mario-CMS063 <CMS063@motorola.com>
Date: Thu, 29 Apr 2004 13:39:51 +0000
Subject: RE: cacheble to uncachble change
Message-Id: <A752C16E6296D711942200065BFCB69407D8FDC3@il02exm10>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, thanks for answering my implicit question.

- Mario

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com] 
Sent: Wednesday, April 28, 2004 11:50 PM
To: Smarduch Mario-CMS063
Cc: Robin Holt; Smarduch Mario-CMS063; davidm@hpl.hp.com; Jack Steiner; IA-64 Mailing List (New)
Subject: Re: cacheble to uncachble change


>>>>> On Wed, 28 Apr 2004 10:52:58 -0500, Mario Smarduch 
>>>>> <cms063@email.mot.com> said:

  Mario> But now that I look at it, it seems that TRs pin the kernel
  Mario> as well with cacheble attribute.

Yes, there are the pinned entries and, additionally, any address that's accessed via region 7 (address 0xe000...) will get mapped by the alternate TLB miss-handler with a granule-sized TLB entry.  The size of a granule is given by IA64_GRANULE_SIZE and is normally 64MB (but may be 16MB for machines that require it).

So if you map _anything_ uncachable, you need to reserve the _entire_
(naturally-aligned) granule (all 64/16MB of it) and then you'll be OK.

	--david
