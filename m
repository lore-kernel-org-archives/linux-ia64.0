From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 26 Sep 2005 22:08:23 +0000
Subject: RE: [patch 2.6.14-rc2 0/5] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F047E9021@scsmsx401.amr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C5C2E6.CFE9161F"
List-Id: <linux-ia64.vger.kernel.org>
References: <09262005170119.15628@bilbo.tuxdriver.com>
In-Reply-To: <09262005170119.15628@bilbo.tuxdriver.com>
To: "John W. Linville" <linville@tuxdriver.com>, Matthew Wilcox <matthew@wil.cx>
Cc: linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, ak@suse.de, "Mallick, Asit K" <asit.k.mallick@intel.com>, gregkh@suse.de

This is a multi-part message in MIME format.

------_=_NextPart_001_01C5C2E6.CFE9161F
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

>Well, now, this is a quandry isn't it...  Actually, I'm inclined to
>agree with you.
>
>Tony, et al., care to restate your reasoning for moving it under
>drivers/pci?

Historically swiotlb.c was written with just PCI in mind (hence
all the comments ("... implement the PCI DMA API",  "The PCI address
to use is returned", "teardown the PCI dma mapping") and a few
error messages ("PCI-DMA: Out of SW-IOMMU space ...", "PCI-DMA: Memory
would be corrupted", "PCI-DMA: Random memory would be DMAed").
Perhaps back then the only options were PCI and ISA????

Matthew is probably technically right in that this is a more
generic interface ... but is it actually being used for anything
other than PCI?  Will it ever be so used?

Ignoring the comments and error messages, the attached patch
removed the <linux/pci.h> and <asm/pci.h> includes (and adds a
couple of others that are then needed, and converts a few
PCI_DMA_* defines to DMA_* ones that sound like they mean the
same thing).  Compiles, but not tested.

-Tony

------_=_NextPart_001_01C5C2E6.CFE9161F
Content-Type: application/octet-stream;
	name="sw.patch"
Content-Transfer-Encoding: base64
Content-Description: sw.patch
Content-Disposition: attachment;
	filename="sw.patch"

LS0tIGEvYXJjaC9pYTY0L2xpYi9zd2lvdGxiLmMJMjAwNS0wOS0yNiAxMzowMzowNC4wMDAwMDAw
MDAgLTA3MDAKKysrIGIvYXJjaC9pYTY0L2xpYi9zd2lvdGxiLmMJMjAwNS0wOS0yNiAxNDo1NDoz
OC4wMDAwMDAwMDAgLTA3MDAKQEAgLTE1LDE3ICsxNSwxNyBAQAogICovCiAKICNpbmNsdWRlIDxs
aW51eC9jYWNoZS5oPgorI2luY2x1ZGUgPGxpbnV4L2RtYS1tYXBwaW5nLmg+CiAjaW5jbHVkZSA8
bGludXgvbW0uaD4KICNpbmNsdWRlIDxsaW51eC9tb2R1bGUuaD4KLSNpbmNsdWRlIDxsaW51eC9w
Y2kuaD4KICNpbmNsdWRlIDxsaW51eC9zcGlubG9jay5oPgogI2luY2x1ZGUgPGxpbnV4L3N0cmlu
Zy5oPgogI2luY2x1ZGUgPGxpbnV4L3R5cGVzLmg+CiAjaW5jbHVkZSA8bGludXgvY3R5cGUuaD4K
IAogI2luY2x1ZGUgPGFzbS9pby5oPgotI2luY2x1ZGUgPGFzbS9wY2kuaD4KICNpbmNsdWRlIDxh
c20vZG1hLmg+CisjaW5jbHVkZSA8YXNtL3NjYXR0ZXJsaXN0Lmg+CiAKICNpbmNsdWRlIDxsaW51
eC9pbml0Lmg+CiAjaW5jbHVkZSA8bGludXgvYm9vdG1lbS5oPgpAQCAtMzkxLDkgKzM5MSw5IEBA
CiAJICAgICAgICJkZXZpY2UgJXNcbiIsIHNpemUsIGRldiA/IGRldi0+YnVzX2lkIDogIj8iKTsK
IAogCWlmIChzaXplID4gaW9fdGxiX292ZXJmbG93ICYmIGRvX3BhbmljKSB7Ci0JCWlmIChkaXIg
PT0gUENJX0RNQV9GUk9NREVWSUNFIHx8IGRpciA9PSBQQ0lfRE1BX0JJRElSRUNUSU9OQUwpCisJ
CWlmIChkaXIgPT0gRE1BX0ZST01fREVWSUNFIHx8IGRpciA9PSBETUFfQklESVJFQ1RJT05BTCkK
IAkJCXBhbmljKCJQQ0ktRE1BOiBNZW1vcnkgd291bGQgYmUgY29ycnVwdGVkXG4iKTsKLQkJaWYg
KGRpciA9PSBQQ0lfRE1BX1RPREVWSUNFIHx8IGRpciA9PSBQQ0lfRE1BX0JJRElSRUNUSU9OQUwp
CisJCWlmIChkaXIgPT0gRE1BX1RPX0RFVklDRSB8fCBkaXIgPT0gRE1BX0JJRElSRUNUSU9OQUwp
CiAJCQlwYW5pYygiUENJLURNQTogUmFuZG9tIG1lbW9yeSB3b3VsZCBiZSBETUFlZFxuIik7CiAJ
fQogfQo=

------_=_NextPart_001_01C5C2E6.CFE9161F--
