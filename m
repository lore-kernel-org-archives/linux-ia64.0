From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 29 Apr 2002 18:36:20 +0000
Subject: Re: [Linux-ia64] use of gdb for ia64 kernel debug
Message-Id: <marc-linux-ia64-105590701905536@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905532@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905532@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 26 Apr 2002 17:33:37 -0500, Ray Bryant <raybry@engr.sgi.com> said:

  Ray> Is is possible to use an IA32 system as a gdb host and run a
  Ray> remote debugging session on an IA64 box (e. g. a Big Sur)?

You need a gdb stub in the kernel for doing that.  I seem to recall
someone wrote such a stub for FreeBSD (or was it NetBSD)?  If so, you
could use that as a starting point.

	--david

