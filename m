From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 15 Dec 2001 00:22:42 +0000
Subject: Re: [Linux-ia64] mmio barrier macro
Message-Id: <marc-linux-ia64-105590698805699@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805698@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805698@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch looks wrong to me.  It shouldn't replace __ia64_mf_a() with
platform_mmiob() because this will force the use of mf.a even on
platforms that don't need it for memory-mapped I/O.  Also, how about a
comment explaining exactly what is being ordered with respect to whom
(yes, I know there are many examples in Linux where this hasn't been
done, but I don't think that's a good reason to make the situation
worse).

Thanks,

	--david

