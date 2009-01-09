From: Shaohua Li <shaohua.li@intel.com>
Date: Fri, 09 Jan 2009 02:42:03 +0000
Subject: RE: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <1231468923.10683.112.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2009-01-08 at 13:25 -0700, Luck, Tony wrote:
> > The patch convert it to below for nop:
> >       [MII] nop.m 0x0
> >       mov r3=ip
> >       nop.i 0x0
> >       [MLX] nop.m 0x0
> >       nop.x 0x0;;
> > This isn't completely nop, as there is one instuction 'mov r3=ip', but
> > it should be light and harmless for code follow it.
> 
> Did you consider using predicate registers to enable/disable.  E.g.
> using something like this (using your currrent calling convention):
> 
>         MMI     cmp.ne p6,p0=r0,r0;;
>                 nop.m 0
>         (p06)   mov r3=ip
>         MLX     nop.m 0
>         (p06)   brl.many <target_address>
> 
> Then just patch the "cmp" instruction to something that makes p6 true to enable.
> 
> Like this it may not be any better though ... although it avoids
> doing the "mov r3=ip" when the tracepoint is disabled ... it may still
> mess with the branch prediction logic and update entries in the branch
> target cache before the processor realizes that p6 is false and so the
> branch should be squashed.
> 
> But it does give you the flexibility to pick almost any 5 instructions
> for your stub (so long as they can fit within the available templates)
> while still allowing ftrace to enable/disable them by patching just one
> instruction.  So you might think of some smarter way to do this.
Ya, this should work too. Is it a nop (or as light as a nop) if an
instruction has false prediction? the 'mov r3=ip' takes overhead, but we
need it in current implementation. Better we can remove the overhead.
Instruction room doesn't matter now. instruction overhead is concerned.

Thanks,
Shaohua

