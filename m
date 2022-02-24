From: Christoph Hellwig <hch@lst.de>
Date: Thu, 24 Feb 2022 15:58:54 +0000
Subject: Re: cleanup swiotlb initialization
Message-Id: <20220224155854.GA30938@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220222153514.593231-1-hch@lst.de>
 <09cb4ad3-88e7-3744-b4b8-a6d745ecea9e@oracle.com>
In-Reply-To: <09cb4ad3-88e7-3744-b4b8-a6d745ecea9e@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, x86@kernel.org, Stefano Stabellini <sstabellini@kernel.org>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

Thanks.

This looks really strange as early_amd_iommu_init should not interact much
with the changes.  I'll see if I can find a AMD system to test on.

On Wed, Feb 23, 2022 at 07:57:49PM -0500, Boris Ostrovsky wrote:
> [=A0=A0 37.377313] BUG: unable to handle page fault for address: ffffc900=
42880018
> [=A0=A0 37.378219] #PF: supervisor read access in kernel mode
> [=A0=A0 37.378219] #PF: error_code(0x0000) - not-present page
> [=A0=A0 37.378219] PGD 7c2f2ee067 P4D 7c2f2ee067 PUD 7bf019b067 PMD 105a3=
0067 PTE 0
> [=A0=A0 37.378219] Oops: 0000 [#1] PREEMPT SMP NOPTI
> [=A0=A0 37.378219] CPU: 14 PID: 1 Comm: swapper/0 Not tainted 5.17.0-rc5s=
wiotlb #9
> [=A0=A0 37.378219] Hardware name: Oracle Corporation ORACLE SERVER E1-2c/=
ASY,Generic,SM,E1-2c, BIOS 49004900 12/23/2020
> [=A0=A0 37.378219] RIP: e030:init_iommu_one+0x248/0x2f0
> [=A0=A0 37.378219] Code: 48 89 43 68 48 85 c0 74 c4 be 00 20 00 00 48 89 =
df e8 ea ee ff ff 48 89 43 78 48 85 c0 74 ae c6 83 98 00 00 00 00 48 8b 43 =
38 <48> 8b 40 18 a8 01 74 07 83 8b a8 04 00 00 01 f6 83 a8 04 00 00 01
> [=A0=A0 37.378219] RSP: e02b:ffffc9004044bd18 EFLAGS: 00010286
> [=A0=A0 37.378219] RAX: ffffc90042880000 RBX: ffff888107260800 RCX: 00000=
00000000000
> [=A0=A0 37.378219] RDX: 0000000080000000 RSI: ffffea00041cab80 RDI: 00000=
000ffffffff
> [=A0=A0 37.378219] RBP: ffffc9004044bd38 R08: 0000000000000901 R09: ffffe=
a00041cab00
> [=A0=A0 37.378219] R10: 0000000000000002 R11: 0000000000000000 R12: ffffc=
90040435008
> [=A0=A0 37.378219] R13: 0000000000080000 R14: 00000000efa00000 R15: 00000=
00000000000
> [=A0=A0 37.378219] FS:=A0 0000000000000000(0000) GS:ffff88fef4180000(0000=
) knlGS:0000000000000000
> [=A0=A0 37.378219] CS:=A0 e030 DS: 0000 ES: 0000 CR0: 0000000080050033
> [=A0=A0 37.378219] CR2: ffffc90042880018 CR3: 000000000260a000 CR4: 00000=
00000050660
> [=A0=A0 37.378219] Call Trace:
> [=A0=A0 37.378219]=A0 <TASK>
> [=A0=A0 37.378219]=A0 early_amd_iommu_init+0x3c5/0x72d
> [=A0=A0 37.378219]=A0 ? iommu_setup+0x284/0x284
> [=A0=A0 37.378219]=A0 state_next+0x158/0x68f
> [=A0=A0 37.378219]=A0 ? iommu_setup+0x284/0x284
> [=A0=A0 37.378219]=A0 iommu_go_to_state+0x28/0x2d
> [=A0=A0 37.378219]=A0 amd_iommu_init+0x15/0x4b
> [=A0=A0 37.378219]=A0 ? iommu_setup+0x284/0x284
> [=A0=A0 37.378219]=A0 pci_iommu_init+0x12/0x37
> [=A0=A0 37.378219]=A0 do_one_initcall+0x48/0x210
> [=A0=A0 37.378219]=A0 kernel_init_freeable+0x229/0x28c
> [=A0=A0 37.378219]=A0 ? rest_init+0xe0/0xe0
> [=A0=A0 37.963966]=A0 kernel_init+0x1a/0x130
> [=A0=A0 37.979415]=A0 ret_from_fork+0x22/0x30
> [=A0=A0 37.991436]=A0 </TASK>
> [=A0=A0 37.999465] Modules linked in:
> [=A0=A0 38.007413] CR2: ffffc90042880018
> [=A0=A0 38.019416] ---[ end trace 0000000000000000 ]---
> [=A0=A0 38.023418] RIP: e030:init_iommu_one+0x248/0x2f0
> [=A0=A0 38.023418] Code: 48 89 43 68 48 85 c0 74 c4 be 00 20 00 00 48 89 =
df e8 ea ee ff ff 48 89 43 78 48 85 c0 74 ae c6 83 98 00 00 00 00 48 8b 43 =
38 <48> 8b 40 18 a8 01 74 07 83 8b a8 04 00 00 01 f6 83 a8 04 00 00 01
> [=A0=A0 38.023418] RSP: e02b:ffffc9004044bd18 EFLAGS: 00010286
> [=A0=A0 38.023418] RAX: ffffc90042880000 RBX: ffff888107260800 RCX: 00000=
00000000000
> [=A0=A0 38.155413] RDX: 0000000080000000 RSI: ffffea00041cab80 RDI: 00000=
000ffffffff
> [=A0=A0 38.175965] Freeing initrd memory: 62640K
> [=A0=A0 38.155413] RBP: ffffc9004044bd38 R08: 0000000000000901 R09: ffffe=
a00041cab00
> [=A0=A0 38.155413] R10: 0000000000000002 R11: 0000000000000000 R12: ffffc=
90040435008
> [=A0=A0 38.155413] R13: 0000000000080000 R14: 00000000efa00000 R15: 00000=
00000000000
> [=A0=A0 38.155413] FS:=A0 0000000000000000(0000) GS:ffff88fef4180000(0000=
) knlGS:0000000000000000
> [=A0=A0 38.287414] CS:=A0 e030 DS: 0000 ES: 0000 CR0: 0000000080050033
> [=A0=A0 38.309557] CR2: ffffc90042880018 CR3: 000000000260a000 CR4: 00000=
00000050660
> [=A0=A0 38.332403] Kernel panic - not syncing: Fatal exception
> [=A0=A0 38.351414] Rebooting in 20 seconds..
>
>
>
> -boris
---end quoted text---
