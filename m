From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 03 Jun 2004 22:46:58 +0000
Subject: Re: sched_clock
Message-Id: <16575.43618.900768.859629@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40B4868F.B649611C@nospam.org>
In-Reply-To: <40B4868F.B649611C@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 May 2004 13:59:11 +0200, Zoltan Menyhart <Zoltan.Menyhart_=
AT_bull.net@nospam.org> said:

  Zoltan> Time can go backward.  At least for the IA64 implementation
  Zoltan> where "sched_clock()" overflows.

Yes, you're right, there is an intermediate-result overflow problem in
sched_clock() that I missed.  How does the attached patch work for you?

  Zoltan> Funny results can be obtained in "schedule()". E.g.:

  Zoltan> unsigned long run_time;
  Zoltan> now =3D sched_clock();
  Zoltan> run_time =3D now - prev->timestamp;

  Zoltan> I do think it is a good programming solution to abuse the
  Zoltan> fact that the variables are unsigned, and should
  Zoltan> "sched_clock()" overflow, we would be saved by the "else"
  Zoltan> branch.

Ingo, please correct me if I'm wrong, but I believe the code in
kernel/sched.c assumes that the cycle-counter will NOT overflow for
all practical purposes.  For example, a 64-bit cycle-counter running
at 10GHz would overflow only once every 532,249,697 years.  However,
this assumes that the cycle counter starts at (or near) zero at
boot-time.  I don't think there is any such guarantee on ia64 so
perhaps we should reset AR.ITC to zero on the boot-strap processor at
boot-time (or on all CPUs if the cycle-counters are not synchronized).

Ingo, is there something on x86 that guarantees that the cycle-counter
will start out near zero at boot time?

	--david

=3D=3D=3D arch/ia64/kernel/head.S 1.22 vs edited =3D=3D--- 1.22/arch/ia64/k=
ernel/head.S	Thu May 27 15:44:02 2004
+++ edited/arch/ia64/kernel/head.S	Thu Jun  3 14:36:56 2004
@@ -815,6 +815,36 @@
 	br.ret.sptk.many rp
 END(ia64_delay_loop)
=20
+/*
+ * Return a CPU-local timestamp in nano-seconds.  This timestamp is NOT sy=
nchronized
+ * across CPUs its return value must never be compared against the values =
returned
+ * on another CPU.  The usage in kernel/sched.c ensures that.
+ *
+ * The code below basically calculates:
+ *
+ *   (ia64_get_itc() * local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_=
SHIFT
+ *
+ * except that the multiplication and the shift are done with 128-bit inte=
rmediate
+ * precision so that we can produce a full 64-bit result.
+ */
+GLOBAL_ENTRY(sched_clock)
+	addl r8=3DTHIS_CPU(cpu_info) + IA64_CPUINFO_NSEC_PER_CYC_OFFSET,r0
+	mov.m r9=3Dar.itc		// fetch cycle-counter				(35 cyc)
+	;;
+	ldf8 f8=3D[r8]
+	;;
+	setf.sig f9=3Dr9		// certain to stall, so issue it _after_ ldf8...
+	;;
+	xmpy.lu f10=F9,f8	// calculate low 64 bits of 128-bit product	(4 cyc)
+	xmpy.hu f11=F9,f8	// calculate high 64 bits of 128-bit product
+	;;
+	getf.sig r8=F10		//						(5 cyc)
+	getf.sig r9=F11
+	;;
+	shrp r8=3Dr9,r8,IA64_NSEC_PER_CYC_SHIFT
+	br.ret.sptk.many rp
+END(sched_clock)
+
 GLOBAL_ENTRY(start_kernel_thread)
 	.prologue
 	.save rp, r0				// this is the end of the call-chain
=3D=3D=3D arch/ia64/kernel/time.c 1.41 vs edited =3D=3D--- 1.41/arch/ia64/k=
ernel/time.c	Fri May 14 19:00:12 2004
+++ edited/arch/ia64/kernel/time.c	Thu Jun  3 14:26:19 2004
@@ -45,14 +45,6 @@
=20
 #endif
=20
-unsigned long long
-sched_clock (void)
-{
-	unsigned long offset =3D ia64_get_itc();
-
-	return (offset * local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_SHIFT;
-}
-
 static void
 itc_reset (void)
 {
