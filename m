From: Alex <lausgans@gmail.com>
Date: Thu, 04 Dec 2014 08:16:45 +0000
Subject: Re: Rebuilding a kernel for a proprietary closed-source ia64 module: possible or not?
Message-Id: <loom.20141204T091415-758@post.gmane.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAA9xbM4fj75nf0=EX7W-6PWZn=SitQSk4htbJXx2wijPPF1yhA@mail.gmail.com>
In-Reply-To: <CAA9xbM4fj75nf0=EX7W-6PWZn=SitQSk4htbJXx2wijPPF1yhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Isn't it a /src/linux-rtgfx-2.6.5-7.244-obj/ia64/rtgfx/.config
> from the kernel-rtgfx-source-2.6.5-7.244.ia64.rpm?
> 
> Please note that it's for sgi machines, not hp ones:
> # CONFIG_IA64_HP_ZX1 is not set
> CONFIG_IA64_SGI_SN2=y
> So it's not usable as is

And CONFIG_MODVERSIONS=n is your solution to running proprietary
modules without their recompilation on a different kernel.



