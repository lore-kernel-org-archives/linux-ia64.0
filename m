From: Matthew Wilcox <willy@debian.org>
Date: Mon, 05 May 2003 19:42:51 +0000
Subject: Re: [Linux-ia64] [PATCH] Increase size of user stack
Message-Id: <marc-linux-ia64-105590723705640@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705637@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705637@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 05, 2003 at 12:35:03PM -0700, Howell, David P wrote:
> Wouldn't it be better to base this off an rlimit?

PA-RISC (which has an upwards-gorwing stack) bases this off RLIMIT_STACK.
By default, we set it to 80MB.  Of course, sshd likes to set it to -1
(unlimited), so we limit it to 1GB.  ia64 will presumably want to be
more generous in its clamping value.

I think this is all in the 2.5 tree now; if not you can pick up a recent
pa patch at ftp://ftp.kernel.org/pub/linux/kernel/ports/parisc/v2.5/
and look for it.  90% of that diff is drivers/input, so it's not much
to look through.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

