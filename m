From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Nov 2003 21:21:39 +0000
Subject: RE: weird speed problem
Message-Id: <marc-linux-ia64-106970893131576@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106957761119369@msgid-missing>
In-Reply-To: <marc-linux-ia64-106957761119369@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 24 Nov 2003 12:00:09 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> You may be able to determine whether this is your problem by
  Tony> using Stephane's "pfmon" tool to count cache misses at various
  Tony> levels of the cache hierarchy, and comparing these numbers
  Tony> from run to run.  If you see wildly varying numbers, and your
  Tony> system is idle apart from the test program, then lack of cache
  Tony> colouring is probably the issue.

Sounds like a good suggestion to me, but before doing that, I'd
recommend to collect a simple profile.  Just to see if anything
obvious is going wrong (like unaligned accesses, lots of fpswa faults,
or similar).

Hans's qprof tool might come in handy for that:

  http://www.hpl.hp.com/research/linux/qprof/

Also, I have a not-yet-released tool which can collect call-counts
(similar to gprof, but without recompilation).  I hope to release it
sometime next week or shortly thereafter, but if someone screams
loudly enough, I might consider making a quick but totally unsupported
snapshot of what I have.

	--david
