From: Paul Jackson <pj@sgi.com>
Date: Thu, 12 Jan 2006 09:45:51 +0000
Subject: Re: [CFT 9/29] Add tiocx bus_type probe/remove methods
Message-Id: <20060112014551.8e7888c3.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060105142951.13.01@flint.arm.linux.org.uk>
	<20060105142951.13.09@flint.arm.linux.org.uk>
In-Reply-To: <20060105142951.13.09@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, greg@kroah.com, linux-ia64@vger.kernel.org

This patch looks broken.  I see the lines:

+	.remove = cx_device_remove,
-	cx_driver->driver.remove = cx_driver_remove;

The routine (not in this patch) is still known as "cx_driver_remove"
but now it is linked to from the .remove line as  "cx_device_remove"

A defconfig ia64 build of *-mm3 with this patch fails:

arch/ia64/sn/kernel/tiocx.c:151: error: `cx_device_remove' undeclared here (not in a function)
arch/ia64/sn/kernel/tiocx.c:151: error: initializer element is not constant
arch/ia64/sn/kernel/tiocx.c:151: error: (near initialization for `tiocx_bus_type.remove')
arch/ia64/sn/kernel/tiocx.c:137: warning: `cx_driver_remove' defined but not used         

When I s/cx_device_remove/cx_driver_remove/, then ia64 *-mm3 defconfig builds fine.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
