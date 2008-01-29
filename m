From: Olof Johansson <olof@lixom.net>
Date: Tue, 29 Jan 2008 21:46:53 +0000
Subject: Re: system hang on latest git
Message-Id: <20080129214653.GA27978@lixom.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC75736A@orsmsx424.amr.corp.intel.com> <20080129201136.GX15220@kernel.dk> <20080129201648.GA15220@kernel.dk>
In-Reply-To: <20080129201648.GA15220@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jens Axboe <jens.axboe@oracle.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Tue, Jan 29, 2008 at 09:16:48PM +0100, Jens Axboe wrote:

> Actually, can you try this? It has a known race but nothing to worry
> about, and it removes ioc->lock from irq context.

I just tried this myself, since I saw hangs within seconds of running
'aiostress' from autotest on this morning's kernel as well (g0ba6c33).

It didn't help. My config is 2 cores (powerpc), built with
arch/powerpc/configs/pasemi_defconfig. Hardware is sata disk on marvell
7042.

Stacktraces:

0:mon> t           
[link register   ] c000000000221984 .as_merged_requests+0x164/0x1e0
[c00000007e8ff750] c00000007e8ff800 (unreliable)
[c00000007e8ff800] c000000000212f20 .elv_merge_requests+0x50/0xb0
[c00000007e8ff890] c000000000218c98 .attempt_merge+0x318/0x3d0
[c00000007e8ff940] c00000000021af98 .__make_request+0x2f8/0x720
[c00000007e8ffa20] c000000000216e6c .generic_make_request+0x22c/0x2f0
[c00000007e8ffad0] c000000000216fd8 .submit_bio+0xa8/0x150
[c00000007e8ffb90] c0000000000efa7c .submit_bh+0x15c/0x1e0
[c00000007e8ffc20] c000000000145d5c .journal_do_submit_data+0x6c/0xb0
[c00000007e8ffcc0] c000000000147460 .journal_commit_transaction+0x1640/0x16e0
[c00000007e8ffe10] c00000000014c238 .kjournald+0x108/0x2f0
[c00000007e8fff00] c000000000067ca8 .kthread+0xc8/0xe0
[c00000007e8fff90] c0000000000237bc .kernel_thread+0x4c/0x68
0:mon> c1
1:mon> t
[link register   ] c00000000033c20c .scsi_device_unbusy+0x8c/0x120
[c00000007e10b6f0] c00000000033c1a8 .scsi_device_unbusy+0x28/0x120 (unreliable)
[c00000007e10b780] c000000000333078 .scsi_finish_command+0x38/0x130
[c00000007e10b810] c00000000033c478 .scsi_softirq_done+0xd8/0x1a0
[c00000007e10b8b0] c00000000021a780 .blk_done_softirq+0xb0/0xe0
[c00000007e10b940] c000000000051e58 .__do_softirq+0xe8/0x1d0
[c00000007e10ba00] c00000000000ac64 .do_softirq+0x64/0xa0
[c00000007e10ba80] c000000000051b84 .irq_exit+0xc4/0xd0
[c00000007e10bb00] c00000000000b3c0 .do_IRQ+0xe0/0x120
[c00000007e10bb80] c00000000000405c hardware_interrupt_entry+0x18/0x3c
--- Exception: 501 (Hardware Interrupt) at c000000000010564 .cpu_idle+0xb4/0x160
[c00000007e10be70] c000000000010524 .cpu_idle+0x74/0x160 (unreliable)
[c00000007e10bf00] c000000000540e6c
[c00000007e10bf90] c000000000007364 .start_secondary_prolog+0xc/0x10


scsi_device_busy is sitting on:

        spin_lock(sdev->request_queue->queue_lock);

and as_merged_requests on the second lock at:

	double_spin_lock(&rioc->lock, &nioc->lock, rioc < nioc);


-Olof
