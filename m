From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 07 Dec 2001 17:34:47 +0000
Subject: RE: [Linux-ia64] mprotect problem
Message-Id: <marc-linux-ia64-105590698805647@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805634@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805634@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jay,

If you don't have a minimal test program or can't share the source
code, it might be useful to collect a syscall trace.  That way, we
could see what addresses and sizes are involved in the mprotect()
call.  Something like:

	strace -o /tmp/out PROGNAME

should do (I'm assuming your program is not multithreaded; if it is,
you'd need to use the -f option and make sure you're running the
latest version of strace).

If the resulting output is very big, you won't be able to send it to
the mailing list.  You can either trim the output or just make sure
you mail it to me directly (davidm@hpl.hp.com).

Thanks,

	--david


