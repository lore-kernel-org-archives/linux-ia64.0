From: Grant Grundler <iod00d@hp.com>
Date: Wed, 05 May 2004 15:36:56 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <20040505153656.GD9752@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 05, 2004 at 09:57:41AM -0500, Mario Smarduch wrote:
> But there are cases where
> kernel values just need to be read timely.

Watching kernel data from userspace is an impossible task.
Unless one has a "real time" scheduler and *halts* all kernel
activity, the kernel values visible to user space will lag
what the kernel does. Something like KGDB can do that.
It's not something I expect to work correctly.
Ergo define an interface (eg gettimeofday() or /proc/sys/kernel/*)
to get "sane" values and move on.

> As things
> are right now you can still corrupt the kernel but
> are unable to do anything useful because of attribute
> aliasing to that range. Perhaps a rejection of mapping
> such regions for writes should be imposed,

Maybe. I don't understand the VM well enough.

> but I'm
> not sure how mapping it as uncachable helps?
> To me this behaviour seems buggy.

I'm still inclined to think the approach is wrong.
Maybe you have a better test case that doesn't involve user
interaction and shows why the data has to come from /dev/kmem?

grant
