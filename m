From: david mosberger <dmosberger@gmail.com>
Date: Tue, 30 Aug 2005 22:01:01 +0000
Subject: Re: ip_contrack module refuses to load...
Message-Id: <ed5aea43050830150112ee6103@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ah, I understand now what you mean.  Sounds to me like the generic
module loader infrastructure needs to be changed to support the
IA64-usage.  On IA64, we want to have per-CPU variables remapped even
on UP, because it allows for more efficient and TLB-pinned addressing
(which is relied upon in some low-level code for correctness, IIRC).

  --david

On 8/30/05, Peter Chubb <peterc@gelato.unsw.edu.au> wrote:
> >>>>> "david" = david mosberger <dmosberger@gmail.com> writes:
> 
> david> The module-loader does its own UP special-casing.  For
> david> example, percpu_modcopy() is a dummy routine in the UP case,
> david> apparently because there is not supposed to be any per-CPU
> david> module data for the UP case.
> 
> Precisely.  All the other architectures redefine the DECLARE_PER_CPU()
> etc., to declare plain variables (i.e., not in a special section) for
> UP.  So the module loader doesn't have to do anything special for UP,
> because for UP a per-cpu variable is just the same as a normal
> variable.
> 
> This doesn't work for IA64, which maps per_cpu variables into a
> separate segment for both UP and SMP.
> 
> --
> Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
> The technical we do immediately,  the political takes *forever*
> 


-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
