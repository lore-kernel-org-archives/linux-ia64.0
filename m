From: Richard Henderson <rth@twiddle.net>
Date: Sun, 21 Sep 2003 21:04:34 +0000
Subject: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106417831414030@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106398916511816@msgid-missing>
In-Reply-To: <marc-linux-ia64-106398916511816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 19, 2003 at 09:32:18AM -0700, H. J. Lu wrote:
> The basically problem is glibc doesn't store information about what
> the kernel interface is so that it can't efficiently set up parameters
> for system calls. Is there a way to improve the situation?

Use __typeof instead of hard-coding long in the LOAD_ARGS macros.
That's where the extension comes from.


r~
