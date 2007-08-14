From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 14 Aug 2007 21:10:45 +0000
Subject: RE: BINIT and physical address
Message-Id: <617E1C2C70743745A92448908E030B2A0229FFB9@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <32209efe0708131042p68748b3el85d3ec4d76864244@mail.gmail.com>
In-Reply-To: <32209efe0708131042p68748b3el85d3ec4d76864244@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Some help is needed with debugging of a hang.
> A system hits BINIT once in a while and the processors are all
> spinning on the address 0x00100002C00 and if the HT is off the address
> becomes 0x0020000A80. This is a physical address captured on the bus
> by analyser. How can this address be decoded to find out what are the
> processors are spinning on?

Natalie,

The Linux kernel is typically loaded at physical address 0x400000 (64MB)
in one continuous block.  If that address doesn't exist on your platform
then elilo will get some other 64MB aligned address instead.  You may be
able to tell what is the state on you machine by looking at the TLB 'TR'
registers:
$ cat /proc/pal/cpu0/tr_info

Look at the mappings for ITR0 and DTR0 ... they map the kernel. I
say 'may' because some older systems didn't report TR maps
correctly.

Kernel modules loaded after boot will be all over the place.  You
can easily find the virtual addresses in use with:
$ cat /proc/modules
But there isn't a user-mode accessible way to convert them to
physical addresses.  You could write a small loadable driver to
do this.  It is unlikely that all the modules would end up with
exactly the same physical addresses from one boot to the next,
so you'll need to capture this information before the BINIT hits.

You should also check whether the memory addresses in question
were available for Linux to use.
$ cat /proc/iomem

Unless the addresses are marked as "System RAM" they wouldn't
have been used by Linux ... so if you are spinning there, it
is because they are part of firmware (PAL, SAL, EFI).

-Tony
