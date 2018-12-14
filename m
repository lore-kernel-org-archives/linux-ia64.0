From: "Derrick, Jonathan" <jonathan.derrick@intel.com>
Date: Fri, 14 Dec 2018 21:34:52 +0000
Subject: Re: [PATCH 14/15] vmd: use the proper dma_* APIs instead of direct methods calls
Message-Id: <1544823277.19764.1.camel@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-9E1D7a0ir8jkFqgEIfO9"
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
         <20181207190720.18517-15-hch@lst.de> <20181214211757.GF20725@google.com>
In-Reply-To: <20181214211757.GF20725@google.com>
To: "hch@lst.de" <hch@lst.de>, "helgaas@kernel.org" <helgaas@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "brouer@redhat.com" <brouer@redhat.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "tariqt@mellanox.com" <tariqt@mellanox.com>, "toke@toke.dk" <toke@toke.dk>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "x86@kernel.org" <x86@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "Busch, Keith" <keith.busch@intel.com>

--=-9E1D7a0ir8jkFqgEIfO9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Looks good to me
Thanks Christoph

Acked-by: Jon Derrick <jonathan.derrick@intel.com>

On Fri, 2018-12-14 at 15:17 -0600, Bjorn Helgaas wrote:
> Conventional spelling in subject is
>=20
>   PCI: vmd: Use dma_* APIs instead of direct method calls
>=20
> On Fri, Dec 07, 2018 at 11:07:19AM -0800, Christoph Hellwig wrote:
> > With the bypass support for the direct mapping we might not always have
> > methods to call, so use the proper APIs instead.  The only downside is
> > that we will create two dma-debug entries for each mapping if
> > CONFIG_DMA_DEBUG is enabled.
> >=20
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
>=20
> You cc'd the VMD maintainers already, and I have no objection to this
> from a PCI core point of view, so:
>=20
> Acked-by: Bjorn Helgaas <bhelgaas@google.com>
>=20
> > ---
> >  drivers/pci/controller/vmd.c | 42 +++++++++++++++---------------------
> >  1 file changed, 17 insertions(+), 25 deletions(-)
> >=20
> > diff --git a/drivers/pci/controller/vmd.c b/drivers/pci/controller/vmd.=
c
> > index 98ce79eac128..3890812cdf87 100644
> > --- a/drivers/pci/controller/vmd.c
> > +++ b/drivers/pci/controller/vmd.c
> > @@ -307,39 +307,32 @@ static struct device *to_vmd_dev(struct device *d=
ev)
> >  	return &vmd->dev->dev;
> >  }
> > =20
> > -static const struct dma_map_ops *vmd_dma_ops(struct device *dev)
> > -{
> > -	return get_dma_ops(to_vmd_dev(dev));
> > -}
> > -
> >  static void *vmd_alloc(struct device *dev, size_t size, dma_addr_t *ad=
dr,
> >  		       gfp_t flag, unsigned long attrs)
> >  {
> > -	return vmd_dma_ops(dev)->alloc(to_vmd_dev(dev), size, addr, flag,
> > -				       attrs);
> > +	return dma_alloc_attrs(to_vmd_dev(dev), size, addr, flag, attrs);
> >  }
> > =20
> >  static void vmd_free(struct device *dev, size_t size, void *vaddr,
> >  		     dma_addr_t addr, unsigned long attrs)
> >  {
> > -	return vmd_dma_ops(dev)->free(to_vmd_dev(dev), size, vaddr, addr,
> > -				      attrs);
> > +	return dma_free_attrs(to_vmd_dev(dev), size, vaddr, addr, attrs);
> >  }
> > =20
> >  static int vmd_mmap(struct device *dev, struct vm_area_struct *vma,
> >  		    void *cpu_addr, dma_addr_t addr, size_t size,
> >  		    unsigned long attrs)
> >  {
> > -	return vmd_dma_ops(dev)->mmap(to_vmd_dev(dev), vma, cpu_addr, addr,
> > -				      size, attrs);
> > +	return dma_mmap_attrs(to_vmd_dev(dev), vma, cpu_addr, addr, size,
> > +			attrs);
> >  }
> > =20
> >  static int vmd_get_sgtable(struct device *dev, struct sg_table *sgt,
> >  			   void *cpu_addr, dma_addr_t addr, size_t size,
> >  			   unsigned long attrs)
> >  {
> > -	return vmd_dma_ops(dev)->get_sgtable(to_vmd_dev(dev), sgt, cpu_addr,
> > -					     addr, size, attrs);
> > +	return dma_get_sgtable_attrs(to_vmd_dev(dev), sgt, cpu_addr, addr, si=
ze,
> > +			attrs);
> >  }
> > =20
> >  static dma_addr_t vmd_map_page(struct device *dev, struct page *page,
> > @@ -347,61 +340,60 @@ static dma_addr_t vmd_map_page(struct device *dev=
, struct page *page,
> >  			       enum dma_data_direction dir,
> >  			       unsigned long attrs)
> >  {
> > -	return vmd_dma_ops(dev)->map_page(to_vmd_dev(dev), page, offset, size=
,
> > -					  dir, attrs);
> > +	return dma_map_page_attrs(to_vmd_dev(dev), page, offset, size, dir,
> > +			attrs);
> >  }
> > =20
> >  static void vmd_unmap_page(struct device *dev, dma_addr_t addr, size_t=
 size,
> >  			   enum dma_data_direction dir, unsigned long attrs)
> >  {
> > -	vmd_dma_ops(dev)->unmap_page(to_vmd_dev(dev), addr, size, dir, attrs)=
;
> > +	dma_unmap_page_attrs(to_vmd_dev(dev), addr, size, dir, attrs);
> >  }
> > =20
> >  static int vmd_map_sg(struct device *dev, struct scatterlist *sg, int =
nents,
> >  		      enum dma_data_direction dir, unsigned long attrs)
> >  {
> > -	return vmd_dma_ops(dev)->map_sg(to_vmd_dev(dev), sg, nents, dir, attr=
s);
> > +	return dma_map_sg_attrs(to_vmd_dev(dev), sg, nents, dir, attrs);
> >  }
> > =20
> >  static void vmd_unmap_sg(struct device *dev, struct scatterlist *sg, i=
nt nents,
> >  			 enum dma_data_direction dir, unsigned long attrs)
> >  {
> > -	vmd_dma_ops(dev)->unmap_sg(to_vmd_dev(dev), sg, nents, dir, attrs);
> > +	dma_unmap_sg_attrs(to_vmd_dev(dev), sg, nents, dir, attrs);
> >  }
> > =20
> >  static void vmd_sync_single_for_cpu(struct device *dev, dma_addr_t add=
r,
> >  				    size_t size, enum dma_data_direction dir)
> >  {
> > -	vmd_dma_ops(dev)->sync_single_for_cpu(to_vmd_dev(dev), addr, size, di=
r);
> > +	dma_sync_single_for_cpu(to_vmd_dev(dev), addr, size, dir);
> >  }
> > =20
> >  static void vmd_sync_single_for_device(struct device *dev, dma_addr_t =
addr,
> >  				       size_t size, enum dma_data_direction dir)
> >  {
> > -	vmd_dma_ops(dev)->sync_single_for_device(to_vmd_dev(dev), addr, size,
> > -						 dir);
> > +	dma_sync_single_for_device(to_vmd_dev(dev), addr, size, dir);
> >  }
> > =20
> >  static void vmd_sync_sg_for_cpu(struct device *dev, struct scatterlist=
 *sg,
> >  				int nents, enum dma_data_direction dir)
> >  {
> > -	vmd_dma_ops(dev)->sync_sg_for_cpu(to_vmd_dev(dev), sg, nents, dir);
> > +	dma_sync_sg_for_cpu(to_vmd_dev(dev), sg, nents, dir);
> >  }
> > =20
> >  static void vmd_sync_sg_for_device(struct device *dev, struct scatterl=
ist *sg,
> >  				   int nents, enum dma_data_direction dir)
> >  {
> > -	vmd_dma_ops(dev)->sync_sg_for_device(to_vmd_dev(dev), sg, nents, dir)=
;
> > +	dma_sync_sg_for_device(to_vmd_dev(dev), sg, nents, dir);
> >  }
> > =20
> >  static int vmd_dma_supported(struct device *dev, u64 mask)
> >  {
> > -	return vmd_dma_ops(dev)->dma_supported(to_vmd_dev(dev), mask);
> > +	return dma_supported(to_vmd_dev(dev), mask);
> >  }
> > =20
> >  static u64 vmd_get_required_mask(struct device *dev)
> >  {
> > -	return vmd_dma_ops(dev)->get_required_mask(to_vmd_dev(dev));
> > +	return dma_get_required_mask(to_vmd_dev(dev));
> >  }
> > =20
> >  static void vmd_teardown_dma_ops(struct vmd_dev *vmd)
> > --=20
> > 2.19.1
> >=20
--=-9E1D7a0ir8jkFqgEIfO9
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

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
PNauajAtxgRKfqfSMb+IcL/VXiPtVZOxVq+CTZeDJkaEmn/79vg8OYxpR+YhFF+tGlKf/Zc4id1P
AgMBAAGjggI3MIICMzAdBgNVHQ4EFgQU4oawcWXM1cPGdwGcIszDfjORVZAwHwYDVR0jBBgwFoAU
HmkqtNwo/kcYTiELP7ysES/wmPUwZQYDVR0fBF4wXDBaoFigVoZUaHR0cDovL3d3dy5pbnRlbC5j
b20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUyMENB
JTIwNEEuY3JsMIGfBggrBgEFBQcBAQSBkjCBjzBpBggrBgEFBQcwAoZdaHR0cDovL3d3dy5pbnRl
bC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIw
SXNzdWluZyUyMENBJTIwNEEuY3J0MCIGCCsGAQUFBzABhhZodHRwOi8vb2NzcC5pbnRlbC5jb20v
MAsGA1UdDwQEAwIHgDA8BgkrBgEEAYI3FQcELzAtBiUrBgEEAYI3FQiGw4x1hJnlUYP9gSiFjp9T
gpHACWeB3r05lfBDAgFkAgEJMB8GA1UdJQQYMBYGCCsGAQUFBwMEBgorBgEEAYI3CgMMMCkGCSsG
AQQBgjcVCgQcMBowCgYIKwYBBQUHAwQwDAYKKwYBBAGCNwoDDDBRBgNVHREESjBIoCoGCisGAQQB
gjcUAgOgHAwaam9uYXRoYW4uZGVycmlja0BpbnRlbC5jb22BGmpvbmF0aGFuLmRlcnJpY2tAaW50
ZWwuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQBxGkHe05DNpYel4b9WbbyQqD1G6y6YA6C93TjKULZi
p8+gO1LL096ixD44+frVm3jtXMikoadRHQJmBJdzsCywNE1KgtrYF0k4zRWr7a28nyfGgQe4UHHD
7ARyZFeGd7AKSQ1y4/LU57I2Aw2HKx9/PXavv1JXjjO2/bqTfnZDJTQmOQ0nvlO3/gvbbABxZHqz
NtfHZsQWS7s+Elk2xGUQ0Po2pMCQoaPo9R96mm+84UP9q3OvSqMoaZwfzoUeAx2wGJYl0h3S+ABr
CPVfCgq9qnmVCn5DyHWE3V/BRjJCoILLBLxAxnmSdH4pF6wJ6pYRLEw9qoyNhpzGUIJU/Lk1MYIC
FzCCAhMCAQEwgZAweTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNBMRQwEgYDVQQHEwtTYW50YSBD
bGFyYTEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFs
IEJhc2ljIElzc3VpbmcgQ0EgNEECEzMAAMamAkocC+WQNPgAAAAAxqYwCQYFKw4DAhoFAKBdMBgG
CSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE4MTIxNDIxMzQzN1owIwYJ
KoZIhvcNAQkEMRYEFK7zC/uHskddgHFj61MTCip8FKViMA0GCSqGSIb3DQEBAQUABIIBAJzKQJAe
2tvDuvtNXIvTKMqBHNncZjrGPda2y86cWqiDaQj+f+bJDfmE/I2ns1X/x93TXscn7K63zEfpuZWp
sFoZEl2grOPxeiNQ327E8NXBgUQY+JAbWCRpn3BXC3McSJlaVIihVHvBkafsrN18qHzdgSeewlbL
3lWJtC8VFQwsZjg21OZVuibrDo+8VZijh7F0arfHfzcKyGyxCK/UHNeMooM2FK5W83AakV2EA6lz
WNirX2RxXqQyDcpkvvHT1nP+MZf9vzerqc81YFQpR/qYuVLsyffVPJclFseCql0fixQi4y5Sbsvs
C/NHHvl2wmD3/J1CYwaeCk0rwvRItrgAAAAAAAA=


--=-9E1D7a0ir8jkFqgEIfO9--
