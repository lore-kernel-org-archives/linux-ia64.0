From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 Aug 2002 04:37:43 +0000
Subject: [Linux-ia64] Re: A comment on the 2.5.29 patch
Message-Id: <marc-linux-ia64-105590701905924@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 8 Aug 2002 13:38:03 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi David,

  Peter> The change to drivers/char/mem.c doesn't look right --- it forces a
  Peter> successful system call even when there's been an error.

  Peter> --- a/drivers/char/mem.c	Thu Aug  1 01:08:13 2002
  Peter> +++ b/drivers/char/mem.c	Thu Aug  1 01:08:13 2002
  Peter> @@ -518,6 +518,7 @@
  Peter> default:
  Peter> ret = -EINVAL;
  Peter> }
  Peter> +	force_successful_syscall_return();
  Peter> unlock_kernel();
  Peter> return ret;
  Peter> }

  Peter> Surely that should only be when ret != -EINVAL ???  You could move it
  Peter> inside the switch, although that's ugly.

Yes, that's a bug, probably due to a bad merge.  Please understand
that the 2.5.29 is works-in-progress; there really is a large number
of outstanding things, so don't expect everything to be all-right.

  Peter> I can't see the point of moving the declaration of extern irq_desc_t
  Peter> irq_desc [NR_IRQS]; from include/linux/irq.h into asm-i386/hw_irq.,

The idea is simple: remove irq_desc[] and replace it with an irq_desc()
macro, so that platforms have the option to implement the table any way
they see fit (e.g., distributed across NUMA nodes).

  Peter> And my remaining comment is that I'm not sure why the changes to the
  Peter> softirq() names were made.  A rose by any name would smell as sweet...

Specifics please?  There are no just-for-fun renames, but again, it
could be a bad merge or something along those lines.

	--david

