From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 29 Dec 2003 20:23:16 +0000
Subject: Re: [PATCH] - ia64_ctx.lock deadlock
Message-Id: <marc-linux-ia64-107272962029686@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107253552523782@msgid-missing>
In-Reply-To: <marc-linux-ia64-107253552523782@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 27 Dec 2003 08:27:22 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> I hit a deadlock involving the ia64_ctx.lock. The lock may be
  Jack> taken in interrupt context to process an IPI from
  Jack> smp_flush_tlb_mm.

The patch looks correct to me.

Thanks,

	--david
