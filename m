From: "E. Focht" <focht@ess.nec.de>
Date: Thu, 14 Dec 2000 14:36:29 +0000
Subject: Re: [Linux-ia64] binary kernel module build flags
Message-Id: <marc-linux-ia64-105590678205843@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Please don't drop the A-stepping support too early! Most of our machines
and half of our processors are still A3 step! And they probably won't be
upgraded before February 2001.

> You shouldn't worry about A-step or B0-step processors unless you personally
> are still using them because you haven't gotten upgrades yet.  I'd like to
> eliminate the compiler -ma-step option before gcc3 comes out, which means it
> won't be in the next compiler release.  Meanwhile, if you must use A-step or
> B0-step processors, then you must use the -ma-step compiler option. Otherwise,
> I recommend using -mb-step for now, which will support B1 and higher processor
> steppings.

Why and when do you want to remove the -ma-step option?

> The current round of OS releases are coming out with B step kernel support only
> by default, and A step support is provided with an optional kernel (TurboLinux)
> or not at all (Red Hat).

As far as I understand, Turbolinux boots the uniprocessor kernel on A-step
CPUs but it's config file stored in the configs directory doesn't have
A-stepping support enabled. The beta2 TurboLinux distribution raises
serious problems, one must recompile kernel and toolchain in order to be
able to work without crashing every few minutes on an A3 stepping
CPU. And I'm not using X or GNOME...

Regards,
Erich


