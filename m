From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Fri, 18 May 2001 19:00:31 +0000
Subject: [Linux-ia64] Software IO-TLB Kernel panic - preliminary analysis
Message-Id: <marc-linux-ia64-105590693005624@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005601@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005601@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This problem is really hard to hunt down, as even kdb will not
respond anymore after the crash happens. Also, my system logs are
truncated.

What I have seen, though, is that IO-TLBs are allocated very quickly
immediately before the crash. By using some printk's, I saw
133 allocations of 8192-byte chunks in a row without a single
deallocation immediately before the machine came down. This alone accounts
for about half of the bounce buffer space, without any space that
was allocated before and without any further allocations that
I may have lost due to the lost lines in the log.

By inspecting elements of the pci_dev structure passed to the routine,
I am now 99% convinced that the Adptect 7899a controller
is the "guilty" device. This fits well to the finding that the
crashes always occur after (!) a file system on that card was
activated a little more heavily.

It seems that the problem does not occur with the "old" aic7xxx
driver. On the contrary, that driver seems to deallocate every buffer
immediately after allocation.

Thus, for the time being I'd recommend to use the aic7xxx_old driver.
But it looks like a problem that ought to be solved.

Should I perhaps approach the aic7xxx maintainers?

Regards,
Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113





