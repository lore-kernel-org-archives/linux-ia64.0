From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Dec 2005 06:15:57 +0000
Subject: RE: Reading /proc/stat is slooow
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05204A1E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1x0v4cpy.fsf@sykes.suse.de>
In-Reply-To: <je1x0v4cpy.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The huge bulk of the time is consumed in this loop:

#if !defined(CONFIG_PPC64) && !defined(CONFIG_ALPHA)
        for (i = 0; i < NR_IRQS; i++)
                seq_printf(p, " %u", kstat_irqs(i));
#endif

But why is this worse now than in 2.6.13?  At the top of
show_stat() we already looked at all of the kstat_cpu(i).irqs[j]
elements [but with the loops reversed: outer loop is all cpus,
inner loop counts 0..NR_IRQ].

-Tony
