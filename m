From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Jan 2009 20:25:42 +0000
Subject: RE: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35CBE5CB0@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The patch convert it to below for nop:
>       [MII] nop.m 0x0
>       mov r3=ip
>       nop.i 0x0
>       [MLX] nop.m 0x0
>       nop.x 0x0;;
> This isn't completely nop, as there is one instuction 'mov r3=ip', but
> it should be light and harmless for code follow it.

Did you consider using predicate registers to enable/disable.  E.g.
using something like this (using your currrent calling convention):

        MMI     cmp.ne p6,p0=r0,r0;;
                nop.m 0
        (p06)   mov r3=ip
        MLX     nop.m 0
        (p06)   brl.many <target_address>

Then just patch the "cmp" instruction to something that makes p6 true to enable.

Like this it may not be any better though ... although it avoids
doing the "mov r3=ip" when the tracepoint is disabled ... it may still
mess with the branch prediction logic and update entries in the branch
target cache before the processor realizes that p6 is false and so the
branch should be squashed.

But it does give you the flexibility to pick almost any 5 instructions
for your stub (so long as they can fit within the available templates)
while still allowing ftrace to enable/disable them by patching just one
instruction.  So you might think of some smarter way to do this.

-Tony
