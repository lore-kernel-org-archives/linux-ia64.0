From: Uros Prestor <uros@turbolinux.com>
Date: Thu, 14 Dec 2000 18:26:50 +0000
Subject: Re: [Linux-ia64] binary kernel module build flags
Message-Id: <marc-linux-ia64-105590678205844@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, 14 Dec 2000, E. Focht wrote:

> Please don't drop the A-stepping support too early! Most of our machines
> and half of our processors are still A3 step! And they probably won't be
> upgraded before February 2001.

The support for A-stepping processors seriously limits the amount of
optimizations you can do.  It's not just the workarounds in the kernel,
it's also the fact that you can't use optimized memory copy routines, for
example.  You should really work with Intel to get your boxes upgraded.

> As far as I understand, Turbolinux boots the uniprocessor kernel on A-step
> CPUs but it's config file stored in the configs directory doesn't have
> A-stepping support enabled. The beta2 TurboLinux distribution raises
> serious problems, one must recompile kernel and toolchain in order to be
> able to work without crashing every few minutes on an A3 stepping
> CPU. And I'm not using X or GNOME...

The A-step support in Beta2 was included just to help with the
install.  It was not thoroughly tested (we don't have any A-step boxes
anyway).  The config files included with kernel-source are for the regular
kernels.  The only difference for the install kernel was to enable the
A-step workarounds.

You are right that you need to recompile the kernel and the
toolchain.  You should probably recompile the glibc as well (and remove
the optimized memory copy routines).

Uros



