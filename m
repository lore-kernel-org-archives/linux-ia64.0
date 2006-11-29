From: xb <xavier.bru@bull.net>
Date: Wed, 29 Nov 2006 14:57:22 +0000
Subject: ia64 ORDERROUNDDOWN issue
Message-Id: <456D9FD2.2070906@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010404030909040405020906"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010404030909040405020906
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Hello all,

On some ia64 NUMA platforms with some specific memory configurations, 
the 2.6.18.3 kernel crashes at system initialisation due to conflict for 
allocating DMA memory.
The machine has the following memory configuration:

physical address       length      node
0                      2GB         0
4GB                    4GB         1
8GB                    2GB         0

We use 64 KB pages and the default CONFIG_FORCE_MAX_ZONEORDER=17 value, 
that provides the availability to use 4GB huge pages   ( 2^(17-1)*2^16 B).

After some investigations I stated that count_node_pages() was computing 
mem_data[1].min_pfn = 0, and mem_data[1].max_pfn = 20000 for node 1, 
thus conflicting with the 0-2GB DMA memory range on node 0.
This is due to the line:
    start = ORDERROUNDDOWN(start);
that computes the value 0 for the 0x100000000 (4GB) address.
I suppose the goal was to check that the memory range is aligned on a 
4GB boundary ( 2^(17-1)*2^16 Bytes), and in our case there should be no 
round of ht value.
I fixed the ORDERROUNDDOWN macro and system boots OK.

It is not sure that this fixes the problem in all cases: with a 
CONFIG_FORCE_MAX_ZONEORDER=18 value, the ORDERROUNDDOWN macro would have 
generated the same problem (mem_data[1].min_pfn=0). This should at least 
be checked in the count_node_pages() function.

--- linux-2.6.18.3/include/asm-ia64/meminit.h    2006-11-19 
04:28:22.000000000 +0100
+++ linux-2.6.18.3new/include/asm-ia64/meminit.h    2006-11-29 
15:23:37.000000000 +0100
@@ -40,7 +40,7 @@
  */
 #define GRANULEROUNDDOWN(n)    ((n) & ~(IA64_GRANULE_SIZE-1))
 #define GRANULEROUNDUP(n)    (((n)+IA64_GRANULE_SIZE-1) & 
~(IA64_GRANULE_SIZE-1))
-#define ORDERROUNDDOWN(n)    ((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
+#define ORDERROUNDDOWN(n)    ((n) & ~((PAGE_SIZE<<(MAX_ORDER-1))-1))
 
 #ifdef CONFIG_NUMA
   extern void call_pernode_memory (unsigned long start, unsigned long 
len, void *func);

- traces 
---------------------------------------------------------------------------------------------------
all_unreclaimable? no
lowmem_reserve[]: 0 0 256 256Linux version 2.6.18.3
...
SRAT Memory (0x0000000000000000 length 0x0000000080000000 type 0x0) in 
proximity domain 0 enabled
SRAT Memory (0x0000000200000000 length 0x0000000080000000 type 0x0) in 
proximity domain 0 enabled
SRAT Memory (0x0000000100000000 length 0x0000000100000000 type 0x0) in 
proximity domain 1 enabled
Number of logical nodes in system = 2
Number of memory chunks in system = 3
...

    ide0: BM-DMA at 0x2080-0x2087<4>swapper: page allocation failure. 
order:0, mode:0x21

Call Trace:
 [<a000000100010c30>] show_stack+0x50/0xa0
                                sp=e000000100cdfbf0 bsp=e000000100cd13c8
 [<a000000100010cb0>] dump_stack+0x30/0x60
                                sp=e000000100cdfdc0 bsp=e000000100cd13b0
 [<a0000001000e5f00>] __alloc_pages+0x500/0x540
                                sp=e000000100cdfdc0 bsp=e000000100cd1348
 [<a000000100119830>] alloc_page_interleave+0xd0/0x160
                                sp=e000000100cdfdd0 bsp=e000000100cd1318
 [<a0000001001199f0>] alloc_pages_current+0x130/0x1a0
                                sp=e000000100cdfdd0 bsp=e000000100cd12e8
 [<a0000001000e5f70>] __get_free_pages+0x30/0x100
                                sp=e000000100cdfdd0 bsp=e000000100cd12c0
 [<a0000001003369b0>] swiotlb_alloc_coherent+0x70/0x280
                                sp=e000000100cdfdd0 bsp=e000000100cd1280
 [<a00000010044e510>] ide_setup_dma+0x430/0x8c0
                                sp=e000000100cdfdd0 bsp=e000000100cd1240
 [<a00000010044b2c0>] ide_pci_setup_ports+0xd60/0xea0
                                sp=e000000100cdfdd0 bsp=e000000100cd11a8
 [<a00000010044bc00>] do_ide_setup_pci_device+0x800/0x840
                                sp=e000000100cdfde0 bsp=e000000100cd1138
 [<a00000010044bc80>] ide_setup_pci_device+0x40/0x140
                                sp=e000000100cdfdf0 bsp=e000000100cd1100
 [<a0000001004322d0>] piix_init_one+0x50/0x80
                                sp=e000000100cdfe00 bsp=e000000100cd10d8
 [<a0000001006c8230>] ide_scan_pcidev+0xf0/0x180
                                sp=e000000100cdfe00 bsp=e000000100cd10a8
 [<a0000001006c8300>] ide_scan_pcibus+0x40/0x1e0
                                sp=e000000100cdfe00 bsp=e000000100cd1080
 [<a0000001006c8110>] ide_init+0xb0/0xe0
                                sp=e000000100cdfe00 bsp=e000000100cd1060
 [<a000000100009640>] init+0x380/0x7a0
                                sp=e000000100cdfe00 bsp=e000000100cd1020
 [<a000000100012dd0>] kernel_thread_helper+0xd0/0x100
                                sp=e000000100cdfe30 bsp=e000000100cd0ff0
 [<a000000100009140>] start_kernel_thread+0x20/0x40
                                sp=e000000100cdfe30 bsp=e000000100cd0ff0
Mem-info:

Node 0 DMA free:0kB min:2688kB low:3328kB high:4032kB active:0kB 
inactive:0kB present:1943936kB pages_scanned:0 all_unreclaimable? yes
Node 1 DMA free:1876352kB min:0kB low:0kB high:0kB active:0kB 
inactive:0kB present:0kB


--------------010404030909040405020906
Content-Transfer-Encoding: 7bit
Content-Type: text/x-vcard; charset=utf-8;
 name="xavier.bru.vcf"
Content-Disposition: attachment;
 filename="xavier.bru.vcf"

begin:vcard
fn:Xavier Bru
n:Bru;Xavier
adr:;;1 rue de Provence, BP 208;38432 Echirolles Cedex;;;France
email;internet:Xavier.Bru@bull.net
title:BULL/DT/Open Software/linux/ia64
tel;work:+33 (0)4 76 29 77 45
tel;fax:+33 (0)4 76 29 77 70 
x-mozilla-html:TRUE
url:http://www.bull.com
version:2.1
end:vcard


--------------010404030909040405020906--
