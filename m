From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Mar 2001 00:48:07 +0000
Subject: [Linux-ia64] CONFIG_IA64_NEW_UNWIND
Message-Id: <marc-linux-ia64-105590693005250@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm running 2.4.0 with a couple of patches on 2-CPU Bigsur.

I have a problem where a cpu apparently hangs when a process
dumps core.  The "hang" is caused when do_copy_regs() in
arch/ia64/kernel/process.c picks up random values for RSE
backing store addresses, and sits in this loop:

        for (addr = pt->ar_bspstore; addr < ar_bsp; addr += 8)
                if (ia64_peek(pt, current, addr, &val) = 0)
                        access_process_vm(current, addr, &val, sizeof(val),
1);

for a really long time (last time I caught it "addr" was 0x000003e2_47fbf540
and "ar_bsp" was 0x00006000_00000000 ... every call to ia64_peek() failed
with EIO ... but I calculated that it would have taken over six weeks to
complete the loop).

Looking back at where do_copy_regs() digs these values out of the
stack, I think that the problem lies in these lines:

        unw_get_sp(info, &sp);
        pt = (struct pt_regs *) (sp + 16);

We pick up a perfectly reasonable "sp" in the first line, but I
can't see why the code believes that that there would be a pt_regs
structure 16 bytes further up.  I think that the frame looks like
this at this point

	[high addresses]
	frame for ia64_elf_core_copy_regs() <- "unw_get_sp(info, &sp)"
	switch_stack structure (pushed by unw_init_running)
	unw_frame_info structure (pushed by unw_init_running)
	[low addresses]

The CONFIG_IA64_NEW_UNWIND=n version seems to make more
sense (it just uses the pt_user structure that was passed
to ia64_elf_core_copy_regs()).

A quick scan of 2.4.2 shows no apparent changes here.

Any clues?

-Tony Luck


