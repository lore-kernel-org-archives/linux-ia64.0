From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 02 Jun 2005 17:36:08 +0000
Subject: RE: flush_icache_range
Message-Id: <17055.17288.428883.146625@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 1 Jun 2005 20:00:30 -0700, "Jim Hull" <jim.hull@hp.com> said:

  Jim> David:

  >> If a CPU advertises an optimal stride-size of 128 bytes, that better
  >> work for all CPUs in the system, even if the optimal stride for
  >> another CPU is smaller, say 64 bytes.

  Jim> Unfortunately, that's not how the ia64 architecture works.
  Jim> Although the flushes are broadcast throughout the cache
  Jim> coherence domain, the parameters returned by PAL are for that
  Jim> specific processor only.  This is because each PAL knows
  Jim> nothing about the other (potentially heterogeneous) processors
  Jim> - that depends on system knowledge.

  Jim> Because there is no SAL interface to query all the PALs and
  Jim> compute the minimum for you, this task falls on the OS to do.

Clearly PAL couldn't do that.  What I had in mind was something else:
suppose you wanted to design a machine that can mix CPUs with L3
cache-line sizes of 128 and 256 bytes.  In such a case, I'd have
_expected_ that either the 256 byte CPUs would also advertise a stride
of 128 (since they're designed to be backwards-compatible) or they
advertise a 256 byte stride but then take care of converting each "fc"
into a pair of 128-byte flushes on the bus.

I guess what you're saying is that the architecture imposes no such
constraint and the OS _must_ flush at the minium stride across all
CPUs.  Right?

	--david
