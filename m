From: Richard Hirst <rhirst@linuxcare.com>
Date: Tue, 26 Mar 2002 16:06:00 +0000
Subject: Re: [Linux-ia64] kernel make install - why don't we make it easy like on ia32?
Message-Id: <marc-linux-ia64-105590701905339@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905306@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905306@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 19, 2002 at 10:38:02PM -0800, Piet/Pete Delaney wrote:
> I was wondering why the ia32 style of installing boot stuff like 
> /boot/vmlinuz that done in:
> 
> 	arch/i386/boot/Makefile
> and
> 	arch/i386/boot/install.sh
> 
> isn't being done for ia64. 
> 
> I'm thinking of makeing a few tweaks to the ia32 version to copy 
> kernel stuff to /boot and /boot/efi. I've been using a hack on the 
> top level kernel Makefile but it's a hack to do it there. The ia32 
> paradigm seems fine; so why isn't it done for ia64. Even after 
> applying the ia64 patch to linux-2.4.18, a 'make install' in the 
> top level kernel Makefile still breaks.
> 
> What gives?

Note that on Debian ia64 the efi partition is not normally mounted.  The
approach we took was that kernels+initrds are dropped in /boot, and then
we have a script /usr/sbin/elilo, which makes sure the efi partition
contents are up to date.

Richard


