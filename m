From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 24 Oct 2001 23:21:08 +0000
Subject: Re: [Linux-ia64] framebuffer console
Message-Id: <marc-linux-ia64-105590698805388@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Oct 2001 12:26:59 +0100, Richard Hirst <rhirst@linuxcare.com> said:

  Richard> This patch solves the problem.  Still surprised that cached
  Richard> accesses to the video memory crash the machine though..

My understanding is that Merced doesn't handle cache line sized
transactions to the PCI bus.  Instead of going uncached, you might be
able to use write-combining (for the video framebuffer, not for memory
mapped control registers).  That can give you noticably better
performance.

	--david

