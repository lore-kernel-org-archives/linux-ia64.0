From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 26 Dec 2001 22:19:20 +0000
Subject: [Linux-ia64] Re: #ifdef missing in linux/irq_cpustat.h
Message-Id: <marc-linux-ia64-105590698805716@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Dec 2001 18:57:46 +0100 (MET), Erich Focht <efocht@ess.nec.de> said:

  Erich> Hi David, as far as I understand the type irq_cpustat_t is
  Erich> not defined on IA64 therefore the line (in
  Erich> include/linux/irq_cpustat.h):

  Erich> extern irq_cpustat_t irq_stat[]; /* defined in asm/hardirq.h
  Erich> */

  Erich> should probably be inside an #ifndef CONFIG_IA64 block...

Technically, you're correct.  But I don't think the extra declaration
hurts anything.  It is a platform-independent file, so I'm reluctant
to add an #ifdef.  I am working on getting the per-CPU data changes
accepted into the main line tree, but the going is very slow (Linus is
focusing on the bio stuff).  Actually, if someone has a good idea of
implementing fast local access to per-CPU data on x86, I'm all ears,
as this would help getting the changes accepted into the main tree.  I
assume the Sequent/IBM folks have solved this problem for their x86
NUMA machines already?

	--david

