From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Thu, 12 Feb 2004 23:12:22 +0000
Subject: Re: How do I raise a thread to realtime priority?
Message-Id: <20040212151222.277cbe9c.rddunlap@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040212215357.GA15214@lnx-holt>
In-Reply-To: <20040212215357.GA15214@lnx-holt>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 12 Feb 2004 16:17:52 -0600 Robin Holt <holt@sgi.com> wrote:

| On Thu, Feb 12, 2004 at 10:08:20PM +0000, Matthew Wilcox wrote:
| > On Thu, Feb 12, 2004 at 03:53:57PM -0600, Robin Holt wrote:
| > > In the 2.4 kernel headers, unistd.h had a _syscall3 that I could
| > > use to make an extern of the sys_sched_setscheduler raise a tasks
| > > priority to realtime.  With 2.6, the _syscall3 has been replaced
| > > with static inlines.  This all seems well.
| > > 
| > > Since sys_sched_setscheduler is not in the unistd.h, should I add
| > > it to unistd.h?  Is there a prefered method for exporting/inlining
| > > syscall entry points?
| > 
| > libc "exports syscall entry points" -- call sched_setscheduler().
| > That works on 2.4 and 2.6.
| 
| Maybe I wasn't clear.  This is a kernel thread that is trying to
| raise priority.

I have patches in progress (in -mm) that add this and other syscalls
to include/linux/syscalls.h (for non-arch-specific) and to
include/asm-*/unistd.h for arch-specific syscalls.

--
~Randy
