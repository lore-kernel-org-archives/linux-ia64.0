From: dann frazier <dannf@hp.com>
Date: Mon, 13 Sep 2004 18:27:49 +0000
Subject: Re: BUG: 2.6.8/2.6.9  register corruption with PTRACE_SYSCALL
Message-Id: <20040913182749.GE25180@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040913122656.GC30808@frankl.hpl.hp.com>
In-Reply-To: <20040913122656.GC30808@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 13, 2004 at 05:26:56AM -0700, Stephane Eranian wrote:
> To all,
> 
> 
> David and I have tracked down a very nasty bug in the 2.6.8 and higher versions
> of the Linux/ia64 kernel. The bug turned out to be due to the compiler. Here is
> the description of the problem.

Thanks for tracking this down.  If I'm affected, should I expect something
like ls to SEGV when run under strace?  If so, I'm not seeing this problem with
the Debian kernels.  They are built w/ gcc 3.3.4 and have CONFIG_AUDIT
disabled.  I'm running Debian/sid which uses libc6.1 2.3.2.ds1-16.

-- 
---------------------------
dann frazier
Hewlett-Packard
Linux and Open Source Lab
dannf@hp.com

