From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 13 Nov 2000 23:14:54 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test10 and upper?
Message-Id: <marc-linux-ia64-105590678205713@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Actually, it does boot, but the Ethernet card reports that the 
>receiver overflows, and I end up not connected to the net.

If you are seeing:
"eth0: card reports no RX buffers."
"eth0: card reports no resources."
then the same problem has been observed on ia32 machines, and is believed to be
a bug in the eepro100 driver.

Just do something like
	ifconfig eth0 down
	ifconfig eth0 up
and it will go away.  If it doesn't go away, repeat until it does.
Alternatively, you can go into /etc/rc.d/init.d and do
	./network stop
	./network start

I don't know anything about kernel workarounds for the problem.  A kernel
person would have to comment on that.  If there is a kernel problem, then
that might explain why this ethernet problem shows up more frequently on
some kernel versions than others.

Jim

