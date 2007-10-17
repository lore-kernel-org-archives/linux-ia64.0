From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 17 Oct 2007 19:55:45 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <471668C1.7000706@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Petr Tesarik wrote:
>[...]
>   2. You must couple it with the (planned) changes to ptrace,
> because otherwise PTRACE_{PEEK,POKE}{TEXT,DATA} still access the kernel
> RBS, but it gets later overwritten back from userspace when it is synced.

I have verified that failing to do so breaks "strace -f", because strace
relies on intercepting the clone() system call and setting the
CLONE_PTRACE bit in the flags argument. Of course, if the bit is only
set in the kernel RBS, which is overwritten with the (old) value from
the user RBS on a PTRACE_CONT, the new process is not traced.

Regards,
Petr Tesarik
