From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jan 2002 21:24:51 +0000
Subject: Re: [Linux-ia64] PATCH redirectable IRQs
Message-Id: <marc-linux-ia64-105590698805798@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805756@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The new patch looks fine to me, but it requires a change to
linux/irq.h which I'm reluctant to make right now (before making new
changes, I'd like to get the existing stuff merged so that the ia64
kernel builds out of the box).  So we either need to get this change
into Marcelo and Linus' tree or find a way to avoid the change.  Can
you pursue this?

Thanks,

	--david

