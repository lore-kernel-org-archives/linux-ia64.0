From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Thu, 24 Feb 2022 16:18:33 +0000
Subject: Re: cleanup swiotlb initialization
Message-Id: <206ba6a3-770a-70ad-96bc-76c6380da988@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220222153514.593231-1-hch@lst.de>
 <09cb4ad3-88e7-3744-b4b8-a6d745ecea9e@oracle.com>
 <20220224155854.GA30938@lst.de>
In-Reply-To: <20220224155854.GA30938@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, x86@kernel.org, Stefano Stabellini <sstabellini@kernel.org>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org


On 2/24/22 10:58 AM, Christoph Hellwig wrote:
> Thanks.
>
> This looks really strange as early_amd_iommu_init should not interact much
> with the changes.  I'll see if I can find a AMD system to test on.


Just to be clear: this crashes only as dom0. Boots fine as baremetal.


-boris


>
> On Wed, Feb 23, 2022 at 07:57:49PM -0500, Boris Ostrovsky wrote:
>> [   37.377313] BUG: unable to handle page fault for address: ffffc90042880018
>> [   37.378219] #PF: supervisor read access in kernel mode
>> [   37.378219] #PF: error_code(0x0000) - not-present page
>> [   37.378219] PGD 7c2f2ee067 P4D 7c2f2ee067 PUD 7bf019b067 PMD 105a30067 PTE 0
>> [   37.378219] Oops: 0000 [#1] PREEMPT SMP NOPTI
>> [   37.378219] CPU: 14 PID: 1 Comm: swapper/0 Not tainted 5.17.0-rc5swiotlb #9
>> [   37.378219] Hardware name: Oracle Corporation ORACLE SERVER E1-2c/ASY,Generic,SM,E1-2c, BIOS 49004900 12/23/2020
>> [   37.378219] RIP: e030:init_iommu_one+0x248/0x2f0
>> [   37.378219] Code: 48 89 43 68 48 85 c0 74 c4 be 00 20 00 00 48 89 df e8 ea ee ff ff 48 89 43 78 48 85 c0 74 ae c6 83 98 00 00 00 00 48 8b 43 38 <48> 8b 40 18 a8 01 74 07 83 8b a8 04 00 00 01 f6 83 a8 04 00 00 01
>> [   37.378219] RSP: e02b:ffffc9004044bd18 EFLAGS: 00010286
>> [   37.378219] RAX: ffffc90042880000 RBX: ffff888107260800 RCX: 0000000000000000
>> [   37.378219] RDX: 0000000080000000 RSI: ffffea00041cab80 RDI: 00000000ffffffff
>> [   37.378219] RBP: ffffc9004044bd38 R08: 0000000000000901 R09: ffffea00041cab00
>> [   37.378219] R10: 0000000000000002 R11: 0000000000000000 R12: ffffc90040435008
>> [   37.378219] R13: 0000000000080000 R14: 00000000efa00000 R15: 0000000000000000
>> [   37.378219] FS:  0000000000000000(0000) GS:ffff88fef4180000(0000) knlGS:0000000000000000
>> [   37.378219] CS:  e030 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   37.378219] CR2: ffffc90042880018 CR3: 000000000260a000 CR4: 0000000000050660
>> [   37.378219] Call Trace:
>> [   37.378219]  <TASK>
>> [   37.378219]  early_amd_iommu_init+0x3c5/0x72d
>> [   37.378219]  ? iommu_setup+0x284/0x284
>> [   37.378219]  state_next+0x158/0x68f
>> [   37.378219]  ? iommu_setup+0x284/0x284
>> [   37.378219]  iommu_go_to_state+0x28/0x2d
>> [   37.378219]  amd_iommu_init+0x15/0x4b
>> [   37.378219]  ? iommu_setup+0x284/0x284
>> [   37.378219]  pci_iommu_init+0x12/0x37
>> [   37.378219]  do_one_initcall+0x48/0x210
>> [   37.378219]  kernel_init_freeable+0x229/0x28c
>> [   37.378219]  ? rest_init+0xe0/0xe0
>> [   37.963966]  kernel_init+0x1a/0x130
>> [   37.979415]  ret_from_fork+0x22/0x30
>> [   37.991436]  </TASK>
>> [   37.999465] Modules linked in:
>> [   38.007413] CR2: ffffc90042880018
>> [   38.019416] ---[ end trace 0000000000000000 ]---
>> [   38.023418] RIP: e030:init_iommu_one+0x248/0x2f0
>> [   38.023418] Code: 48 89 43 68 48 85 c0 74 c4 be 00 20 00 00 48 89 df e8 ea ee ff ff 48 89 43 78 48 85 c0 74 ae c6 83 98 00 00 00 00 48 8b 43 38 <48> 8b 40 18 a8 01 74 07 83 8b a8 04 00 00 01 f6 83 a8 04 00 00 01
>> [   38.023418] RSP: e02b:ffffc9004044bd18 EFLAGS: 00010286
>> [   38.023418] RAX: ffffc90042880000 RBX: ffff888107260800 RCX: 0000000000000000
>> [   38.155413] RDX: 0000000080000000 RSI: ffffea00041cab80 RDI: 00000000ffffffff
>> [   38.175965] Freeing initrd memory: 62640K
>> [   38.155413] RBP: ffffc9004044bd38 R08: 0000000000000901 R09: ffffea00041cab00
>> [   38.155413] R10: 0000000000000002 R11: 0000000000000000 R12: ffffc90040435008
>> [   38.155413] R13: 0000000000080000 R14: 00000000efa00000 R15: 0000000000000000
>> [   38.155413] FS:  0000000000000000(0000) GS:ffff88fef4180000(0000) knlGS:0000000000000000
>> [   38.287414] CS:  e030 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   38.309557] CR2: ffffc90042880018 CR3: 000000000260a000 CR4: 0000000000050660
>> [   38.332403] Kernel panic - not syncing: Fatal exception
>> [   38.351414] Rebooting in 20 seconds..
>>
>>
>>
>> -boris
> ---end quoted text---
>
