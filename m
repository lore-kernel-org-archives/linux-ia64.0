From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jan 2002 19:07:21 +0000
Subject: Re: [Linux-ia64] latest MCA logging patch
Message-Id: <marc-linux-ia64-105590698805790@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Jenna> include/asm-ia64/sal.h: - Removed spinlock from SAL calls to
  Jenna> conform to SAL spec.

SAL is re-entrant now?

BTW: please do not use save_and_cli() in new code.  Use local_irq_save()
instead.

Thanks,

	--david

