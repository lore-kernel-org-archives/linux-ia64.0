From: Mario Smarduch <cms063@email.mot.com>
Date: Wed, 05 May 2004 16:32:50 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <40991732.2AA2D922@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote:

> On Wed, May 05, 2004 at 09:57:41AM -0500, Mario Smarduch wrote:
> > But there are cases where
> > kernel values just need to be read timely.
>
> Watching kernel data from userspace is an impossible task.
> Unless one has a "real time" scheduler and *halts* all kernel
> activity, the kernel values visible to user space will lag
> what the kernel does. Something like KGDB can do that.
> It's not something I expect to work correctly.

I've worked with protocol applications (Frame Relay/LAPD)
that used /dev/kmem to synchronize across kernel allocated
buffers to bypass standard system call overhead.  The tasks ran
at highest priority and were locked. I'm not advacating that
kind of use but its been done.

>
> Ergo define an interface (eg gettimeofday() or /proc/sys/kernel/*)
> to get "sane" values and move on.

That's kind of what this is intended for.

- Mario.

>
>
> > As things
> > are right now you can still corrupt the kernel but
> > are unable to do anything useful because of attribute
> > aliasing to that range. Perhaps a rejection of mapping
> > such regions for writes should be imposed,
>
> Maybe. I don't understand the VM well enough.
>
> > but I'm
> > not sure how mapping it as uncachable helps?
> > To me this behaviour seems buggy.
>
> I'm still inclined to think the approach is wrong.
> Maybe you have a better test case that doesn't involve user
> interaction and shows why the data has to come from /dev/kmem?
>
> grant

