From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 07 Feb 2005 22:58:36 +0000
Subject: RE: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02DC12C5@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I'm confused about how the offsets are now being computed.
>Keith's explaination made sense.  How does the current code
>get the correct link time offsets?

Initially I'd imagined that ar.k3 would point at the physical
address of the base of the per-cpu area ... and then we'd be
able to access any per-cpu variable with:

	phys(per_cpu_X) = ar.k3 + (virt_per_cpu_X - PERCPU_ADDR);

As Keith has pointed out, it's hard to do this because of the
allocation of addresses to percpu variables at link time.  But
David observed that we could get around this by assigning ar.k3
a value so that:

	phys(per_cpu_X) = ar.k3 + virt_per_cpu_X;

re-arranging (algebra 101):

	ar.k3 = phys(per_cpu_X) - virt_per_cpu_X;

This clearly gives the same value for ar.k3 for any per-cpu
variable (the offsets within the virtual page are the same
as the offsets within the physical page).  So we can use the
base of the page itself in setup.c:

        ia64_set_kr(IA64_KR_PER_CPU_DATA,
                    ia64_tpa(cpu_data) - (long) __per_cpu_start);

Interesting numerical aside ... When I first looked at the values in
ar.k3 on each cpu, I thought there was an off-by-one error in
the initialzation ... I saw that ar.k3 on cpu(N) pointed to the
physical address of the percpu area of cpu(N+1).  But if you think for
a little while about the addresses that we use for per-cpu variables,
you realize that they all look like small negative numbers (since we
anchor the top of the per-cpu area at 0xffffffffffffffff).  So in fact
the value we end up with in ar.k3 is the physical address of the END
of that cpu's per area.  E.g. "__per_cpu_start" in the statement above
has the value "-64K" ... so if ar.k3 points at the end of the structure,
then ar.k3 - 64K points at the start.

-Tony
