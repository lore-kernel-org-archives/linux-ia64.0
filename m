From: Richard Henderson <rth@twiddle.net>
Date: Mon, 22 Sep 2003 23:21:23 +0000
Subject: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106427289405560@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106398916511816@msgid-missing>
In-Reply-To: <marc-linux-ia64-106398916511816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 22, 2003 at 12:39:18PM -0700, H. J. Lu wrote:
> Can I get char * from char [300]?

x+0 would work in this case; I'd guess it'd work for most of the
cases that syscalls need to handle.


r~
