From: Jonathan Case Nicklin <nicklin@missioncriticallinux.com>
Date: Wed, 08 Nov 2000 13:28:32 +0000
Subject: [Linux-ia64] re-enabling interrupts and interrupt collect
Message-Id: <marc-linux-ia64-105590678205668@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205670@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205670@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All,

Recently, i was working on a section of code that disabled/enable
interrupts
and interrupt collection like so.

    rsm psr.i | psr.ic
    ;;
    ... //body
    ;;
    ssm psr.i | psr.ic
    ;;
    srlz.d
    ;;

I found however that this implementation did not work under heavy loads.

It took a while to figure out that a pending interrupt that had occurred

in the body of code, executed while interrupts were turned off, was
delivered
after the ssm call as expected. However, it was delivered before the ic
bit
serialized. In the code this caused undesirable results. I found that
the
proper way to implement the above is to re-enable the ic bit and
serialize
before re-enabling the interrupt bit. Has anyone else come across this
problem and can anybody shed some light on whether this is the expected
operation.

Sincerely,
Jonathan Case Nicklin

Mission Critical Linux
www.missioncriticallinux.com

ps. The manual gives an example of the implementation that works, but
does
not provide any explanation of implementation itself (as far as I can
see ;-P )



