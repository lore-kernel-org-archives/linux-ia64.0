From: Piet/Pete Delaney <piet@sgi.com>
Date: Thu, 21 Mar 2002 06:51:32 +0000
Subject: [Linux-ia64] [piet@sgi.com: Re: kernel make install - why don't we make it easy like on ia32?]
Message-Id: <marc-linux-ia64-105590701905310@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

How do I build: 

	/boot/module-info-${KERNELRELEASE}
	/boot/kernel.h-${KERNELRELEASE}
	/boot/initrd-${KERNELRELEASE}

In upgrading from RedHat ia64 2.4.9-18 to 2.4.17 and 2.4.18 may require changes in these files.
I thought linux/arch/i386/boot/Makefile would have been a resonable place to have found out how
i32 does it but it's not there.

I had problems last time I tried to run 2.4.17 on my 2.4.7-10 Red Hat 7.2 i386 systems.
I was wondering of the /boot/module-info file had to be updated or that the stuff in 
/lib/modules that 'Make modules-install' sets up might need to be tweaked.

-piet


