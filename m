From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 03 Jun 2005 19:11:29 +0000
Subject: Re: Initialization of cr.dcr
Message-Id: <17056.43873.142776.892002@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A01CA2.8010209@hob.de>
In-Reply-To: <42A01CA2.8010209@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 3 Jun 2005 13:27:54 -0500 (CDT), Russ Anderson <rja@sgi.com> said:

  Russ> Ken Chen wrote:
  >>  Christian Hildner wrote on Friday, June 03, 2005 2:02 AM >
  >> playing around with speculation I found that on initialization
  >> dcr.dm is > not set, while the comment says "Initialize default
  >> control register to > defer all speculative faults". To be
  >> conform to the comment (and also to > the expected behavior) the
  >> value IA64_DCR_DM should be added in > arch/ia64/kernel/setup.c.

  >> It should be the other way around: update the comments to reflect
  >> what the code does.  Turning off dcr.dm is a big win for
  >> speculative load where you do want the tlb miss to be serviced up
  >> front.

That's correct.  We changed this a long time ago and apparently forgot
to update the comment.

  Russ>   Virtual Memory in the IA-64 Linux Kernel * By Stephane
  Russ> Eranian, David Mosberger.

  Russ>   A related problem arises from speculative loads in the
  Russ> kernel. If TLB misses are not deferred (dcr.dm is 0), a
  Russ> speculative load inside the kernel may cause a TLB miss to an
  Russ> arbitrary address. If that address happens to fall inside
  Russ> region 6 or 7, the speculative load would trigger an alternate
  Russ> TLB fault. This again poses the risk of inserting a
  Russ> translation with conflicting memory attributes. To prevent
  Russ> this, the alternate DTLB miss handler also checks whether the
  Russ> faulting access was caused by a speculative load and, if so,
  Russ> turns on the exception deferral bit (ed in psr) instead of
  Russ> installing a translation. The net effect of this method is
  Russ> that all speculative loads to region 6 and 7 produce a NaT
  Russ> value, unless the translation for the page being accessed
  Russ> happens to be in the TLB already. This solution may sometimes
  Russ> produce a NaT unnecessarily, but apart from a small
  Russ> performance impact, does not affect the correct operation of
  Russ> the kernel. This solution also has the advantage that
  Russ> speculative loads cannot pollute the TLB with unnecessary
  Russ> translations.

  Russ> http://www.informit.com/articles/article.asp?p)961&seqNum=5&rl=1

And your point is?

	--david
