From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 12 Nov 2001 23:58:06 +0000
Subject: Re: [Linux-ia64] Pagesize is different between IA32 and IA64
Message-Id: <marc-linux-ia64-105590698805479@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

But I think the page size problem with brk() is real and can be fixed
quite easily.  If I understood correctly, the problem is that doing
something along the lines of:

	x = ALIGN_TO_4K(sbrk(8192));
	memset(x, 0xff, 4096);
	brk(x);
	brk(x+4096);	

might preserve the contents of the page at X on under the ia32
subsystem of ia64 when in fact it should be cleared to zero.

Would you be able/interested into looking into this?

	--david

