From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 07 Mar 2001 16:53:43 +0000
Subject: Re: [Linux-ia64] CONFIG_IA64_NEW_UNWIND
Message-Id: <marc-linux-ia64-105590693005256@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 6 Mar 2001 16:48:07 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> I'm running 2.4.0 with a couple of patches on 2-CPU Bigsur.  I
  Tony> have a problem where a cpu apparently hangs when a process
  Tony> dumps core.  The "hang" is caused when do_copy_regs() in
  Tony> arch/ia64/kernel/process.c picks up random values for RSE
  Tony> backing store addresses, and sits in this loop:

  Tony>         for (addr = pt->ar_bspstore; addr < ar_bsp; addr += 8)
  Tony> if (ia64_peek(pt, current, addr, &val) = 0)
  Tony> access_process_vm(current, addr, &val, sizeof(val), 1);

  Tony> for a really long time (last time I caught it "addr" was
  Tony> 0x000003e2_47fbf540 and "ar_bsp" was 0x00006000_00000000
  Tony> ... every call to ia64_peek() failed with EIO ... but I
  Tony> calculated that it would have taken over six weeks to complete
  Tony> the loop).

That's a sign that the unwind info is incorrect.  Are you by chance
trying to use the 3.0 branch of gcc?  There is a known bug in that
compiler that's causing this problem.

  Tony> Looking back at where do_copy_regs() digs these values out of
  Tony> the stack, I think that the problem lies in these lines:

  Tony>         unw_get_sp(info, &sp); pt = (struct pt_regs *) (sp +
  Tony> 16);

  Tony> We pick up a perfectly reasonable "sp" in the first line, but
  Tony> I can't see why the code believes that that there would be a
  Tony> pt_regs structure 16 bytes further up.  I think that the frame
  Tony> looks like this at this point

You missed the call to unw_unwind_to_user().  It rewinds the stack
to the pt-regs structure created on entry to the kernel.

	--david

