From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 25 Mar 2003 16:45:56 +0000
Subject: RE: [Linux-ia64] ia64_mca_rendez_int_handler use of hard_smp_processor_id
Message-Id: <marc-linux-ia64-105590723705309@msgid-missing>
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

  David> I don't know either.  Perhaps the original author remembers (Jenna or
  David> Tony, perhaps?).

This code predates me.  I checked with Jenna and she says that it's before
her time too.

<speculation>
That convoluted expression avoids use of the per-cpu mapping, but I can't see
why we'd be scared to use that here, and not be paranoid elsewhere.  How was
smp_processor_id() implemented far back in days of 2.4.0 and before?
</speculation>

-Tony

