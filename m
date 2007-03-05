From: "Magnus Damm" <magnus.damm@gmail.com>
Date: Mon, 05 Mar 2007 09:03:40 +0000
Subject: ia64: kdump not working on HP rx2620 hardware
Message-Id: <aec7e5c30703050103k462ed219v4b0293bb028a7e01@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi everyone,

Just wanted to let you know that 2.6.21-rc2 does _not_ work with kdump
on HP rx2620 hardware. It is not a regression though - it has never
worked on that platform so far actually. Kexec is working fine since
2.6.20, but kdump is not.

The following two patches fixes things for me. In theory they should
improve kdump on other ia64 hardware as well, but there has not been
that much feedback so far.

/proc/vmcore has zero size without this fix:
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.21-rc2/2.6.21-rc2-mm1/broken-out/ia64-point-saved_max_pfn-to-the-max_pfn-of-the-entire-system.patch

kdump kernel dies early because initramfs is not mapped:
http://lists.osdl.org/mailman/htdig/fastboot/2007-February/005984.html

I'd be happy to resend the second patch somewhere, just let me know
where and when.

Thanks.

/ magnus
