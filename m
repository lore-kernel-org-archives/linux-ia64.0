From: Bill Nottingham <notting@redhat.com>
Date: Thu, 22 Jun 2000 18:49:31 +0000
Subject: Re: [Linux-ia64] new Red Hat Linux for IA-64 available
Message-Id: <marc-linux-ia64-105590678205173@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205167@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205167@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike Weiss (weiss@roguewave.com) said: 
> I have been having trouble installing this release, when nothing is passed
> to the kernel I get a message stating no root, when I specify
> 'root=/dev/hdc' it says no init found, 'init=/sbin/init' has no effect on
> this. Does anyone have any suggestions as to what I'm doing wrong?

How are you booting?  You should just boot by running 'eli' and choosing
the default image; unfortunately, you can't yet pass the proper arguments
(initrd name) to the boot loader on the command line.

Bill


