From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 02 Jun 2004 05:53:28 +0000
Subject: Re: [patch] define pending_irq_cpumask in irq.c and move #endif up wrt #ifdef __ARCH_WANT_SYS_SIGPRO
Message-Id: <16573.27480.6415.603648@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Darren,

>>>>> On Fri, 28 May 2004 11:42:55 +1000, Darren Williams <dsw@gelato.unsw.edu.au> said:

  Darren> When compiling the HP simulator ioapci is not included and
  Darren> defines 'pending_irq_cpumask' for SMP machines, because of
  Darren> this we are getting the following build error on our auto
  Darren> build system: arch/ia64/kernel/built-in.o(.text+0x66e0): In
  Darren> function `irq_affinity_write_proc':
  Darren> arch/ia64/kernel/irq.c:1011: undefined reference to
  Darren> `pending_irq_cpumask'

I applied this now.

  Darren> I have updated it so that generic_defconfig, zx1_defconfig,
  Darren> and the attached simulator config compiles. I have also
  Darren> tested the simulator config with and without SMP and for
  Darren> booting.

OK, I added the config as arch/ia64/configs/sim_defconfig

  Darren> Also if CONFIG_IA32_SUPPORT is not set in the attached
  Darren> config we are getting the follwing errors, I can chase this
  Darren> back to when __ARCH_WANT_foo was introduced to ia64.

  Darren> I think the #endif to #ifdef __ARCH_WANT_SYS_SIGPROCMASK may
  Darren> be out by one routine patch attached.

Indeed.  Thanks for catching this!  I forward the patch the Andrew.

Thanks,

	--david
