From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 30 Aug 2005 01:35:45 +0000
Subject: RE: ip_contrack module refuses to load...
Message-Id: <17171.47089.417214.67841@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:


Peter> Should the module loader do anything special for per-cpu
Peter> variables?

Per-cpu variables are messed up for modules and UP kernel builds.
They're always placed in a special area (whether built for UP or SMP),
but the code for copying the .data.small segment for a module into the
per-cpu area is compiled only if !CONFIG_SMP.

In fact, in the generic percpu_modcopy for UP, there's a BUG_ON if the
percpu data area is non-zero-sized (which we don't hit, because IA64
uses its own percpu_modcopy).

There's code, for example, in the kernel entry/exit path that relies
on the per-cpu area being specially mapped (getting the number of
physical stacked registers), so doing the same as other architectures
isn't really an option.

So what to do?


-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
