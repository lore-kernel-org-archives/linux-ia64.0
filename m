From: root <davidm@hpl.hp.com>
Date: Tue, 12 Jun 2001 16:23:32 +0000
Subject: Re: [Linux-ia64] IO/TLB bounce buffer space
Message-Id: <marc-linux-ia64-105590693005718@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005716@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005716@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 12 Jun 2001 10:44:12 +0200 (CEST), Martin Wilck <Martin.Wilck@fujitsu-siemens.com> said:

  Martin> it is becoming apparent that the limited bounce buffer space
  Martin> is the reason for the crashes with the new aic7xxx driver
  Martin> and linux-IA64 with >=4GB RAM that I reported previously.

  Martin> If I understand it right, the driver uses up to 253 buffers
  Martin> per device, each of which can be 8kB in size. Consequently,
  Martin> it almost completely fills up the available IO/TLB space.

The deeper question is of course: is this really a good idea?  From a
latency perspective, such long queues may not make a lot of sense.
Even from a throughput perspective the benefit of using a 253 entry
queue is probably negligible compared to a shorter queue.  Reading
aic7xxx.h, I get the impression that the author chose 253 as the max
queue length because s/he could.  I don't see anything that suggests
that this length is optimal in any sense.  It might be worth
experimenting with.

  Martin> Question: Would it hurt to increase IO/TLB space on machines
  Martin> with large memory? Would it be possible and make sense to
  Martin> make IO/TLB space size a kernel configuration option?

An alternative is to use GFP_ATOMIC allocation.  I'm not sure that
counts as a "solution" though as it arguably just hides the real
issue.

	--david

