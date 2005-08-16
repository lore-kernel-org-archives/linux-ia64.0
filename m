From: david mosberger <dmosberger@gmail.com>
Date: Tue, 16 Aug 2005 20:11:17 +0000
Subject: Re: [PATCH] Make sched_clock() work in early boot
Message-Id: <ed5aea4305081613116bd8c15f@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050816195916.GA753838@dragonfly.engr.sgi.com>
In-Reply-To: <20050816195916.GA753838@dragonfly.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I'm somewhat nervous about *requiring* that the per-CPU page be pinned
in the TLB.  Sure, that's how it works today, but if it ever changed,
it would lead to subtle sporadic failures in sched_clock().  Also, I
believe that with your patch applied, sched_clock() would fail (return
0) if a data-debug breakpoint was set on the area that it's reading
and debug-faults are deferred.

  --david

On 8/16/05, Jason Uhlenkott <jasonuhl@sgi.com> wrote:
> Turning on PRINTK_TIME causes us to die in early boot when sched_clock()
> tries to access per-cpu data which isn't set up yet.
>=20
> We can avoid this by doing a speculative load on the per-cpu data and
> just returning zero if we fail.  This matches the way sched_clock()
> appears to behave on most other arches if it gets called before we
> know the cpu frequency.
>=20
> Signed-off-by: Jason Uhlenkott <jasonuhl@sgi.com>
>=20
> Index: linux/arch/ia64/kernel/head.S
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux.orig/arch/ia64/kernel/head.S  2005-0=
8-15 15:54:56.130313231 -0700
> +++ linux/arch/ia64/kernel/head.S       2005-08-16 12:49:23.843747550 -07=
00
> @@ -983,9 +983,10 @@
>         addl r8=3DTHIS_CPU(cpu_info) + IA64_CPUINFO_NSEC_PER_CYC_OFFSET,r0
>         mov.m r9=3Dar.itc         // fetch cycle-counter                 =
         (35 cyc)
>         ;;
> -       ldf8 f8=3D[r8]
> +       ldf8.s f8=3D[r8]
>         ;;
>         setf.sig f9=3Dr9          // certain to stall, so issue it _after=
_ ldf8...
> +       chk.s r8, .recover
>         ;;
>         xmpy.lu f10=F9,f8       // calculate low 64 bits of 128-bit produ=
ct     (4 cyc)
>         xmpy.hu f11=F9,f8       // calculate high 64 bits of 128-bit prod=
uct
> @@ -995,6 +996,10 @@
>         ;;
>         shrp r8=3Dr9,r8,IA64_NSEC_PER_CYC_SHIFT
>         br.ret.sptk.many rp
> +.recover:                      // per-cpu data isn't set up yet,
> +                               // so just return 0.
> +       mov r8=3Dr0
> +       br.ret.sptk.many rp
>  END(sched_clock)
>=20
>  GLOBAL_ENTRY(start_kernel_thread)
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--=20
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
