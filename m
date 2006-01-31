From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Tue, 31 Jan 2006 17:51:25 +0000
Subject: Fwd: [patch 1/6] remove dead code in ia64_leave_kernel
Message-Id: <ed5aea430601310951x24a715cbp2134a97b23f389d4@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

[Failed to cc' the list...]

---------- Forwarded message ----------
From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Jan 31, 2006 10:51 AM
Subject: Re: [patch 1/6] remove dead code in ia64_leave_kernel
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>


Ken,

Be careful here.  Signal-delivery triggers some strange corner-cases.
I don't have this all in my head at the moment, but one tricky part is
returning from a signal-handler, where you enter the kernel as a
syscall, but leave it as a non-syscall (usually).  I trust that you
already checked this case, but wanted to make sure the point isn't
lost.

Also, I believe with your patch, you'll end up consuming the read of
ar.bsp which could adversely affect the latency of syscalls
(especially when everything is cached).  Did you check on this?

  --david

On 1/31/06, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> The code around restoring user backing store in ia64_leave_kernel
> is just plain dumb.  ia64_leave_kernel is used for non-syscall
> exit path.  When entering the kernel from the user space, we
> already preserved the user stack register frame by doing a
> cover instruction.  on the way out, ia64_leave_kernel uncondition-
> ally bypass a section of code by "br dont_preserve_current_frame"
> (pNonSys should always be one in that path).  However, part of
> code in the beginning of rbs_switch is used by ia64_leave_syscall
> to calculate new "ndirty" bytes since in leave syscall, kernel
> have to preserve the current frame and thus needing to re
> calculate new ndirty size for loadrs.  Streamline that section of
> code into ia64_leave_syscall and remove unneeded reading ar.bsp
> in the leave kernel path.
>
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
>
> --- ./arch/ia64/kernel/entry.S.orig     2006-01-02 19:21:10.000000000 -08=
00
> +++ ./arch/ia64/kernel/entry.S  2006-01-22 02:20:46.475278554 -0800
> @@ -787,6 +787,13 @@ ENTRY(ia64_leave_syscall)
>
>         mov.m ar.ssd=3Dr0                 // M2   clear ar.ssd
>         mov f11=F0                      // F    clear f11
> +       sub r16=3Dr16,r18                 // krbs =3D old bsp - size of d=
irty partition
> +       cmp.ne p9,p0=3Dr0,r0              // clear p9 to skip restore of =
cr.ifs
> +       ;;
> +       sub r19=3Dr19,r16                 // calculate total byte size of=
 dirty partition
> +       add r18d,r18                  // don't force in0-in7 into memory.=
..
> +       ;;
> +       shl r19=3Dr19,16                  // shift size of dirty partitio=
n into loadrs pos
>         br.cond.sptk.many rbs_switch    // B
>  END(ia64_leave_syscall)
>
> @@ -951,32 +958,17 @@ GLOBAL_ENTRY(ia64_leave_kernel)
>  (pUStk)        st1 [r18]=3Dr17           // restore current->thread.on_u=
stack
>         shr.u r18=3Dr19,16        // get byte size of existing "dirty" pa=
rtition
>         ;;
> -       mov r16=3Dar.bsp          // get existing backing store pointer
>         addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
>         ;;
>         ld4 r17=3D[r17]           // r17 =3D cpu_data->phys_stacked_size_=
p8
>  (pKStk)        br.cond.dpnt skip_rbs_switch
>
> +rbs_switch:
>         /*
>          * Restore user backing store.
>          *
>          * NOTE: alloc, loadrs, and cover can't be predicated.
> -        */
> -(pNonSys) br.cond.dpnt dont_preserve_current_frame
> -       cover                           // add current frame into dirty p=
artition and set cr.ifs
> -       ;;
> -       mov r19=3Dar.bsp                  // get new backing store pointer
> -rbs_switch:
> -       sub r16=3Dr16,r18                 // krbs =3D old bsp - size of d=
irty partition
> -       cmp.ne p9,p0=3Dr0,r0              // clear p9 to skip restore of =
cr.ifs
> -       ;;
> -       sub r19=3Dr19,r16                 // calculate total byte size of=
 dirty partition
> -       add r18d,r18                  // don't force in0-in7 into memory.=
..
> -       ;;
> -       shl r19=3Dr19,16                  // shift size of dirty partitio=
n into loadrs position
> -       ;;
> -dont_preserve_current_frame:
> -       /*
> +        *
>          * To prevent leaking bits between the kernel and user-space,
>          * we must clear the stacked registers in the "invalid" partition=
 here.
>          * Not pretty, but at least it's fast (3.34 registers/cycle on It=
anium,
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/


--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
