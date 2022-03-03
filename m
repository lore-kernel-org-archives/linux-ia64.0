From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Thu, 03 Mar 2022 19:06:45 +0000
Subject: Re: [PATCH 11/12] swiotlb: merge swiotlb-xen initialization into swiotlb
Message-Id: <588b2378-cac4-79cb-e520-a535422cd04f@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de>
 <20220301105311.885699-12-hch@lst.de>
 <alpine.DEB.2.22.394.2203011720150.3261@ubuntu-linux-20-04-desktop>
 <ca748512-12bb-7d75-13f1-8d5ec9703e26@oracle.com>
 <20220303105714.GB15103@lst.de>
In-Reply-To: <20220303105714.GB15103@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christoph Hellwig <hch@lst.de>
Cc: Juergen Gross <jgross@suse.com>, Tom Lendacky <thomas.lendacky@amd.com>, linux-s390@vger.kernel.org, Stefano Stabellini <sstabellini@kernel.org>, linux-ia64@vger.kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-mips@vger.kernel.org, tboot-devel@lists.sourceforge.net, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-hyperv@vger.kernel.org, linux-pci@vger.kernel.org, xen-devel@lists.xenproject.org, linux-riscv@lists.infradead.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org


On 3/3/22 5:57 AM, Christoph Hellwig wrote:
> On Wed, Mar 02, 2022 at 08:15:03AM -0500, Boris Ostrovsky wrote:
>> Not for me, I fail to boot with
>>
>> [   52.202000] bnxt_en 0000:31:00.0: swiotlb buffer is full (sz: 256 byt=
es), total 0 (slots), used 0 (slots)
>>
>> (this is iscsi root so I need the NIC).
>>
>>
>> I bisected it to "x86: remove the IOMMU table infrastructure" but haven'=
t actually looked at the code yet.
> Thanks. Looks like the sizing is going wrong.  Just to confirm, this is
> dom0 on x86 and no special command line options?


Right.


module2 /boot/vmlinuz-5.17.0-rc6swiotlb placeholder root=3DUUID=DBef1262-8c=
8a-43db-8055-7d9bec7bece0 ro crashkernel=3Dauto LANG=3Den_US.UTF-8 rd.luks=
=3D0 rd.lvm=3D0 rd.md=3D0 rd.dm=3D0 netroot=3Discsi:169.254.0.2:::1:iqn.201=
5-02.oracle.boot:uefi iscsi_param=3Dnode.session.timeo.replacement_timeout`=
00 net.ifnames=3D1 nvme_core.shutdown_timeout=10 ipmi_si.tryacpi=3D0 ipmi_s=
i.trydmi=3D0 ipmi_si.trydefaults=3D0 libiscsi.debug_libiscsi_eh=3D1=C2=A0 p=
anic  nokaslr earlyprintk=3Dxen console=3Dhvc0 loglevel=3D8 4
