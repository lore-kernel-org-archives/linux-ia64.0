From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 18 Jan 2001 02:48:11 +0000
Subject: Re: [Linux-ia64] /proc/pid/mem and stack variables
Message-Id: <marc-linux-ia64-105590693005074@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005037@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005037@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 15 Jan 2001 18:57:56 +0100 (MET), Erich Focht <focht@ess.nec.de> said:

  Erich> A small patch for the file fs/proc/base.c implementing llseek for
  Erich> /proc/PID/mem is appended. It's the same as for /dev/kmem therefore it
  Erich> does only SEEK_SET and SEEK_CUR, not SEEK_END. 

Thanks for the patch, I applied it to my tree and will work on getting
it into Linus's tree.

  Erich> It works for reading from stack pages, positioning is ok but the return
  Erich> value is -1 (which is wrong). Probably because the offsets seem to be
  Erich> negative... Can anybody please tell me why I'm getting the -1 error return
  Erich> though I should get back the huge negative offset?

I added a force_successful_syscall_return() to ensure that a succesful
lseek() returning a "negative" value isn't mistaken as an error.  I
did the same to memory_lseek() in drivers/char/mem.c.  This should
avoid the problem you were seeing.

	--david

