From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jan 2002 21:33:16 +0000
Subject: Re: [Linux-ia64] Re: Announce: kdb v2.0 is available for kernel 2.4.17
Message-Id: <marc-linux-ia64-105590698805801@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805789@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805789@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 11 Jan 2002 08:09:14 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> David, can you send these ia64 patches to Marcelo for
  Keith> inclusion in base kernel?  If you are too busy I will package
  Keith> them up and send them.

That would be fine with me.  But could you send me the patch for a
final sanity check before sending it off to Marcelo?

Also, do not send it the linux/mm.h changes.  Due to the multiple
memory attribute issue, I'm not sure the VM_NONCACHED and
VM_WRITECOMBINED are such good ideas (besides, I don't think they're
really needed anymore).

  Keith>   Documentation/Configure.help
  Keith> Documentation/kernel-parameters.txt init/main.c Makefile
  Keith> (second chunk only, adding AFLAGS_KERNEL) include/linux/mm.h
  Keith> (just to reserve the bits) include/linux/prctl.h (reserve the
  Keith> bits) include/linux/time.h kernel/ksyms.c kernel/signal.c
  Keith> kernel/sys.c

  Keith> The list above excludes anything that might affect other
  Keith> architectures.  The patch to ensure that the console
  Keith> variables are contiguous is already in 2.4.18-pre1.

  Keith> I would like to get crc32 in base as well but I believe that
  Keith> another person has been working on this as well.  If you like
  Keith> I will reconcile the two versions and get one crc32 into base
  Keith> kernel.

Matt was working on this.  Is that who you were referring two?  Yes,
there is no reason this patch shouldn't be in 2.4.xx as far as I'm
concerned.

Thanks,

	--david

