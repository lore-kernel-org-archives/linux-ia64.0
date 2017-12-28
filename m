From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 28 Dec 2017 15:04:31 +0000
Subject: Re: [PATCH 4/5] Expand the INIT_SIGNALS and INIT_SIGHAND macros and remove
Message-Id: <alpine.DEB.2.20.1712281559410.1899@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk> <151274831156.9961.11214505146256879075.stgit@warthog.procyon.org.uk>
In-Reply-To: <151274831156.9961.11214505146256879075.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>
Cc: linux-arch@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri, 8 Dec 2017, David Howells wrote:
>  #define INIT_CPU_TIMERS(s)						\
>  	.cpu_timers = {							\
>  		LIST_HEAD_INIT(s.cpu_timers[0]),			\
>  		LIST_HEAD_INIT(s.cpu_timers[1]),			\

That macro is only used in init_task.c Why not moving it there and get rid
of the whole macro maze in the header file?

Thanks,

	tglx

