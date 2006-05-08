From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 08 May 2006 15:49:44 +0000
Subject: Re: [perfmon] Re: beta of pfmon-3.2 available
Message-Id: <20060508154944.GD19268@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060426145636.GA6819@frankl.hpl.hp.com> <20060503054711.b1734c26.akpm@osdl.org>
In-Reply-To: <20060503054711.b1734c26.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net, Stephane Eranian <eranian@hpl.hp.com>

Andrew,

On Wed, May 03, 2006 at 05:47:11AM -0700, Andrew Morton wrote:
> 
> perfctr was almost-ready-for-merge.  Then it was decided that perfmon was
> the way ahead, and perfctr died.  And now perfmon isn't making progress in
> the kernelwards direction (worse, perfmon is getting bigger, thus making a
> merge harder and harder).  So we now have the worst of all worlds.
> 

I have been very busy cleaning up the code with some help of IBM. In the
last few months the code and was split into multiple C and header files.
The arch-specific modules for X86-64 and i386 have been merged.

I have also recently added a few features based upon requests from users.
For instance, the ability to automatically load PMU description modules. That
simplifies greatly the job of system administrators. I have also been busy talking
to Don Zickus about cleaning up the NMI watchdog timer and its use of performance
counters. He has produced a patch. I don't know if it is in your tree yet. Once that
happens, I will be able to simplify the perfmon code even more. So yes, the code is
changing but I think all of this is going into the direction of the kernel merge.

I have also received new feature requests from people of the SystemTap project.
They want to be able to call the interface from inside the kernel. This will add some
code but I don't anticipate it breaking the user level API. I think we all agree this
is something very useful to have. 

With Will Cohen from Redhat we are also looking at migrating Oprofile entirely over
to perfmon on x86 platforms. This can be accomplished very easily with perfmon. We did
that a long time ago on Itanium. In fact the exact same "glue" code can be shared between
all architectures. We are talking with John Levon about this. It is important that perfmon
provides smooth transition to Oprofile users.

> This is a problem.  I'd suggest that at this time we should be
> concentrating on getting perfmon merged up rather than adding more stuff to
> the out-of-tree version.
> 
I agree with you on this. Except for the recent Systemtap request, I do not think any *major* new
features were added in the last few months. By *major* I mean that changed the user level API
in an incompatbile way.

I may not have posted the full patches on lkml last time I released a patch but I will next time.

> IOW: please send patches ;)
> 
I was on vacation up until today. So I will likely release a new patch within a week.

> And keep sending them.  People want this.
> 
But please keep sending me constructive feeback as well.

-- 
-Stephane
