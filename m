From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 25 Sep 2003 06:02:34 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106447093307460@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442121824485@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442121824485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 24 Sep 2003 09:30:44 -0700, Stephen Hemminger <shemminger@osdl.org> said:
Stephen> Looks good, but you aren't likely to get much acceptance or
Stephen> testing if it only works on ia64.  You need to make a
Stephen> version for i386 as well.

On Wed, Sep 24, 2003 at 10:02:35AM -0700, David Mosberger wrote:
> Is this true for >8-way machines?

x86's architectural limitations are 64x for serial APIC -based machines
(e.g. NUMA-Q) and 255x for xAPIC -based machines (no known extant > 32x
machines, apparently some kind of non-architectural regression), where
the non-power-of-two number of cpus is due to the broadcast ID reserved
from an 8-bit interrupt controller ID space. A likely explanation for
the current xAPIC limitations is the recommended (publicly documented)
physical APIC ID enumeration scheme breaking down for > 32x.

Custom interrupt controllers may exceed these limits, but I don't know
of any that have actually been made use of to do so. Though it sucks
and very, very badly, x86 is not limited to anything like 8x.


-- wli
