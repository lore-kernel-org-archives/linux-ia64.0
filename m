From: Stephane Eranian <eranian@hpl.hp.com>
Date: Sat, 29 Oct 2005 12:26:29 +0000
Subject: Re: [Perfctr-devel] updated perfmon new code base package available
Message-Id: <20051029122629.GC26745@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051018041556.GJ3614@frankl.hpl.hp.com> <436277EC.8040407@redhat.com>
In-Reply-To: <436277EC.8040407@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Cohen <wcohen@redhat.com>
Cc: perfmon@napali.hpl.hp.com, perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Will,
On Fri, Oct 28, 2005 at 03:11:40PM -0400, William Cohen wrote:
> 
> I have been looking at what changes are required to get oprofile to be 
> able to use the custom sampling format in perfmon2. It looks like there 
> have been some changes between the perfmon and perfmon2. The ia64 
> oprofile support uses the older interface. I don't have easy access to 
> an ia64 machine, so I have been making similar support available on the 
> x86 version.
> 
> I noticed that the older interface passed in "struct pt_regs *regs", but 
> the newer interface does not. The oprofile code extracted the program 
> counter and whether the interrupted process was in kernel or user mode 
> from regs. The newer perfmon interface passes in the instruction 
> pointer, but the information about user/kernel mode is lacking.
> 
> Reading through the perform2 documentation the last argument passed into 
> fmt_handler is a void pointer. The Perfmon2 specification 
> (HPL-2004-200R1.pdf) says:
> 
> data : a pointer to an implementation-specific data structure which may 
> be needed by a handler. For instance, this could point to the 
> interrupted machine state and/or the thread to which the overflow is 
> attributed.
> 
> However, the actual call in linux/perfmon/perfmon.c just passes NULL for 
> it. Would it be possible to pass the regs instead? Why not pass regs to 
> the handler? Was there some thought to allow other data to be passed?
> 
I remember removing it, I just don't remeber why. may I thought that there
was enough information carried by the ip argument (i.e. where you were
interrupted), but I don't see a problmen in passing pt_regs again. The
documentation clearly hints at that. I'll do that in the next patch
for all platforms.

Thanks.

-- 
-Stephane
