From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 30 Apr 2002 03:11:08 +0000
Subject: Re: [Linux-ia64] Strange behaviour
Message-Id: <marc-linux-ia64-105590701905541@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905530@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905530@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 26 Apr 2002 04:40:23 +0200 (CEST), Steffen Persvold <sp@scali.com> said:

  Steffen> Hi all, In our lab we have two B2-stepping BigSur (that is
  Steffen> the codename for the 2-cpu ones isn't it ?) machines
  Steffen> running slightly modified RH7.1 2.4.3 kernel with SMP
  Steffen> support (Yes I know, it's unsupported hardware, but they've
  Steffen> worked fine so far). When I do a rather long DMA transfer
  Steffen> with a Dolphin SCI card the machine prints this to the
  Steffen> serial console and stops :

  Steffen> gSelFlashStartAddr : ffe4ffb0

I believe this is a sign that a machine check (or "init") occurred.
Given that B2 is pretty much ancient, I'm not sure there is much
that can be done about it.

  Steffen> I'm curious to what this is, it seems to come from the
  Steffen> machine firmware or something ? Is this related to the beta
  Steffen> HW I have, Linux kernel version or is it something else ?

It's coming from the firmware.  Perhaps an older kernel with B2
support would work better, but then again, a lot of bugs got fixed in
the kernel since then.

	--david

