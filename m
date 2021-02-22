From: Jens Axboe <axboe@kernel.dk>
Date: Mon, 22 Feb 2021 23:34:50 +0000
Subject: Re: 5.11 regression: "ia64: add support for TIF_NOTIFY_SIGNAL" breaks ia64 boot
Message-Id: <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf>
In-Reply-To: <20210222230519.73f3e239@sf>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Sergei Trofimovich <slyich@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 2/22/21 4:05 PM, Sergei Trofimovich wrote:
> Hia Jens!
>=20
> Tried 5.11 on rx3600 box and noticed it has
> a problem handling init (5.10 booted fine):
>=20
> INIT: version 2.98 booting
>=20
>    OpenRC 0.42.1 is starting up Gentoo Linux (ia64)
>=20
> mkdir `/run/openrc': Read-only file system
> mkdir `/run/openrc/starting': No such file or directory
> mkdir `/run/openrc/started': No such file or directory
> mkdir `/run/openrc/stopping': No such file or directory
> mkdir `/run/openrc/inactive': No such file or directory
> mkdir `/run/openrc/wasinactive': No such file or directory
> mkdir `/run/openrc/failed': No such file or directory
> mkdir `/run/openrc/hotplugged': No such file or directory
> mkdir `/run/openrc/daemons': No such file or directory
> mkdir `/run[   14.595059] Kernel panic - not syncing: Attempted to kill i=
nit! exitcode=3D0x0000000b
> [   14.599059] ---[ end Kernel panic - not syncing: Attempted to kill ini=
t! exitcode=3D0x0000000b ]---
>=20
> I suspect we build bad signal stack frame for userspace.
>=20
> With a bit of #define DEBUG_SIG 1 enabled the signals are SIGCHLD:
>=20
> [   34.969771] SIG deliver (gendepends.sh:69): sig=17 sp`000fffff6aeaa0 i=
p=A000000000040740 handler=000000004b4c59b6
> [   34.969948] SIG deliver (init:1): sig=17 sp`000fffff1ccc50 ip=A0000000=
00040740 handler=000000004638b9e5
> [   34.969948] SIG deliver (gendepends.sh:69): sig=17 sp`000fffff6adf90 i=
p=A000000000040740 handler=000000004b4c59b6
> [   34.973948] SIG deliver (init:1): sig=17 sp`000fffff1cc140 ip=A0000000=
00040740 handler=000000004638b9e5
> [   34.973948] Kernel panic - not syncing: Attempted to kill init! exitco=
de=3D0x0000000b
> [   34.973948] SIG deliver (gendepends.sh:69): sig=17 sp`000fffff6ad480 i=
p=A000000000040740 handler=000000004b4c59b6
> [   34.973948] ---[ end Kernel panic - not syncing: Attempted to kill ini=
t! exitcode=3D0x0000000b ]---
>=20
> Bisect points at:
>=20
> commit b269c229b0e89aedb7943c06673b56b6052cf5e5
> Author: Jens Axboe <axboe@kernel.dk>
> Date:   Fri Oct 9 14:49:43 2020 -0600
>=20
>     ia64: add support for TIF_NOTIFY_SIGNAL
>=20
>     Wire up TIF_NOTIFY_SIGNAL handling for ia64.
>=20
>     Cc: linux-ia64@vger.kernel.org
>     [axboe: added fixes from Mike Rapoport <rppt@kernel.org>]
>     Signed-off-by: Jens Axboe <axboe@kernel.dk>
>=20
> diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/=
thread_info.h
> index 64a1011f6812..51d20cb37706 100644
> --- a/arch/ia64/include/asm/thread_info.h
> +++ b/arch/ia64/include/asm/thread_info.h
> @@ -103,6 +103,7 @@ struct thread_info {
>  #define TIF_SYSCALL_TRACE      2       /* syscall trace active */
>  #define TIF_SYSCALL_AUDIT      3       /* syscall auditing active */
>  #define TIF_SINGLESTEP         4       /* restore singlestep on return t=
o user mode */
> +#define TIF_NOTIFY_SIGNAL      5       /* signal notification exist */
>  #define TIF_NOTIFY_RESUME      6       /* resumption notification reques=
ted */
>  #define TIF_MEMDIE             17      /* is terminating due to OOM kill=
er */
>  #define TIF_MCA_INIT           18      /* this task is processing MCA or=
 INIT */
> @@ -115,6 +116,7 @@ struct thread_info {
>  #define _TIF_SINGLESTEP                (1 << TIF_SINGLESTEP)
>  #define _TIF_SYSCALL_TRACEAUDIT        (_TIF_SYSCALL_TRACE|_TIF_SYSCALL_=
AUDIT|_TIF_SINGLESTEP)
>  #define _TIF_NOTIFY_RESUME     (1 << TIF_NOTIFY_RESUME)
> +#define _TIF_NOTIFY_SIGNAL     (1 << TIF_NOTIFY_SIGNAL)
>  #define _TIF_SIGPENDING                (1 << TIF_SIGPENDING)
>  #define _TIF_NEED_RESCHED      (1 << TIF_NEED_RESCHED)
>  #define _TIF_MCA_INIT          (1 << TIF_MCA_INIT)
> @@ -124,7 +126,7 @@ struct thread_info {
>=20
>  /* "work to do on user-return" bits */
>  #define TIF_ALLWORK_MASK       (_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_=
SYSCALL_AUDIT|\
> -                                _TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE)
> +                                _TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|_TI=
F_NOTIFY_SIGNAL)
>  /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT=
 */
>  #define TIF_WORK_MASK          (TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRACE|_T=
IF_SYSCALL_AUDIT))
>=20
> diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
> index 6b61a703bcf5..8d4e1cab9190 100644
> --- a/arch/ia64/kernel/process.c
> +++ b/arch/ia64/kernel/process.c
> @@ -171,7 +171,8 @@ do_notify_resume_user(sigset_t *unused, struct sigscr=
atch *scr, long in_syscall)
>         }
>=20
>         /* deal with pending signal delivery */
> -       if (test_thread_flag(TIF_SIGPENDING)) {
> +       if (test_thread_flag(TIF_SIGPENDING) ||
> +           test_thread_flag(TIF_NOTIFY_SIGNAL)) {
>                 local_irq_enable();     /* force interrupt enable */
>                 ia64_do_signal(scr, in_syscall);
>=20
> which looks benign, but it enables a bit of conditional
> TIF_NOTIFY_SIGNAL handling I don't understand.
>=20
> Can you help me get what is the interaction between
> TIF_NOTIFY_SIGNAL and TIF_SIGPENDING for
> simple processes without io_uring use case?
>=20
> I wonder if it's ia64_do_signal()' generates a signal
> delivery when it should not.

Can you test:

https://marc.info/?l=3Dlinux-ia64&m=161187407609443&w=3D1

with the addition mentioned here:

https://marc.info/?l=3Dlinux-ia64&m=161187470709706&w=3D1

if needed?

--=20
Jens Axboe
