From: Matt_Domsch@Dell.com
Date: Sat, 10 Nov 2001 02:51:30 +0000
Subject: RE: [Linux-ia64] adding new network device driver
Message-Id: <marc-linux-ia64-105590698805463@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805461@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805461@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> When I boot with new kernel my driver probe routine is not entered. 
> Is there anyplace I need to inform the kernel about the existence 
> of the new driver.

If it's a module, you simply mark your init function with __init, like so:

int __init my_driver_init(void)
{
	...
}

And then if it can be built as a module, put
module_init(my_driver_init);

at the end.  See most of the networking drivers for how they do this.

Then, at kernel build time, if your driver is built into the kernel
(CONFIG_XXXX=Y), it gets its initialization routine called during the kernel
startup.  If it's a module, it gets called when you insmod your driver.

Of course, all of this isn't specific to IA-64, so this probably isn't the
right list.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

