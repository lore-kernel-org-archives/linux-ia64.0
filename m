From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Sun, 09 Nov 2003 18:57:22 +0000
Subject: Re: problem in booting HP zx6000 with stock kernel 2.5.75
Message-Id: <marc-linux-ia64-106840426422921@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 09 Nov 2003 17:00:12 +0100, "Deepak Kumar Gupta, Noida" <dkumar@noida.hcltech.com> said:

  Deepak> Hello everybody I am trying to boot 2 CPU hp zx6000 machine
  Deepak> (ia64, itanium2) from STOCK kernel version 2.5.75. I have
  Deepak> followed following steps.

2.5.75?  Why such an old kernel?

  Deepak> Kindly provide me appropriate guidance.. , where am I wrong?

For a zx6000, you're better off configuring it as ZX1 system, rather
than GENERIC.  The latter should also work, but will be (slightly)
less efficient (and the kernel will be needlessly bigger).

  Deepak> I have following doubts: -

  Deepak> 1. Is it possible to build and run _stock_ kernel (not
  Deepak> redhat patched kernel, as redhat advanced distribution is
  Deepak> available on my machine) on hp zx6000 machine ?

Yes, but you do need something newer than 2.5.75.  Try 2.6.0-test9.

  Deepak> Do I need additional patches the stock kernel + ia64 patch ?

No patch is needed.  There still is a patch, but if you don't care
about the last drop of performance and/or early printk-support, you
don't need it.

BTW: The daily build-status of Linus' kernel tree can be found here:
       http://www.gelato.unsw.edu.au/kerncomp/
     You can also get know-to-be-good .config files from there.

Also, in the future you may want to use linux-ia64@vger.kernel.org for
such question, since that mailing list is focused on ia64.

	--david
