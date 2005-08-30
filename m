From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 30 Aug 2005 21:52:35 +0000
Subject: Re: ip_contrack module refuses to load...
Message-Id: <17172.54563.329758.846131@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "david" = david mosberger <dmosberger@gmail.com> writes:

david> The module-loader does its own UP special-casing.  For
david> example, percpu_modcopy() is a dummy routine in the UP case,
david> apparently because there is not supposed to be any per-CPU
david> module data for the UP case.

Precisely.  All the other architectures redefine the DECLARE_PER_CPU()
etc., to declare plain variables (i.e., not in a special section) for
UP.  So the module loader doesn't have to do anything special for UP,
because for UP a per-cpu variable is just the same as a normal
variable.

This doesn't work for IA64, which maps per_cpu variables into a
separate segment for both UP and SMP.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
