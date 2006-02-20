From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 20 Feb 2006 13:12:07 +0000
Subject: "BUG()" definition
Message-Id: <43F9C027.20203@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Can someone please explain me why the generic "BUG()" definition

#define BUG() do { \
        printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); \
        panic("BUG!"); \
} while (0)

has been changed to

#define BUG() do { i\
	printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); \
	ia64_abort(); \
} while (0)

?

Only for the sake of "show_regs()" ?

If a task calls a kernel service, and that service detects some
incoherency in the kernel data, then we usually call "BUG()".

Due to the actual "BUG()" definition, only the calling task gets
killed, the system continues with the incoherent kernel data.

Maybe "die()" should call "panic()" unconditionally, instead
of "do_exit()" ?

Thanks,

Zoltan Menyhart

