From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 30 Sep 2003 20:55:00 +0000
Subject: Re: [PATCH] disable legacy floppy related ioctl32s
Message-Id: <marc-linux-ia64-106495539424409@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106495318021597@msgid-missing>
In-Reply-To: <marc-linux-ia64-106495318021597@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 30 September 2003 2:16 pm, Arun Sharma wrote:
> Since we don't support legacy floppy devices on ia64, this patch disables the corresponding ioctl32.

	-#ifndef CONFIG_ARCH_S390
	+#if !defined(CONFIG_ARCH_S390) && !defined(CONFIG_IA64)
	 /* 0x02 -- Floppy ioctls */
	 COMPATIBLE_IOCTL(FDMSGON)
	 COMPATIBLE_IOCTL(FDMSGOFF)

Could this be done with config symbols somehow, i.e., CONFIG_BLK_DEV_FD?
It seems sort of ugly to encode the knowledge about which platforms
support legacy floppy both in Kconfig and in the actual source.

BTW, it looks like one can still select legacy floppy support on ia64:

config BLK_DEV_FD
        tristate "Normal floppy disk support"
        depends on !X86_PC9800 && !ARCH_S390

