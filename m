From: Piet/Pete Delaney <piet@sgi.com>
Date: Thu, 21 Mar 2002 08:18:18 +0000
Subject: Re: [Linux-ia64] [piet@sgi.com: Re: kernel make install - why don't we make it easy like on ia32?]
Message-Id: <marc-linux-ia64-105590701905311@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905310@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905310@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 20, 2002 at 10:51:32PM -0800, Piet/Pete Delaney wrote:
> How do I build: 
> 
> 	/boot/module-info-${KERNELRELEASE}
> 	/boot/kernel.h-${KERNELRELEASE}
> 	/boot/initrd-${KERNELRELEASE}
> 
> In upgrading from RedHat ia64 2.4.9-18 to 2.4.17 and 2.4.18 may require changes in these files.
> I thought linux/arch/i386/boot/Makefile would have been a resonable place to have found out how
> i32 does it but it's not there.
> 
> I had problems last time I tried to run 2.4.17 on my 2.4.7-10 Red Hat 7.2 i386 systems.
> I was wondering of the /boot/module-info file had to be updated or that the stuff in 
> /lib/modules that 'Make modules-install' sets up might need to be tweaked.

The module problem I'm getting in trying to boot a generic 2.4.17 kernel is with /lib/ext3.0. 
It's getting a lot of undefined symbols like:

	getblk_Rsmp_0fdb96c8
	journal_destroy_Rsmp_e6169b31
	register_filesystem_Rsmp_462b6e36
	__wait_on_buffer_Rsmp_e7187873
	generic_read_dir_Rsmp_...
	journal_try_start_Rsmp_...
	journal_check_available_features_Rsmp_...

It fails in /bin/insmod in mounting the /proc filesystem.

Then it fails to mount the (ext3) root filesystem.

The last time I had this on a ia32 laptop I thought the 
problem was with the root being a ext3 filesystem but the
ext3 filesystem being a loadable module. So I updated the
kernel .config file to make ext3 a part of the kernel instead
of a loadable module. I re-installed the modules just to be
safe and the kernel continued to get the same error. The only
thing I didn't do is to do a make mrproper. I'll try that this time.

Any suggestions?

-piet

