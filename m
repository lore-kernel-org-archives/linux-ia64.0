From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 29 Dec 2003 21:40:12 +0000
Subject: Re: GL-related crash w/ X 4.3 & kernel 2.6
Message-Id: <marc-linux-ia64-107273408202267@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107272704926812@msgid-missing>
In-Reply-To: <marc-linux-ia64-107272704926812@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 29 Dec 2003 20:51:20 +0000, Matthew Wilcox <willy@debian.org> said:

  >>  You mean you can't use gdb to attach to the CPU-hogging
  >> processes?  My guess would be that the server and the app get
  >> stuck trying to acquire a lock, which is incidentally an area
  >> that the Radeon DRI driver had problems with in the past.

  Matthew> It's certainly consistent with their behaviour -- spinning
  Matthew> waiting for a lock.  I guess the next step is to try a 2.4
  Matthew> kernel so I can see if the kernel is failing to release a
  Matthew> lock or if the X server/application is the one doing the
  Matthew> Bad Thing.

I just tried DRI with a radeon 7000 again and am still getting the
same old error message when inserting the radeon kernel module:

[drm] Initialized radeon 1.9.0 20020828 on minor 0
[drm:radeon_cp_init] *ERROR* radeon_cp_init called without lock held
[drm:radeon_unlock] *ERROR* Process 968 using kernel context 0

This is the same error message I saw on an x86 machine with a radeon
chip.  I don't think AGP is available after this error message, so
something must be different in your setup.  Can you confirm that you
didn't get the same kind of drm error when loading radeon.ko?

	--david
