From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 08 Nov 2000 16:46:44 +0000
Subject: Re: [Linux-ia64] re-enabling interrupts and interrupt collect
Message-Id: <marc-linux-ia64-105590678205669@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205670@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205670@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, psr.ic needs to be on before psr.i can be turned on.  That's what
we are doing in ivt.S, for example.  I thought the manual was quite
clear on that topic.

	--david

>>>>> On Wed, 08 Nov 2000 08:28:32 -0500, Jonathan Case Nicklin <nicklin@missioncriticallinux.com> said:

  Jonathan> All, Recently, i was working on a section of code that
  Jonathan> disabled/enable interrupts and interrupt collection like
  Jonathan> so.

  Jonathan>     rsm psr.i | psr.ic ;; ... //body ;; ssm psr.i | psr.ic
  Jonathan> ;; srlz.d ;;

  Jonathan> I found however that this implementation did not work
  Jonathan> under heavy loads.

  Jonathan> It took a while to figure out that a pending interrupt
  Jonathan> that had occurred in the body of code, executed while
  Jonathan> interrupts were turned off, was delivered after the ssm
  Jonathan> call as expected. However, it was delivered before the ic
  Jonathan> bit serialized. In the code this caused undesirable
  Jonathan> results. I found that the proper way to implement the
  Jonathan> above is to re-enable the ic bit and serialize before
  Jonathan> re-enabling the interrupt bit. Has anyone else come across
  Jonathan> this problem and can anybody shed some light on whether
  Jonathan> this is the expected operation.

  Jonathan> Sincerely, Jonathan Case Nicklin

  Jonathan> Mission Critical Linux www.missioncriticallinux.com

  Jonathan> ps. The manual gives an example of the implementation that
  Jonathan> works, but does not provide any explanation of
  Jonathan> implementation itself (as far as I can see ;-P )

