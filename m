From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 Oct 2003 22:01:02 +0000
Subject: Re: [PATCH 2.4.23-pre8]  Remove broken prefetching in free_one_pgd()
Message-Id: <marc-linux-ia64-106703330919486@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106702916015259@msgid-missing>
In-Reply-To: <marc-linux-ia64-106702916015259@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 24 Oct 2003 13:56:31 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> This patch was accepted into 2.5.55, attributed to "davej@uk".
  Tony> This code will prefetch from beyond the end of the page table
  Tony> being cleared ... which is clearly a bad thing if the page
  Tony> table in question is allocated from the last page of memory
  Tony> (or precedes a hole on a discontig mem system).

Different arches behave differently, though.  In the case of ia64,
it'a always safe to prefetch (even with lfetch.fault).

	--david
