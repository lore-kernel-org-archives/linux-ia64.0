From: Keith Owens <kaos@sgi.com>
Date: Thu, 10 Jan 2002 21:09:14 +0000
Subject: [Linux-ia64] Re: Announce: kdb v2.0 is available for kernel 2.4.17
Message-Id: <marc-linux-ia64-105590698805797@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805789@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805789@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 10 Jan 2002 19:48:26 +0100 (NFT), 
Xavier Bru <Xavier.Bru@bull.net> wrote:
>We must take care that the common KDB patch (kdb-v2.0-2.4.17-common-3)
>conflicts with the IA64 patch on 2.4.17(linux-2.4.17-ia64-011226.diff). (needs to merge both patches).
>I did not notice that first time and got a strange KDB behavior ( kdb_init()
>was not called, and no way to quit kdb after breaking into it ).

That is due to the ia64 patch adding CONFIG_PERMON patches into
init/main.c.  AFAICT there is no reason that this patch cannot be sent
to Marcelo to reduce the footprint of the ia64 patch on common code.

David, can you send these ia64 patches to Marcelo for inclusion in base
kernel?  If you are too busy I will package them up and send them.

  Documentation/Configure.help
  Documentation/kernel-parameters.txt
  init/main.c
  Makefile (second chunk only, adding AFLAGS_KERNEL)
  include/linux/mm.h (just to reserve the bits)
  include/linux/prctl.h (reserve the bits)
  include/linux/time.h
  kernel/ksyms.c
  kernel/signal.c
  kernel/sys.c

The list above excludes anything that might affect other architectures.
The patch to ensure that the console variables are contiguous is
already in 2.4.18-pre1.

I would like to get crc32 in base as well but I believe that another
person has been working on this as well.  If you like I will reconcile
the two versions and get one crc32 into base kernel.


