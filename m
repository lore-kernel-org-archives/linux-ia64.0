From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 12 Mar 2008 21:42:04 +0000
Subject: RE: [PATCH, RFC] Create 'slot' sysfs attribute in/sys/devices/system/cpu/cpuN/topology/
Message-Id: <1FE6DD409037234FAB833C420AA843ECCBFA9D@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080310222735.GA22619@ldl.fc.hp.com>
In-Reply-To: <20080310222735.GA22619@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>, lenb@kernel.org
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

> include/asm-x86/cpu.h         |    1 +

I assume this slipped in accidentally (though it would
eventually be needed for an x86 version of this patch).

> +#ifdef	topology_slot
> +define_id_show_func(slot);
> +define_one_ro(slot);
> +#define ref_slot_attr			&attr_slot.attr,
> +#else
> +#define ref_slot_attr
> +#endif

This is a bit ugly ... I don't see how to make it better (but
I'm sure that akpm will say "You could just ...", and then
I'll wonder why I didn't think of that).

> +EXPORT_SYMBOL(arch_set_topology_slot);

As the author you get to choose the license ... but there is
strong movement to make new exported symbols GPL only.

When I apply this patch and run it on my tiger, I see a slew
of

	ACPI: Invalid PBLK length [0]

messages on my console during boot and the see

	$ cat /sys/devices/system/cpu/cpu0/topology/slot
	-1

So I guess that the _SUN method isn't there on my machine.

-Tony
