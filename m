From: Keith Owens <kaos@sgi.com>
Date: Sat, 22 Mar 2003 04:12:55 +0000
Subject: [Linux-ia64] ia64_mca_rendez_int_handler use of hard_smp_processor_id
Message-Id: <marc-linux-ia64-105590723705289@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/kernel/mca.c:ia64_mca_rendez_int_handler has

#ifdef CONFIG_SMP
	cpu = cpu_logical_id(hard_smp_processor_id());
#endif
	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_DONE;

All the other code that runs imi_rendez_checkin does so using logical
cpu numbers.  Why does ia64_mca_rendez_int_handler use that convoluted
expression instead of the simpler
	cpu = smp_processor_id();


