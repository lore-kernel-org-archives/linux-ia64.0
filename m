From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 25 Sep 2003 07:07:03 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106447363909419@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442121824485@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442121824485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Sep 2003 23:57:10 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:
  Bill> x86's architectural limitations are 64x for serial APIC -based
  Bill> machines (e.g. NUMA-Q) and 255x for xAPIC -based machines (no
  Bill> known extant > 32x machines, apparently some kind of
  Bill> non-architectural regression), where the non-power-of-two
  Bill> number of cpus is due to the broadcast ID reserved from an
  Bill> 8-bit interrupt controller ID space. A likely explanation for
  Bill> the current xAPIC limitations is the recommended (publicly
  Bill> documented) physical APIC ID enumeration scheme breaking down
  Bill> for > 32x.

  Bill> Custom interrupt controllers may exceed these limits, but I
  Bill> don't know of any that have actually been made use of to do
  Bill> so. Though it sucks and very, very badly, x86 is not limited
  Bill> to anything like 8x.

  David> I wasn't suggesting that x86 is limited to 8-way, I was
  David> wondering how many > 8-way x86 Linux machines are actually
  David> out there.  I wasn't even being facetious---just curious.

Incidentally, the first "big" SMP machine I had access to was some
sort of Sequent (S81/10?), with ~12 80386 CPUs (yes, that was a long
time ago... ;-).

	--david
