From: Grant Grundler <grundler@cup.hp.com>
Date: Sat, 05 Jan 2002 01:31:24 +0000
Subject: Re: [Linux-ia64] Compiling kernel 2.4.17 fails at link stage
Message-Id: <marc-linux-ia64-105590698805743@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Alan Modra wrote:
> It's a kernel bug exposed by recent binutils.  You can either fix the
> kernel by making the references weak, or hack around the problem by
> adding -fnoinhibit-exec to the ld command line.

I had added "-fnoinhibit-exec" to LINKFLAGS in linux/arch/ia64/Makefile
and got:
	ld -f may not be used without -shared
	make: *** [vmlinux] Error 1

So how do I "make references weak"?

thanks,
grant

