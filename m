From: duraid@fl.net.au
Date: Wed, 30 Jan 2002 06:46:45 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805954@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Quoting Stephane Eranian <eranian@frankl.hpl.hp.com>:


> Just by curiosity, have you looked at the system log in /var/log/messages?

permission denied ;)

> I am guessing your program does some floating point operations.
> Have you seen something about floating-point software assist?

No flops in this code!

> Another potential cause could be unaligned accesses. That you can also see 
> in the system log.

'dmesg' works and sure enough, I get unaligned accesses. But not enough to get
*that* sort of a performance hit, surely? To explain what I'm seeing, each
unaligned access would have to cost 0.05 seconds or so!

        Duraid




-------------------------------------------------
This mail sent through IMP: http://horde.org/imp/

