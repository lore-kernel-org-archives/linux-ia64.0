From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 Oct 2003 22:21:41 +0000
Subject: RE: [PATCH 2.4.23-pre8]  Remove broken prefetching in free_one_pgd()
Message-Id: <marc-linux-ia64-106703704523140@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106702916015259@msgid-missing>
In-Reply-To: <marc-linux-ia64-106702916015259@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 24 Oct 2003 15:16:59 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> This patch was accepted into 2.5.55, attributed to "davej@uk".
  Tony> This code will prefetch from beyond the end of the page table
  Tony> being cleared ... which is clearly a bad thing if the page
  Tony> table in question is allocated from the last page of memory
  Tony> (or precedes a hole on a discontig mem system).

  >> Different arches behave differently, though.  In the case of ia64,
  >> it'a always safe to prefetch (even with lfetch.fault).

  Tony> Not quite always ... this was how I found the efi trim.bottom
  Tony> bug, since Linux had allocated a pgd at 0xa00000-16k, and the
  Tony> lfetch that reached out beyond the end of the page to the
  Tony> uncacheable address 0xa00000 took an MCA.

But don't confuse cause and effect!  The MCA was caused by a bad TLB
entry.  The lfetch only triggered the latent bug (as might have a
instruction-prefetch).

  Tony> A pgd in the last page of a granule that is followed by an uncacheable
  Tony> address would do the same with lfetch.fault, wouldn't it?

No, lfetch to uncacheable translations have no effect.

	--david
