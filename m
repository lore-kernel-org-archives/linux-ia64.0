From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 21 Mar 2002 21:30:54 +0000
Subject: Re: [Linux-ia64] [piet@sgi.com: Re: kernel make install - why don't we make it easy like on ia32?]
Message-Id: <marc-linux-ia64-105590701905317@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905310@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905310@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 20 Mar 2002 22:51:32 -0800, 
Piet/Pete Delaney <piet@sgi.com> wrote:
>How do I build: 
>
>	/boot/module-info-${KERNELRELEASE}
>	/boot/kernel.h-${KERNELRELEASE}

Redhat special files, not part of the kernel build.

>	/boot/initrd-${KERNELRELEASE}

mkinitrd, if you really insist.  initrd is useful for distributors and
when you need a binary only module at boot time.  Otherwise initrd is a
pain in the neck, build boot drivers into the kernel instead.


