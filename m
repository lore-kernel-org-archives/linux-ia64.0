From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 17 Nov 2003 17:16:01 +0000
Subject: RE: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106908979932384@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106901123527791@msgid-missing>
In-Reply-To: <marc-linux-ia64-106901123527791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 	- the IRQ masks are displayed in an unusual format:
> 		# echo 12345678 >prof_cpu_mask
> 		# cat prof_cpu_mask
> 		5678123400000000

Although it's ugly ... that format seems to have been adopted in
generic code ... here's the code from drivers/base/node.c to
display the bitmap of cpus that belong to a node:

        for (k = 0; k < sizeof(cpumask_t)/sizeof(u16); ++k) {
                int j = sprintf(buf, "%04hx", (u16)cpus_coerce(tmp));
                len += j;
                buf += j;
                cpus_shift_right(tmp, tmp, 16);
        }

There should be some consistency in how bitmaps from cpumask_t
get displayed, but it would also be nice if the 'write' interfaces
to settable cpumasks used the same format that the 'read'
interfaces printed.  E.g. I might want to do:

 # cat /sys/devices/system/node/node0/cpumap > /proc/irq/prof_cpu_mask

-Tony
