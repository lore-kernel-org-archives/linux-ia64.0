From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Thu, 17 May 2001 11:44:50 +0000
Subject: [Linux-ia64] Software IO-TLB Kernel panic
Message-Id: <marc-linux-ia64-105590693005601@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I am reproduceably getting kernel panics when accessing discs on an
Adaptec 39160 adapter (SCSI host 1 after the built-in QLA1280).
I am using the "new" aic7xxx driver on a 2.4.4 IA64 kernel.
I configured the kernel for DIG-compliant C0-stepping hardware.

The kernel panic occurs in map_single (arch/ia64/lib/swiotlb.c:171).

I have a 2-CPU Lion with C0-stepping CPUs. The requested
IO TLB size is 8192 when the panic occurs.

After the crash, I always have severe corruption on the filesystem that
was being accessed during the crash. e2fsck reports ~10 illegal blocks in
one inode, and many follow-up errors.

The only TLB related boot message I see is
kernel: Placing software IO TLB between 0xe000000000100000 - 0xe000000000300000

I am looking into this myself right now, but I would be grateful for hints
where to start. Any help appreciated,

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




