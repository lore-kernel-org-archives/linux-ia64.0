From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 May 2003 22:47:33 +0000
Subject: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705915@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 16 May 2003 15:33:30 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> Here's a first crack at the missing fs/proc/kcore.c part of
  Tony> relocating the kernel.

  Tony> Not as pretty as I'd hoped ... just having your kernel at a
  Tony> lower address than your modules isn't sufficient to fit with
  Tony> what the code currently does (which is to assume that your
  Tony> kernel is in the 1-1 area above PAGE_OFFSET).

  Tony> Perhaps it might be cleaner to add the kernel to the vmlist
  Tony> (as somebody suggested before)?  That would get rid of almost
  Tony> all the changes except one ... we'd still need to set
  Tony> KCORE_BASE to the start address of region 5, so any
  Tony> suggestions on how to do that in a cleaner way than #ifdef
  Tony> CONFIG_IA64 gratefully accepted.

Well, the patch looks fine to me, so I'm probably the wrong person to
ask.  Might be good to bring this up on linux-kernel.

Was there a particular reason to send the full file instead of just a
diff?  Also, your file seems to revert the ANSI 99 initializer changes
for no good reason.

	--david

