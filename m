From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 25 Apr 2006 15:20:49 +0000
Subject: Re: I/O read, write implementation questions
Message-Id: <444E3E51.9040403@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <444E2EA6.8000604@bull.net>
In-Reply-To: <444E2EA6.8000604@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger-Tang wrote:

>>Why do not "readb()" ... "writeb()" include "mf.a"-s?
> 
> Again, acceptance is not normally needed by readX/writeX and mf.a is
> extremely expensive (on the order of 1,000 cycles).  If you want
> ordering, you need to use explicit barriers (or rely on the effect of
> "volatile" in ia64-specific code).

Assuming a device driver uses memory mapped I/O, what is the architecture
independent way to make sure that the I/O reads - writes are accepted ?
(I cannot use "__ia64_mf_a()".)

What is the difference between "readb_relaxed()" and "readb()"?
Were not they defined to provide both strict and weak (relaxed)
I/O ordering?


Thanks,

Zoltan
