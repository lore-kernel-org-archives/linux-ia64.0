From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 01 Mar 2001 15:29:46 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005231@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

OK, turns out there were two silly typos which I didn't catch because
the simulator configuration was accidentally set for CONFIG_SMP...

Here are the fixes:

--- arch/ia64/kernel/irq_ia64.c~	Wed Feb 28 12:55:54 2001
+++ arch/ia64/kernel/irq_ia64.c	Thu Mar  1 07:08:01 2001
@@ -155,7 +155,9 @@
 init_IRQ (void)
 {
 	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
+#ifdef CONFIG_SMP
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
+#endif
 	platform_irq_init();
 }
=20
--- include/asm-ia64/hardirq.h~	Wed Feb 28 22:35:39 2001
+++ include/asm-ia64/hardirq.h	Thu Mar  1 07:07:18 2001
@@ -41,8 +41,8 @@
 # define local_hardirq_trylock()	(local_irq_count() =3D=3D 0)
 # define local_hardirq_endlock()	do { } while (0)
=20
-# define local_irq_enter(irq)		(local_irq_count(cpu)++)
-# define local_irq_exit(irq)		(local_irq_count(cpu)--)
+# define local_irq_enter(irq)		(local_irq_count()++)
+# define local_irq_exit(irq)		(local_irq_count()--)
=20
 # define synchronize_irq()		barrier()
 #else

I also updated the patch on linux.kernel.org.  The fixed version
has a size of 456023 bytes.

	--david

>>>>> On 01 Mar 2001 11:27:02 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> Andreas Schwab <schwab@suse.de> writes: |> David Mosberger
  Andreas> <davidm@hpl.hp.com> writes: |> |> |> The latest IA-64 patch
  Andreas> is now available at: |> |> |> |>
  Andreas> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ |> |> |>
  Andreas> |> in file linux-2.4.2-ia64-010228.diff* |> |> This doesn't
  Andreas> compile: |> |> irq.c:458:28: too many arguments in
  Andreas> invocation of macro "local_irq_count" |> irq.c:474:27: too
  Andreas> many arguments in invocation of macro "local_irq_count" |>
  Andreas> irq.c: In function `handle_IRQ_event': |> irq.c:458:
  Andreas> `local_irq_count' undeclared (first use in this function)
  Andreas> |> irq.c:458: (Each undeclared identifier is reported only
  Andreas> once |> irq.c:458: for each function it appears in.)

  Andreas> Another bug:

  Andreas> irq_ia64.c: In function `init_IRQ': irq_ia64.c:158:
  Andreas> `ipi_irqaction' undeclared (first use in this function)
  Andreas> irq_ia64.c:158: (Each undeclared identifier is reported
  Andreas> only once irq_ia64.c:158: for each function it appears in.)

  Andreas> Andreas.

  Andreas> -- Andreas Schwab "And now for something SuSE Labs
  Andreas> completely different."  Andreas.Schwab@suse.de SuSE GmbH,
  Andreas> Schanz=E4ckerstr. 10, D-90443 N=FCrnberg Key fingerprint =3D 58CA
  Andreas> 54C7 6D53 942B 1756 01D3 44D5 214B 8276 4ED5

