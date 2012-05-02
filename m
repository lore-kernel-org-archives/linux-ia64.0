From: David Mosberger-Tang <dmosberger@gmail.com>
Date: Wed, 02 May 2012 04:11:53 +0000
Subject: Re: why is sigreturn() skipping some code on the way out of kernel?
Message-Id: <CACwUX0MWJMWYBJCGvcGR0aAwD-C47kfNj7CzEfT-c4oyood2iQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120501233743.GI6871@ZenIV.linux.org.uk>
In-Reply-To: <20120501233743.GI6871@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

[Resending, this time without html bloat...]

Al,

AFAIR (which isn't saying much), it's correct. =A0sigreturn() is not a
normal syscall. =A0The code that's being jumped over normally ensures
that the syscall args that were passed into a syscall are present in
user-level upon returning from the syscall. =A0However, since
sigreturn() does a non-local return, that behavior would be wrong.
For my own reference (and the other few people who still might have a
copy of my book): this is described on page 233, last paragraph.

=A0 --david

On Tue, May 1, 2012 at 5:37 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> AFAICS, pNonSys had been used for several purposes from the very
> beginning; one of them is suppression of syscall restarts and
> since 2.3.99pre6-4 rt_sigreturn(2) is relying on that to prevent
> a really unpleasant pile of problems. =A0So far, so good, but that's
> not the only thing conditional on pNonSys - there's also
> (pNonSys) br.cond.dpnt dont_preserve_current_frame
> =A0 =A0 =A0 =A0COVER =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
// add current frame into dirty partition and set cr.ifs
> =A0 =A0 =A0 =A0;;
> =A0 =A0 =A0 =A0mov r19=3Dar.bsp =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// get=
 new backing store pointer
> rbs_switch:
> =A0 =A0 =A0 =A0sub r16=3Dr16,r18 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 // krbs =
=3D old bsp - size of dirty partition
> =A0 =A0 =A0 =A0cmp.ne p9,p0=3Dr0,r0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// clear p=
9 to skip restore of cr.ifs
> =A0 =A0 =A0 =A0;;
> =A0 =A0 =A0 =A0sub r19=3Dr19,r16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 // calcu=
late total byte size of dirty partition
> =A0 =A0 =A0 =A0add r18d,r18 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// don't f=
orce in0-in7 into memory...
> =A0 =A0 =A0 =A0;;
> =A0 =A0 =A0 =A0shl r19=3Dr19,16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// shi=
ft size of dirty partition into loadrs position
> =A0 =A0 =A0 =A0;;
> dont_preserve_current_frame:
>
> in .work_processed_kernel and I'd really like to know if skipping it on
> sigreturn() is an intended effect. =A0I don't know ia64 well enough to ev=
en
> tell what that code is doing, let alone whether it should be done on
> sigreturn() or not...
>
> The reason I'm asking is that we really need to loop after hitting
> notify_resume_user() when we are returning to userland; not to mention
> anything else, NEED_RESCHED might've been set while we had been building
> sigframes. =A0Moreover, handling all pending signals is the normal behavi=
our
> on most of the architectures; some of the reasons for it are covered by
> kinda-sorta looping inside do_signal() (to catch self-inflicted SIGSEGV),
> but the full-blown variant is saner anyway and it's better to have that
> logics consistent between the architectures.
>
> Of course, taking that loop into entry.S needs a different mechanism
> for preventing double restarts; I wonder if using the same method that
> is used by sigreturn() would be safe. =A0FWIW, entry.S bits are very
> small; the question is whether they are correct...
>
> Comments?
>
> diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
> index 1ccbe12..27322e6 100644
> --- a/arch/ia64/kernel/entry.S
> +++ b/arch/ia64/kernel/entry.S
> @@ -1184,7 +1184,8 @@ skip_rbs_switch:
>
> =A0.notify:
> =A0(pUStk) =A0 =A0 =A0 =A0br.call.spnt.many rp=3Dnotify_resume_user
> -.ret10: =A0 =A0 =A0 =A0cmp.ne p6,p0=3Dr0,r0 =A0 =A0 =A0// p6 <- 0 (don't=
 re-check)
> +.ret10:
> +(pUStk) =A0 =A0 =A0 =A0cmp.eq.unc p6,p0=3Dr0,r0 =A0 =A0 =A0 =A0 =A0// p6=
 <- pUStk
> =A0(pLvSys)br.cond.sptk.few =A0__paravirt_pending_syscall_end
> =A0 =A0 =A0 =A0br.cond.sptk.many .work_processed_kernel
>
> @@ -1250,6 +1251,7 @@ GLOBAL_ENTRY(notify_resume_user)
> =A0(pSys) mov out2=3D1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0// out2=3D1 =3D> we're in a syscall
> =A0 =A0 =A0 =A0;;
> =A0(pNonSys) mov out2=3D0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 // out2=3D0 =3D> not a syscall
> + =A0 =A0 =A0 cmp.eq pNonSys,pSys=3Dr0,r0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 // =
don't do restarts twice
> =A0 =A0 =A0 =A0.fframe 16
> =A0 =A0 =A0 =A0.spillsp ar.unat, 16
> =A0 =A0 =A0 =A0st8 [sp]=3Dr9,-16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 // allocate space for ar.unat and save it
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html

--=20
eGauge Systems LLC, http://egauge.net/, 1.877-EGAUGE1, fax 720.545.9768
