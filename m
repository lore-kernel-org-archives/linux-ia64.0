From: Steven Rostedt <srostedt@redhat.com>
Date: Thu, 18 Dec 2008 14:01:11 +0000
Subject: Re: [RFC 1/2] ftrace porting of ia64
Message-Id: <1229608871.30177.41.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1229570238.28616.31.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1229570238.28616.31.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, 2008-12-18 at 11:25 +0100, Ingo Molnar wrote:
> * Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > ftrace porting of IA64.
> > TBD:
> > 1. I don't how to add unwind info to the assemble code, so please
> > advise.
> > 2. The generic ftrace ring buffer code doesn't handle alignment well.
> > With the patch, kernel will report a lot of unalignment. This is still
> > under investigation.
> 
> hm, that's weird - i recently profiled 64-bit x86 for unaligned accesses 
> and there didnt seem to be many. In any case, feel free to fix any 
> unaligned structure fields by reordering them.

Will x86_64 break if something is aligned by 32 bits?

The records in the buffer use to be 64 bit aligned. They are now 32 bit
aligned. I wonder if we should make that alignment arch specific.

-- Steve


