From: Mike Weiss <weiss@roguewave.com>
Date: Thu, 22 Jun 2000 18:55:18 +0000
Subject: RE: [Linux-ia64] new Red Hat Linux for IA-64 available
Message-Id: <marc-linux-ia64-105590678205175@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205167@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205167@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

With a flat ATA disk, I run 'eli vmlinux' from the CD efi filesystem, just
like with TL. <--this gives me the "no root" panic, I then try 'eli vmlinux
root=/dev/hdc' this gives the init panic. I have no idea whats wrong.

Mike

-----Original Message-----
From: Bill Nottingham [mailto:notting@redhat.com]
Sent: Thursday, June 22, 2000 11:50 AM
To: linux-ia64@linuxia64.org; 'ia64-list@redhat.com'
Subject: Re: [Linux-ia64] new Red Hat Linux for IA-64 available


Mike Weiss (weiss@roguewave.com) said: 
> I have been having trouble installing this release, when nothing is passed
> to the kernel I get a message stating no root, when I specify
> 'root=/dev/hdc' it says no init found, 'init=/sbin/init' has no effect on
> this. Does anyone have any suggestions as to what I'm doing wrong?

How are you booting?  You should just boot by running 'eli' and choosing
the default image; unfortunately, you can't yet pass the proper arguments
(initrd name) to the boot loader on the command line.

Bill

_______________________________________________
ia64-list mailing list
ia64-list@redhat.com
http://listman.redhat.com/mailman/listinfo/ia64-list


