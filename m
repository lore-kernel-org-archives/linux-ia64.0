From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Tue, 26 Jun 2001 17:11:18 +0000
Subject: RE: [Linux-ia64] Re: volatile unsigned long cpu_online_map vs uns
Message-Id: <marc-linux-ia64-105590693005775@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005772@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005772@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

cpu_online_map gets used and defined only for SMP configurations.  We will
need to remove the definition of cpu_online_map from setup.c as it is
defined in smpboot.c.  For setup.c, cpu_online_map is done extern in smp.h
(...change to volatile there..)

Below is the patch for setup.c


--- kernel/setup.c      Fri Jun  1 15:15:53 2001
+++ /tmp/setup.c        Tue Jun 26 09:46:40 2001
@@ -60,10 +60,6 @@
 /* This tells _start which CPU is booting.  */
 int cpu_now_booting;

-#ifdef CONFIG_SMP
-volatile unsigned long cpu_online_map;
-#endif
-
 unsigned long ia64_iobase;     /* virtual address for I/O accesses */

 #define COMMAND_LINE_SIZE      512


-----Original Message-----
From: Andreas Schwab [mailto:schwab@suse.de]
Sent: Tuesday, June 26, 2001 9:57 AM
To: David Mosberger
Cc: linux-ia64@linuxia64.org
Subject: [Linux-ia64] Re: volatile unsigned long cpu_online_map vs
unsigned long cpu_online_map


Bill Nottingham <notting@redhat.com> writes:

|> David Mosberger (davidm@hpl.hp.com) said:=20
|> >   Andreas> include/asm-ia64/smp.h has 'extern unsigned long
|> >   Andreas> cpu_online_map', but arch/ia64/kernel/setup.c and
|> >   Andreas> arch/ia64/kernel/smpboot.c have 'volatile unsigned long
|> >   Andreas> cpu_online_map'.  Which one is correct?
|> >=20
|> > It should be volatile.
|>=20
|> Also, shoudn't it be extern in at least one of setup.c/smpboot.c?

No.  The definition in setup.c is guarded by CONFIG_SMP, and smpboot.c is
not use on non-SMP.

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


