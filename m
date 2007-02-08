From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 08 Feb 2007 07:38:01 +0000
Subject: Re: [RFC Patch]Use ar.kr2 for smp_processor_id
Message-Id: <1170920281.3230.42.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1170905324.3230.7.camel@linux-znh>
In-Reply-To: <1170905324.3230.7.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, 2007-02-08 at 15:14, Zou Nan hai wrote:
> On Thu, 2007-02-08 at 16:40, Keith Owens wrote:
> > Zou Nan hai (on 08 Feb 2007 13:11:49 +0800) wrote:
> > >On Thu, 2007-02-08 at 14:55, Keith Owens wrote:
> > >> Keith Owens (on Thu, 08 Feb 2007 17:37:54 +1100) wrote:
> > >> Correction: ar.k3 contains the physical address of the per-cpu
> data
> > >> area, virtual access to per-cpu data goes via the cpu local TLB
> and
> > >> does not rely on an ar.k<n> variable.  ar.k3 is used in the MCA
> > >> assembler handler, see GET_THIS_PADDR in
> include/asm-ia64/mca_asm.h
> > >> and
> > >> arch/ia64/kernel/mca_asm.S.
> > >>=20
> > >
> > > Since MCA is slow path,=20
> > > so I think put smp_processor_id in ar.kr3 is a gain.
> > >
> > > We could even optimize get_cpu_var based on this...
> >=20
> > (1) Somebody else (not me) gets to fix up and test the MCA handler
> >     assembler code - lots of luck.
> >=20
> > (2) smp_processor_id() in the IA64 kernel is accessed via struct
> >     thread_info.cpu.  That maps to a simple memory access with code
> >     like this:
> >=20
> >        adds r14252,r13
> >        ;;
> >        ld4 r15=3D[r14]
> >=20
> >     The stop bits usually get amortized away with other code.
> >     thread_info.cpu will normally be cached in L1 so reading
> >     smp_processor_id() is relatively fast.
> >=20
> > (3) Reading smp_processor_id() from ar.k3 in the kernel is 10 times
> >     slower than the existing kernel code.  See the timing program
> >     below.
> >=20
> > (4) If the justification for storing cpu number in ar.k<n> is to
> speed
> >     up user space, how can user space tell if the current kernel
> > stores
> >     the physical address of the per-cpu data in k3 or if it stores
> the
> >     cpu number in k3?  Detecting which variant of the kernel is
> > running
> >     will slow down user space.
> >=20
> >=20
> > Timing results on 'modprobe measure'
> >=20
> > init_measure: empty_loop 2000007 cpu_loop 3000011 k3_loop 11999992
> >=20
> > module measure.c
> >=20
> >
> -----------------------------------------------------------------------
> >=20
> > #include <linux/init.h>
> > #include <linux/kernel.h>
> > #include <linux/module.h>
> > #include <linux/preempt.h>
> > #include <asm/kregs.h>
> > #include <asm/timex.h>
> >=20
> > MODULE_LICENSE("GPL");
> >=20
> > #define LOOPS 1000000
> >=20
> > static int __init init_measure(void)
> > {
> >         int loop;
> >         register int cpu;
> >         unsigned long start, end, empty_loop, cpu_loop, k3_loop;
> >         printk("%s: start\n", __FUNCTION__);
> >         preempt_disable();
> >=20
> >         local_irq_disable();
> >         start =3D get_cycles();
> >         barrier();
> >         for (loop =3D 0; loop < LOOPS; ++loop) {
> >                 /* ensure that all loops are the same size (2
> bundles)
> > */
> >                 asm volatile ("nop 0; nop 0; nop 0;");
> >                 barrier();
> >         };
> >         end =3D get_cycles();
> >         barrier();
> >         local_irq_enable();
> >         empty_loop =3D end - start;
> >=20
> >         local_irq_disable();
> >         start =3D get_cycles();
> >         barrier();
> >         for (loop =3D 0; loop < LOOPS; ++loop) {
> >                 /* hand code the read of smp_processor_id() to stop
> > gcc moving
> >                  * the address calculation outside the loop
> >                  */
> >                 asm volatile ("adds r14=3D%0,r13"
> >                               ";;"
> >                               "ld4 r15=3D[r14]"
> >                               : :
> >                               "i" (IA64_TASK_SIZE + offsetof(struct
> > thread_info, cpu)) :
> >                               "r14", "r15" );
> >                 barrier();
> >         };
> >         end =3D get_cycles();
> >         barrier();
> >         local_irq_enable();
> >         cpu_loop =3D end - start;
> >=20
> >         local_irq_disable();
> >         start =3D get_cycles();
> >         barrier();
> >         for (loop =3D 0; loop < LOOPS; ++loop) {
> >                 cpu =3D ia64_get_kr(IA64_KR_PER_CPU_DATA);
> >                 barrier();
> >         };
> >         end =3D get_cycles();
> >         barrier();
> >         local_irq_enable();
> >         k3_loop =3D end - start;
> >=20
> >         preempt_enable();
> >         printk("%s: empty_loop %ld cpu_loop %ld k3_loop %ld\n",
> > __FUNCTION__, empty_loop, cpu_loop, k3_loop);
> >         return 0;
> > }
> >=20
> > static void __exit exit_measure(void)
> > {
> >         printk("%s: start\n", __FUNCTION__);
> >         printk("%s: end\n", __FUNCTION__);
> > }
> >=20
> > module_init(init_measure)
> > module_exit(exit_measure)
> >=20
> >
> -----------------------------------------------------------------------
> >=20
> > objdump of the interesting bits (the three loops):
> >=20
> > empty loop:
> >=20
> >   40:   09 08 00 50 00 21       [MMI]       mov r1=3Dr40
> >   46:   00 00 00 02 00 e0                   nop.m 0x0
> >   4c:   81 6c 64 84                         adds r15272,r13;;
> >   50:   0a 18 00 1e 10 10       [MMI]       ld4 r3=3D[r15];;
> >   56:   20 08 0c 00 42 00                   adds r2=3D1,r3
> >   5c:   00 00 04 00                         nop.i 0x0
> >   60:   0b 00 00 00 01 00       [MMI]       nop.m 0x0;;
> >   66:   00 10 3c 20 23 00                   st4 [r15]=3Dr2
> >   6c:   00 00 04 00                         nop.i 0x0;;
> >   70:   0b 00 00 02 07 00       [MMI]       rsm 0x4000;;
> >   76:   50 02 b0 44 08 00                   mov.m r37=3Dar.itc
> >   7c:   00 00 04 00                         nop.i 0x0;;
> >   80:   0b 70 fc 78 84 24       [MMI]       mov r14=999999;;
> >   86:   00 00 00 02 00 00                   nop.m 0x0
> >   8c:   e0 08 aa 00                         mov.i ar.lc=3Dr14;;
> >   90:   01 00 00 00 01 00       [MII]       nop.m 0x0
> >   96:   00 00 00 02 00 00                   nop.i 0x0
> >   9c:   00 00 04 00                         nop.i 0x0;;
> >   a0:   10 00 00 00 01 00       [MIB]       nop.m 0x0
> >   a6:   00 00 00 02 00 a0                   nop.i 0x0
> >   ac:   f0 ff ff 48                         br.cloop.sptk.few 90
> > <init_module+0x90>
> >   b0:   0b 20 01 58 22 04       [MMI]       mov.m r36=3Dar.itc;;
> >   b6:   00 00 04 0c 00 00                   ssm 0x4000
> >   bc:   00 00 04 00                         nop.i 0x0;;
> >   c0:   0b 00 00 00 30 00       [MMI]       srlz.d;;
> >=20
> > Read smp_processor_id:
> >=20
> >   c6:   00 00 04 0e 00 00                   rsm 0x4000
> >   cc:   00 00 04 00                         nop.i 0x0;;
> >   d0:   01 18 01 58 22 04       [MII]       mov.m r35=3Dar.itc
> >   d6:   00 00 00 02 00 00                   nop.i 0x0
> >   dc:   00 00 04 00                         nop.i 0x0;;
> >   e0:   0a 40 fc 78 84 24       [MMI]       mov r8=999999;;
> >   e6:   00 00 00 02 00 00                   nop.m 0x0
> >   ec:   80 08 aa 00                         mov.i ar.lc=3Dr8
> >   f0:   0b 70 d0 1a 19 21       [MMI]       adds r14252,r13;;
> >   f6:   f0 00 38 20 20 00                   ld4 r15=3D[r14]
> >   fc:   00 00 04 00                         nop.i 0x0;;
> >  100:   10 00 00 00 01 00       [MIB]       nop.m 0x0
> >  106:   00 00 00 02 00 a0                   nop.i 0x0
> >  10c:   f0 ff ff 48                         br.cloop.sptk.few f0
> > <init_module+0xf0>
> >  110:   0b 10 01 58 22 04       [MMI]       mov.m r34=3Dar.itc;;
> >  116:   00 00 04 0c 00 00                   ssm 0x4000
> >  11c:   00 00 04 00                         nop.i 0x0;;
> >  120:   0b 00 00 00 30 00       [MMI]       srlz.d;;
> >=20
> > Read ar.k3:
> >=20
> >  126:   00 00 04 0e 00 00                   rsm 0x4000
> >  12c:   00 00 04 00                         nop.i 0x0;;
> >  130:   01 08 01 58 22 04       [MII]       mov.m r33=3Dar.itc
> >  136:   00 00 00 02 00 00                   nop.i 0x0
> >  13c:   00 00 04 00                         nop.i 0x0;;
> >  140:   0a 48 fc 78 84 24       [MMI]       mov r9=999999;;
> >  146:   00 00 00 02 00 00                   nop.m 0x0
> >  14c:   90 08 aa 00                         mov.i ar.lc=3Dr9
> >  150:   01 70 00 06 22 04       [MII]       mov.m r14=3Dar.k3
> >  156:   00 00 00 02 00 00                   nop.i 0x0
> >  15c:   00 00 04 00                         nop.i 0x0;;
> >  160:   10 00 00 00 01 00       [MIB]       nop.m 0x0
> >  166:   00 00 00 02 00 a0                   nop.i 0x0
> >  16c:   f0 ff ff 48                         br.cloop.sptk.few 150
> > <init_module+0x150>
> >  170:   0b 00 01 58 22 04       [MMI]       mov.m r32=3Dar.itc;;
> >  176:   00 00 04 0c 00 00                   ssm 0x4000
> >  17c:   00 00 04 00                         nop.i 0x0;;
> >  180:   01 00 00 00 30 00       [MII]       srlz.d
> >=20
> =20
> Ok,=20
>   I think using a static value to cache getcpu will heavily bounced on
> that cache line contain the static value if multi cpus calls getcpu
> very
> frequently.=20
>=20
>   then implement current_thread_info()->cpu in fsys call should be
> better?
>=20
> Thanks
> Zou Nan hai
>  =20
>=20
  Maybe let glibc caches CPU ID and Node ID in thread locale storage
will be better?

Zou Nan hai
> =20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
