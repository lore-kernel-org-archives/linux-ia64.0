From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 07 Oct 2004 23:44:09 +0000
Subject: Re: [PATCH] Support ia32 exec domains without CONFIG_IA32_SUPPORT
Message-Id: <4165D4C9.2040804@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41643EC0.1010505@intel.com>
In-Reply-To: <41643EC0.1010505@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 10/7/2004 6:27 AM, Christoph Hellwig wrote:

> This was rejected for qemu on various arches already.  Please do it in your
> userland emulator.
> 

I agree that there is no functionality issue here, but there is a performance issue. Doing it in the userland emulator is much slower. What's wrong with the patch ?

	-Arun

PS: For others following this thread, the qemu stuff is at:
http://groups.google.com/groups?hl=en&lr=&threadm 030407063012%243336%40gated-at.bofh.it
