From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 08 Aug 2000 18:51:37 +0000
Subject: Re: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205278@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 08 Aug 2000 11:26:09 -0700, Uros Prestor <uros@turbolinux.com> said:

  Uros> Why is that?  Our kernels have been compiled with AzusA hacks
  Uros> enabled and we had no problems with our kernels running on
  Uros> BigSurs and Lions.

Any configuration with the string *HACKS* in it should be turned on
only for that machine.  You may get lucky at the moment and the
current AzusA hacks may not cause problems on Lion or BigSur, but I
won't guarantee that it will stay that way.  The AzusA hacks need to
be merged in cleanly with the existing source code so that #define can
go away (eventually, I don't expect this to happen over night).

  Uros> On another note, we are getting a lot more segfaults during
  Uros> builds lately.  The 0505 release which had the 2.3.99-pre6
  Uros> kernel was rock solid; after moving to 2.4.0 kernels the
  Uros> segfaults came back with a vengeance.  We did upgrade
  Uros> processors from A2 to A3 but I don't think this could be a
  Uros> culprit.  Any ideas on this?

Yes, we are seeing similar behavior.  I suspect the kernel's new
memcpy routine.  Can you try the old (and stupid) byte-by-byte copy
routine and let me know if that helps on your machines?

	--david

