From: Doug Rabson <dfr@nlsystems.com>
Date: Tue, 30 Apr 2002 13:02:10 +0000
Subject: Re: [Linux-ia64] use of gdb for ia64 kernel debug
Message-Id: <marc-linux-ia64-105590701905542@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905532@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905532@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 29 Apr 2002, David Mosberger wrote:

> >>>>> On Fri, 26 Apr 2002 17:33:37 -0500, Ray Bryant <raybry@engr.sgi.com> said:
>
>   Ray> Is is possible to use an IA32 system as a gdb host and run a
>   Ray> remote debugging session on an IA64 box (e. g. a Big Sur)?
>
> You need a gdb stub in the kernel for doing that.  I seem to recall
> someone wrote such a stub for FreeBSD (or was it NetBSD)?  If so, you
> could use that as a starting point.

There is a 'stub of a stub' in the FreeBSD-current kernel but it certainly
isn't functional on ia64. I don't yet use gdb for kernel debugging on
FreeBSD.

-- 
Doug Rabson				Mail:  dfr@nlsystems.com
					Phone: +44 20 8348 6160



