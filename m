From: Bill Nottingham <notting@redhat.com>
Date: Thu, 03 May 2001 18:41:48 +0000
Subject: [Linux-ia64] Re: Kernel 2.4.4 compile problems...
Message-Id: <marc-linux-ia64-105590693005532@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mark Buckaway (markb@platespin.com) said: 
> I've install Redhat Wolverine onto our IA64 system (BigSur). I've
> downloaded and "installed" the 2.4.4 kernel source. I've attempting to
> make vmlinux after make menuconfig, and it stops on main.c (errors
> below). BTW, this is the same problem I had with the 2.4.3 plus the
> Apr.5 patch on the previous redhat IA64 release...although I had better
> luck with the SGIPro compiler, but it would not link the kernel. BTW,
> I've wiped the /usr/include/asm and /usr/include/linux directories and
> correctly linked them into the kernel source. Help.

It looks like you're using 2.4.4 without any ia64 patches. I doubt
that will work.

Bill

