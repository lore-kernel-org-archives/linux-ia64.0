From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 12 Nov 2002 17:00:26 +0000
Subject: Re: [Linux-ia64] [PATCH] Performance Patch for TLB misses
Message-Id: <marc-linux-ia64-105590709805401@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805350@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805350@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 12 Nov 2002 09:43:02 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> David Mosberger schrieb:

  >> Useless to the user, but dangerous to the health of the machine!
  >> Please note that attribute aliasing can lead to a machine-check
  >> and therefore is an absolute no-no (the machine check could be
  >> triggered either by a hardware-prefetch or due to speculative
  >> memory accesses inside the kernel).

  Christian> I still haven't read volume 2 (System Architecture) to
  Christian> the end, so I learned another piece of the total
  Christian> complexity of IA64 now.

Note that attribute-aliasing is a problem any architecture with
multiple page-size somehow needs to deal with.  Remember the Athlon
AGP bug?  It caused problems for a long time and it was due to
attribute-aliasing (between 4KB user pages and 4MB kernel mappings).
The difference with ia64 is that the architects chose to make
attribute-aliasing illegal upfront (so that you may get an MCA when
inserting an invalid translation in the TLB), rather than waiting for
silent data corruption (as it happened with the Athlong AGP bug).
Given the choice between silent data corruption and an explicit MCA, I
think the latter is much preferable.

	--david

