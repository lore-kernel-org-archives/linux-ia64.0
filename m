From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Sep 2003 18:06:04 +0000
Subject: RE: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434575413144@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Sep 2003 12:58:59 -0500, "Van Maren, Kevin" <kevin.vanmaren@unisys.com> said:

  Van> That's my view on the fpswa printk's (handle_fpu_swa): they are
  Van> normal, expected, and there is absolutely nothing that can be
  Van> done about them -- so why print a "warning" about them (even if
  Van> it is only 5 per second)?  If nothing else, toggle the meaning
  Van> for IA64_THREAD_FPEMU_NOPRINT: turn it ON for special apps.

So what's wrong with doign prctl --fpemul=silent in the init process?
The flags are inherited across fork().

	--david
