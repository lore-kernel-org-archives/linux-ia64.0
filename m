From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 16 Feb 2001 19:48:52 +0000
Subject: RE: [Linux-ia64] Intermittent errors on mov rr
Message-Id: <marc-linux-ia64-105590693005163@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005157@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005157@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 16 Feb 2001 11:12:16 -0800, "Jim Hull" <jim_hull@hp.com> said:

  Jim> The fault happens because you are attempting to use a rid value which
  Jim> requires 19 bits, but Itanium only supports 18-bit rids (the minimum
  Jim> required by the architecture).  The implemented rid size is returned by
  Jim> PAL_VM_SUMMARY, which you can examine with:

  Jim> cat /proc/pal/cpu0/vm_info | grep RR.rid

  Jim> I know nothing about how IA-64 Linux manages rid values,
  Jim> whether it makes use of the rid size field returned by
  Jim> PAL_VM_SUMMARY, etc., so I can't help you any more than this.
  Jim> Probably David Mosberger can track down the root cause of this
  Jim> problem.

Linux reads PAL_VM_SUMMARY and sets the limit accordingly.  On
Itanium, the limit should be 0x8000-1 (18-3 bits) and that's what I
see:

	kdb> md ia64_ctx
	e000000000abe6e8: 00000000 00006a02 00008000 00007fff  .....j.........
						     ^^^^^^^^

Keith, can you verify that you get the right value here as well?

	--david

