From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 08 Jun 2006 10:27:18 +0000
Subject: Re: [PATCH] printing support for MCA/INIT
Message-Id: <4487FB86.8030004@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4486BE32.80100@jp.fujitsu.com>
In-Reply-To: <4486BE32.80100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> Also consider that crash dump may be invoked from MCA/INIT.  The
> various crash dump analysis tools all expect to find the messages in
> the dmesg buffer in the dump.  Adding a special print buffer just for
> MCA/INIT means changing all the crash dump tools to look in two places.

I doubt it.
If you successfully get the crash dump, you will be able to see where
the dump was invoked, possibly with short string describing why the dump
was invoked. Then these short messages from MCA/INIT handler are not so
important thing even still you can look in special buffer.

Or export ia64_mlogbuf_break and use it to flush special buffer to
dmesg buffer before you invoke crash dump.

> It is possible to make the core of printk completely NMI safe.  We can
> make it lockless, or retain the locks but detect that there is no
> movement and ignore the lock.  The SN2 serial console does the latter,
> see drivers/serial/sn_console.c::sn_sal_console_write().  This means
> that SN2 machines can safely write to the console even from MCA/INIT.
> printk can use the same technique to lock access to its print buffer.

Latter will not be acceptable. How long we can pause the system to
recover a TLB error which can be swept in a second?

I have no idea to make printk lockless. Really can we?

Still I like patching as a workaround better than waiting incredible
feature in future.

H.Seto

