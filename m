From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 08 Feb 2005 18:11:24 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02DFB12D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith wrote:
>arch/ia64/kernel/mca_asm.S is treating per_cpu__ia64_mca_data as the
>start of the mca data, instead of as a pointer to the mca data.  It
>ends up overwriting the rest of the per cpu area with the MCA stack and
>bspstore.  Since we dereference ia64_mca_data several times, make it a
>macro.

That's the combination of my patch to (almost) correctly do the
dereference, and Russ's patch (which fixes the spot where I managed
to deref after adding the IA64_MCA_CPU_STACKFRAME_OFFSET).  The
macro is cleaner, and avoids the possibility of making a dumb
mistake (like mine :-( )

Applied, and pushed.

This just survived me inserting a TLB error ... the resulting MCA
was fixed and logged.  The system is still ticking on all four cpus.

But Russ's last report of running with effectively the same patch
wasn't positive:

> The patch (below) helps in that they system gets through the
> MCA code and back to the error injection app, but then
> the system dies.

Russ: Any detail on why the system died?

-Tony
