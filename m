From: gerard <gerard@mylos.grenoble.hp.com>
Date: Wed, 13 Jun 2001 15:04:51 +0000
Subject: [Linux-ia64] modules external refs
Message-Id: <marc-linux-ia64-105590693005726@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have a product consisting in several loadable modules,
among which one is the central controler.
When I load this on I do not have any problems, as it has external
references
only from the kernel.
But all the other modules call functions from this module.
I  started only with a module calling this controler.
I verified that in /proc/ksyms all the functions of the controler are
described.
I have put a printk in the second module trying to access the controler
in which I  print the address of the function it tries to call, it
corresponds to what
I see in /proc/ksyms, but when I call that function, I get a
Unimplemented Instruction Address fault .
I have tried to declare the function with a hardcoded address, and it
works "fine",
Iit seems that the external function reference is not resolved properly
when I load the module.
I do not have the version enabled in my environment.

What do I need to do to make it work, it used to work fine on a IA32
machine , but
not on a BIGSUR.
Thanks
Gerard LYONNAZ



