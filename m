From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 May 2003 07:25:59 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705753@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 May 2003 09:02:48 +0200, Bruno Vidal <bruno_vidal@hp.com> said:

  Bruno> I've already wrote a dump modules driver for linux-parisc.
  Bruno> This module goal is to create a memory image on a swap area, and
  Bruno> at reboot time to save it to disk with all kernel modules, in
  Bruno> order to analyze it after by "support" people with tools like
  Bruno> gdb/p4. The problem while dumping is that the dump modules
  Bruno> cannot trust anymore the system, so dumping means: no interruption,
  Bruno> no disk driver, no buffer, nothing. The solution is to use low level
  Bruno> call. For parisc I use the IODC calls, for ia64 I think I'll
  Bruno> use the EFI calls. My questions:
  Bruno> -do you think it is a "good" and realistic solution.
  Bruno> -because I think "yes", does exist somewhere an example of
  Bruno> reading/writing with EFI call on disk using BLOCK IO. I've already
  Bruno> looked in elilo, but it seems that it use FS access.

Once the kernel is booted, you can access only the EFI runtime
services (see struct efi in include/linux/efi.h).  I'm afraid there is
no support for writing disk blocks.  Given this limitation, I suspect
you'd have to include your own (simple) disk driver(s).

	--david

