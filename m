From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 25 Sep 2003 06:57:10 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106447313609056@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442121824485@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442121824485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Sep 2003 23:02:34 -0700, William Lee Irwin III <wli@holomorphy.com> said:

  Bill> On Wed, 24 Sep 2003 09:30:44 -0700, Stephen Hemminger
  Bill> <shemminger@osdl.org> said:

  Stephen> Looks good, but you aren't likely to get much acceptance or
  Stephen> testing if it only works on ia64.  You need to make a
  Stephen> version for i386 as well.

  Bill> On Wed, Sep 24, 2003 at 10:02:35AM -0700, David Mosberger wrote:

  >> Is this true for >8-way machines?

  Bill> x86's architectural limitations are 64x for serial APIC -based machines
  Bill> (e.g. NUMA-Q) and 255x for xAPIC -based machines (no known extant > 32x
  Bill> machines, apparently some kind of non-architectural regression), where
  Bill> the non-power-of-two number of cpus is due to the broadcast ID reserved
  Bill> from an 8-bit interrupt controller ID space. A likely explanation for
  Bill> the current xAPIC limitations is the recommended (publicly documented)
  Bill> physical APIC ID enumeration scheme breaking down for > 32x.

  Bill> Custom interrupt controllers may exceed these limits, but I don't know
  Bill> of any that have actually been made use of to do so. Though it sucks
  Bill> and very, very badly, x86 is not limited to anything like 8x.

I wasn't suggesting that x86 is limited to 8-way, I was wondering how
many > 8-way x86 Linux machines are actually out there.  I wasn't even
being facetious---just curious.

	--david
