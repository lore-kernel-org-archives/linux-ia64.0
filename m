From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Mar 2003 21:54:05 +0000
Subject: Re: [Linux-ia64] ia64_mca_rendez_int_handler use of hard_smp_processor_id
Message-Id: <marc-linux-ia64-105590723705305@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705289@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705289@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 22 Mar 2003 15:12:55 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> arch/ia64/kernel/mca.c:ia64_mca_rendez_int_handler has
  Keith> #ifdef CONFIG_SMP
  Keith> cpu = cpu_logical_id(hard_smp_processor_id());
  Keith> #endif
  Keith> ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_DONE;

  Keith> All the other code that runs imi_rendez_checkin does so using logical
  Keith> cpu numbers.  Why does ia64_mca_rendez_int_handler use that convoluted
  Keith> expression instead of the simpler
  Keith> cpu = smp_processor_id();

I don't know either.  Perhaps the original author remembers (Jenna or
Tony, perhaps?).

	--david

