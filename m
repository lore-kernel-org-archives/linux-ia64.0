From: nomura@hpc.bs1.fc.nec.co.jp
Date: Wed, 15 Nov 2000 14:10:38 +0000
Subject: Re: [Linux-ia64] SW IO TLB buffer management in kernel test10
Message-Id: <marc-linux-ia64-105590678205722@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205720@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205720@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

From: Hirofumi Fujita <h-fujita@ebina.hitachi.co.jp>
Subject: [Linux-ia64] SW IO TLB buffer management in kernel test10
Date: Wed, 15 Nov 2000 17:15:52 +0900

> there seems to be a problem on buffer management of SW IO TLB.
> The contents of io_tlb_list[] become broken.
...
> I applied the attached patch and kernel panic when mke2fs /dev/sda4.
> (QLogic BIOS setting: >4GB addressing is disabled)
> Kernel panic: __pci_map_single: could not allocate software IO TLB (16384=
 bytes)
> At this time, io_tlb_list[] are almost 0.
...
> With swiotlb=8192 option, mke2fs successes,
> but 60% of io_tlb_list[] remain 0 after mke2fs finished.
> This is because pci_unmap is not called correctly ?

I think it's because your patch makes pci_unmap do nothing on io_tlb_list[].
In __pci_unmap_single, making 2 steps apart has its meaning.

The patch should be something like this?

--- arch/ia64/kernel/pci-dma.c	2000/11/07 06:49:39	1.1.1.4.2.1
+++ arch/ia64/kernel/pci-dma.c	2000/11/15 13:50:28
@@ -109,7 +109,8 @@
 {
 	unsigned long flags;
 	char *dma_addr;
-	unsigned int i, nslots, stride, index, wrap;
+	unsigned int nslots, stride, index, wrap, count;
+	int i;
=20
 	/*
 	 * For mappings greater than a page size, we limit the stride (and hence =
alignment)
@@ -133,7 +134,7 @@
 		wrap =3D index =3D ALIGN(io_tlb_index, stride);
=20
 		if (index >=3D io_tlb_nslabs)=20
-			index =3D 0;
+			wrap =3D index =3D 0;
=20
 		do {
 			/*
@@ -144,6 +145,9 @@
 			if (io_tlb_list[index] >=3D nslots) {
 				for (i =3D index; i < index + nslots; i++)
 					io_tlb_list[i] =3D 0;
+				count =3D 0;
+				for (i =3D index - 1; (i >=3D 0) && io_tlb_list[i]; i--)
+					io_tlb_list[i] =3D ++count;
 				dma_addr =3D io_tlb_start + (index << IO_TLB_SHIFT);
=20
 				/*

--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.



