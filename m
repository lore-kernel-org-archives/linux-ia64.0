From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 05 Jan 2001 19:17:52 +0000
Subject: Re: [Linux-ia64] CR[TPR] initialization in test12 kernel
Message-Id: <marc-linux-ia64-105590678205884@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Hirofumi,

>>>>> On Thu, 21 Dec 2000 17:20:12 +0900, Hirofumi Fujita <h-fujita@ebina.hitachi.co.jp> said:

  Hirofumi> Hi, In test12 kernel, CR[TPR] is not initialized for APs
  Hirofumi> (application processors).

  Hirofumi> SAL spec says nothing about it's value at SAL to OS
  Hirofumi> handoff, but we cannot expect it has been set to 0.  So it
  Hirofumi> should be set to 0 when interrupts are enabled in
  Hirofumi> smp_callin().

  Hirofumi> BSP's CR[TPR] is correctly initialized in init_IRQ().

Good point.  I moved the initialization of the CPU-local irq sources
into init_cpu(), where it should have been in the first place.

Thanks!

	--david

