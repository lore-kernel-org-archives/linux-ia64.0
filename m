From: Jesper Juhl <juhl@eisenstein.dk>
Date: Wed, 17 Oct 2001 13:39:06 +0000
Subject: [Linux-ia64] Re: console_loglevel is broken on ia64
Message-Id: <marc-linux-ia64-105590698805358@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:

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
> Does anybody fancy a small project to clean up these variables?

I would like to give it a try. Seems like a good little project for one 
who is trying to learn his way around the kernel :)  It will probably 
take me a lot longer than one of the experienced kernel hackers and 
would probably not be perfect on the first try, but I'm willing to 
invest some time in it.


Best regards,
Jesper Juhl




