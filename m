From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Mon, 12 Sep 2005 16:42:51 +0000
Subject: RE: [RFC] timer_interrupt: Avoid device timeouts by freezing time if system froze
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD802C0681A@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi, Christoph,
	Whether gettimeofday will be influenced and can wall clock catch up later?=
 Seems that time interpolator can compensate for lost jiffies, but I'm not =
sure here. ;-)

Regards,
Kevin
>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-owner@vger.kerne=
l.org]
>On Behalf Of Christoph Lameter
>Sent: 2005=C4=EA9=D4=C210=C8=D5 6:02
>To: linux-ia64@vger.kernel.org
>Subject: [RFC] timer_interrupt: Avoid device timeouts by freezing time if =
system froze
>
>In extraordinay circumstances (MCA init/ debugger invocation, hardware pro=
blems)
>the
>system may not be able to process timer ticks for an extended period of ti=
me.
>
>The timer interrupt will compensate as soon as the system becomes function=
al again
>by
>calling do_timer for each missed tick. This will cause time to race forwar=
d in a very
>fast way. Device drivers that wait for timeouts will find that the system =
times out
>on everything and thus device drivers will conclude that the devices are n=
ot in
>a functional state disabling them. The system then cannot continue from th=
e frozen
>state because the device drivers have given up.
>
>This patch fixes that issue by checking if more than half a second has pas=
sed
>since the last tick. If more than half a second has passed then we would n=
eed to do
>around 500 calls to do_timer to compensate. So in order to avoid these tim=
eouts
>we act as if time has been frozen with the system and do not compensate fo=
r lost
>time.
>Device drivers may still find that their outstanding requests have failed =
but they
>will be able to reinitialize the device and the system can hopefully conti=
nue.
>
>A consequence of this patch is that the wall clock will stand still if the=
 no ticks
>can be processed for more than half a second.
>
>Signed-off-by: Christoph Lameter <clameter@sgi.com>
>
>Index: linux-2.6.13/arch/ia64/kernel/time.c
>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
>=3D>--- linux-2.6.13.orig/arch/ia64/kernel/time.c	2005-08-28 16:41:01.0000=
00000 -0700
>+++ linux-2.6.13/arch/ia64/kernel/time.c	2005-09-09 14:45:37.000000000 -07=
00
>@@ -55,6 +55,7 @@ static irqreturn_t
> timer_interrupt (int irq, void *dev_id, struct pt_regs *regs)
> {
> 	unsigned long new_itm;
>+	unsigned long itc;
>
> 	if (unlikely(cpu_is_offline(smp_processor_id()))) {
> 		return IRQ_HANDLED;
>@@ -64,10 +65,25 @@ timer_interrupt (int irq, void *dev_id,
>
> 	new_itm =3D local_cpu_data->itm_next;
>
>-	if (!time_after(ia64_get_itc(), new_itm))
>+	itc =3D ia64_get_itc();
>+	if (!time_after(itc, new_itm))
> 		printk(KERN_ERR "Oops: timer tick before it's due (itc=3D%lx,itm=3D%lx)=
\n",
> 		       ia64_get_itc(), new_itm);
>
>+	/*
>+	 * If more than half a second has passed since the last timer interrupt =
then
>+	 * something significant froze the system. Skip the time adjustments
>+	 * otherwise repeated calls to do_timer will trigger timeouts by devices.
>+	 */
>+	if (unlikely(time_after(itc, new_itm + HZ /2 * local_cpu_data->itm_delta=
))) {
>+		new_itm =3D itc;
>+		if (smp_processor_id() =3D TIME_KEEPER_ID) {
>+			time_interpolator_reset();
>+			printk(KERN_ERR "Oops: more than 0.5 seconds since last tick."
>+				"Skipping time adjustments in order to avoid timeouts.\n");
>+		}
>+	}
>+
> 	profile_tick(CPU_PROFILING, regs);
>
> 	while (1) {
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
