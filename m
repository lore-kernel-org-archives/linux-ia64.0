From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 02 Apr 2002 00:15:25 +0000
Subject: Re: [Linux-ia64] [PATCH] set ar.k0 on APs
Message-Id: <marc-linux-ia64-105590701905356@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 1 Apr 2002 16:54:20 -0700, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  Bjorn> We currently set ar.k0 on the BP, but not on the APs.  The following
  Bjorn> patch does it for APs as well.

  Bjorn> Apparently Intel firmware sets ar.k0, but HP firmware doesn't.
  Bjorn> If the kernel doesn't set ar.k0, X won't start up on APs because
  Bjorn> it uses ar.k0 to access I/O port space.

Sounds good.

  Bjorn> +	/*
  Bjorn> +	 * Set I/O port base per CPU
  Bjorn> +	 */
  Bjorn> +	ia64_set_kr(IA64_KR_IO_BASE, ia64_iobase & ~PAGE_OFFSET);

But you shouldn't mask anything with PAGE_OFFSET (it's a base-address,
not a mask).  __pa() can be used instead.  I see that setup.c had the
same problem, so I cleaned that up as well, plus I made it use
ioremap(), instead of hardcoding the formation of an uncachable
mapping).

Thanks,

	--david

