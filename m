From: Uros Prestor <uros@turbolinux.com>
Date: Sun, 10 Sep 2000 00:24:29 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test8)
Message-Id: <marc-linux-ia64-105590678205478@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> >>>>> On Sat, 9 Sep 2000 14:49:52 -0700, "H . J . Lu" <hjl@valinux.com> said:
>
>   HJ> Yes, I did "make dep". What should include/asm-ia64/offsets.h
>   HJ> look like? That may explain many things.
>
> Well, it depends on your kernel configuration.  If you did a "make
> dep", you should have the right values in there.
>
> I'm not sure why the new kernel isn't working for you.  Nothing has
> changed in the kernel that would explain an infinite stream of irq 0.

Yep, that's what I am seeing now.  I have disabled kdb and now the kernel boots,
I briefly see a panic dump and then an infinite stream of irq 0's.  If you can
tell me of a way of capturing the kernel output I'll try to send you what I get.

Uros


--
Uros Prestor
uros@turbolinux.com




