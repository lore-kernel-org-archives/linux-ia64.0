From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Wed, 17 Oct 2001 15:29:43 +0000
Subject: [Linux-ia64] Re: console_loglevel is broken on ia64
Message-Id: <marc-linux-ia64-105590698805361@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> 
> kernel/printk.c has this abomination.
> 
> /* Keep together for sysctl support */
> int console_loglevel = DEFAULT_CONSOLE_LOGLEVEL;
> int default_message_loglevel = DEFAULT_MESSAGE_LOGLEVEL;
> int minimum_console_loglevel = MINIMUM_CONSOLE_LOGLEVEL;
> int default_console_loglevel = DEFAULT_CONSOLE_LOGLEVEL;
> 
> sysctl assumes that the 4 variables occupy contiguous storage.  They
> don't on ia64, console_loglevel is separate from the other variables.
> 
>   echo 6 4 1 7 > /proc/sys/kernel/printk
> 
> on ia64 overwrites console_loglevel and the next 3 integers, whatever
> they happen to be.  On 2.4.12 it corrupts console_sem, other ia64
> kernels will corrupt different data.
> 
> Does anybody fancy a small project to clean up these variables?  They
> need to become an integer array (say console_printk) containing 4
> elements, which is what sysctl assumes.  All references to these fields
> have to be changed to refer to the corresponding array element.  That
> should be as simple as

Yep.  I asked someone to clean this up about
3 weeks ago, and he said that he would do so, but....?

So Jesper or someone else should jump on it.

~Randy

