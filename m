From: "Sluder, Charles" <Charles.Sluder@UNISYS.com>
Date: Fri, 14 Feb 2003 03:15:48 +0000
Subject: [Linux-ia64] Problem with elilo 3.3a
Message-Id: <marc-linux-ia64-105590709805846@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I keep seeing hangs in the SAL that I have traced back to a corrupted EFI
memory map. I was looking at the code for allocating the boot parameter
block in elilo and noticed this piece of code in bootparams.c

	/*
	 * Allocate memory for boot parameters.
	 * This CANNOT be EfiLoaderData or EfiLoaderCode as the kernel
	 * frees this region when initializing.
	 */

	bp = (boot_params_t *)alloc(BOOT_PARAM_MEMSIZE, EfiLoaderData);

The comment seems to be at odds with the code. Is this a problem with the
code or the comment?

-chuck

Charles Sluder
Unisys Corp.
Salt Lake City, UT

