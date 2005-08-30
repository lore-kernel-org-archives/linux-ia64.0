From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 30 Aug 2005 16:17:42 +0000
Subject: RE: ip_contrack module refuses to load...
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0443A20B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Per-cpu variables are messed up for modules and UP kernel builds.
>They're always placed in a special area (whether built for UP or SMP),
>but the code for copying the .data.small segment for a module into the
>per-cpu area is compiled only if !CONFIG_SMP.
>
>In fact, in the generic percpu_modcopy for UP, there's a BUG_ON if the
>percpu data area is non-zero-sized (which we don't hit, because IA64
>uses its own percpu_modcopy).
>
>There's code, for example, in the kernel entry/exit path that relies
>on the per-cpu area being specially mapped (getting the number of
>physical stacked registers), so doing the same as other architectures
>isn't really an option.
>
>So what to do?

At first glance it looks like ia64 should not be treating the UP
case differently from the SMP case.  UP kernels place the per-cpu
data up in the top 64K (PERCPU_PAGE_SIZE) of the virtual address
space mapped by DTR[1], just like SMP kernels do ... so all the
space allocation, mapping, and relocation code should be the same
for UP and SMP ... shouldn't they?

-Tony
