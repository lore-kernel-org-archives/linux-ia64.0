From: Gururaj Ananthateerta <gururaj@cup.hp.com>
Date: Tue, 13 Nov 2001 01:20:47 +0000
Subject: Re: [Linux-ia64] adding new network device driver
Message-Id: <marc-linux-ia64-105590698805484@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805461@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805461@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Updated Space.c and compiled the kernel. 
The proble is called and my device is identified and configured. But there
is some problem.
There are 2 ethernet devices (including mine) 1 is Intel EEpro100 and
mine (gigabit controller). When the kernel boots it recognizes my NIC and
EEpro100 NIC and hangs. I am unable to figure out whats going on. 
There is some confusions with  ehto and eth1 that I am unable to follow.

> On Fri, 9 Nov 2001 16:08:06 -0800 (PST), 
> Gururaj Ananthateerta <gururaj@cup.hp.com> wrote:
> >When I boot with new kernel my driver probe routine is not entered. 
> >Is there anyplace I need to inform the kernel about the existence 
> >of the new driver.
> 
> linux/Documentation/DocBook/kernel-hacking.tmpl, __initcall and friends.
> 
> 


