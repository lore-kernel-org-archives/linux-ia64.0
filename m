From: John Hesterberg <jh@sgi.com>
Date: Mon, 03 Dec 2001 15:02:33 +0000
Subject: Re: [Linux-ia64] No include/asm-ia64/mmzone.h in 2.4.16-ia64-011128
Message-Id: <marc-linux-ia64-105590698805581@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sun, Dec 02, 2001 at 08:10:31PM -0600, John Hesterberg wrote:
> On Sun, Dec 02, 2001 at 05:12:27PM +1100, Keith Owens wrote:
> > On Sat, 1 Dec 2001 23:27:14 -0600,=20
> > John Hesterberg <jh@sgi.com> wrote:
> > >On Sun, Dec 02, 2001 at 03:23:01PM +1100, Keith Owens wrote:
> > >> I tried compiling 2.4.16-ia64-011128 as type SGI-SN1.  It broke at
> > >> include/linux/mmzone.h:138 trying to include asm/mmzone.h which does
> > >> not exist on ia64.  Is ia64-011128 supposed to compile sn1/sn2 out of
> > >> the box or are there extra patches required?
> > >
> > >No, as you've discovered, it's missing mmzone.h.
> >=20
> > Is that intentional or a mistake?
>=20
> Neither, really.  We'd like it to be at least buildable, but right
> now our SN specific code is tied to changes that are not yet in the
> non-SN specific code.  That makes it hard to come up with a
> version of the code that is reasonably current and still buildable.
>=20
> I think I have a patch for you to use, but the machine it's on just
> went belly up (grrr), so I'll have to wait until I get in to work
> tomorrow to recover the machine.  If you're ready to send to Linus,
> you'll have to decide if you want to wait or not. =20

Here's the patch.  It builds for SN1 and DIG, I didn't try anything
else.  It boots DIG, but probably won't boot SN1.

Some, most, or all of this patch will change before it makes it into
David's ia64 patch, so don't base other changes on it.  This is for
test building only.  It's as unofficial as it gets.

To build for SN1, use arch/ia64/sn/configs/sn1/defconfig-sn1-mp,
do make oldconfig, and take the default values for everything.

John


diff -Naur 2.4.16-ia64/linux/arch/ia64/kernel/smp.c 16i.sn/linux/arch/ia64/=
kernel/smp.c
--- 2.4.16-ia64/linux/arch/ia64/kernel/smp.c	Fri Nov  9 22:26:17 2001
+++ 16i.sn/linux/arch/ia64/kernel/smp.c	Sun Dec  2 22:58:29 2001
@@ -72,6 +72,11 @@
 #define IPI_CALL_FUNC		0
 #define IPI_CPU_STOP		1
=20
+#ifdef CONFIG_IA64_SGI_SN1
+#define IPI_FLUSH_TLB		3
+#endif
+
+
 static void
 stop_this_cpu (void)
 {
@@ -315,6 +320,14 @@
 	send_IPI_allbutself(IPI_CPU_STOP);
 	smp_num_cpus =3D 1;
 }
+
+#ifdef CONFIG_IA64_SGI_SN1
+void
+smp_send_flush_tlb (void)
+{
+        send_IPI_allbutself(IPI_FLUSH_TLB);
+}
+#endif
=20
 int __init
 setup_profiling_timer (unsigned int multiplier)
diff -Naur 2.4.16-ia64/linux/arch/ia64/sn/io/klconflib.c 16i.sn/linux/arch/=
ia64/sn/io/klconflib.c
--- 2.4.16-ia64/linux/arch/ia64/sn/io/klconflib.c	Sun Dec  2 22:22:05 2001
+++ 16i.sn/linux/arch/ia64/sn/io/klconflib.c	Sun Dec  2 23:42:45 2001
@@ -302,10 +302,7 @@
 int
 get_cpu_slice(cpuid_t cpu)
 {
-	klcpu_t *acpu;
-	if ((acpu =3D get_cpuinfo(cpu)) =3D NULL)
-	    return -1;
-	return acpu->cpu_info.physid;
+	return -1;
 }
=20
=20
diff -Naur 2.4.16-ia64/linux/arch/ia64/sn/kernel/setup.c 16i.sn/linux/arch/=
ia64/sn/kernel/setup.c
--- 2.4.16-ia64/linux/arch/ia64/sn/kernel/setup.c	Sun Dec  2 22:22:06 2001
+++ 16i.sn/linux/arch/ia64/sn/kernel/setup.c	Sun Dec  2 23:39:28 2001
@@ -40,7 +40,6 @@
 #include <asm/sn/sn2/shub.h>
 #endif
=20
-void platform_smp_callin(int);
 long sn_rtc_cycles_per_second;  =20
=20
 /*
@@ -249,13 +248,6 @@
         for (cnode=3D0; cnode<num_compact_nodes; cnode++)
 		memcpy(nodepdaindr[cnode]->pernode_pdaindr, nodepdaindr, sizeof(nodepdai=
ndr));
=20
-
-	/*=20
-	 * For the bootcpu, we do this here. All other cpus will make the
-	 * call as part of smp_callin initialization.
-	 */
-	platform_smp_callin(smp_processor_id());
-
 	/*
 	 * Set up IO related platform-dependent nodepda fields.
 	 * The following routine actually sets up the hubinfo struct
@@ -265,21 +257,32 @@
 		init_platform_nodepda(nodepdaindr[cnode], cnode);
 }
=20
-/*
- * platform_smp_callin
+/**
+ * sn_cpu_init - initialize per-cpu data areas
+ * @cpuid: cpuid of the caller
  *
  * Called during cpu initialization on each cpu as it starts.
  * Currently, initializes the per-cpu data area for SNIA.
- * Also setup up a few fields in the nodepda.
+ * Also sets up a few fields in the nodepda.  Also known as
+ * platform_cpu_init() by the ia64 machvec code.
  */
 void __init
-platform_smp_callin(int cpuid)
+sn_cpu_init(void)
 {
+	int	cpuid;
 	int	cpuphyid;
 	int	nasid;
 	int	slice;
 	int	cnode;
=20
+	/*
+	 * The boot cpu makes this call again after platform initialization is
+	 * complete.
+	 */
+	if (nodepdaindr[0] =3D NULL)
+		return;
+
+	cpuid =3D smp_processor_id();
 	cpuphyid =3D ((ia64_get_lid() >> 16) & 0xffff);
 	nasid =3D cpu_physical_id_to_nasid(cpuphyid);
 	cnode =3D nasid_to_cnodeid(nasid);
@@ -292,10 +295,6 @@
 	pda.hb_state =3D 0;
 	pda.idle_flag =3D 0;
 =09
-	if (nodepda->node_num_cpus =3D 0)
-		nodepda->node_first_cpu =3D cpuid;
-	nodepda->node_num_cpus++;
-
 #ifdef CONFIG_IA64_SGI_SN1
 	{
 		int	synergy;
@@ -305,14 +304,15 @@
 #endif
=20
 #ifdef CONFIG_IA64_SGI_SN2
+
 	/*
-	 * We must use different memory allocators for first cpu (bootmem allocat=
or)
-	 * than for the other cpus (regular allocator).
+	 * We must use different memory allocators for first cpu (bootmem=20
+	 * allocator) than for the other cpus (regular allocator).
 	 */
 	if (cpuid =3D 0)
 		irqpdaindr[cpuid] =3D alloc_bootmem_node(NODE_DATA(cpuid_to_cnodeid(cpui=
d)),sizeof(irqpda_t));
 	else
-		irqpdaindr[cpuid] =3D page_address(alloc_pages_node(numa_node_id(), GFP_=
KERNEL, get_order(sizeof(irqpda_t))));
+		irqpdaindr[cpuid] =3D page_address(alloc_pages_node(local_cnodeid(), GFP=
_KERNEL, get_order(sizeof(irqpda_t))));
 	memset(irqpdaindr[cpuid], 0, sizeof(irqpda_t));
 	pda.p_irqpda =3D irqpdaindr[cpuid];
 #endif
diff -Naur 2.4.16-ia64/linux/drivers/net/ioc3-eth.c 16i.sn/linux/drivers/ne=
t/ioc3-eth.c
--- 2.4.16-ia64/linux/drivers/net/ioc3-eth.c	Wed Oct 17 04:56:29 2001
+++ 16i.sn/linux/drivers/net/ioc3-eth.c	Sun Dec  2 22:58:29 2001
@@ -6,7 +6,8 @@
  * Driver for SGI's IOC3 based Ethernet cards as found in the PCI card.
  *
  * Copyright (C) 1999, 2000, 2001 Ralf Baechle
- * Copyright (C) 1995, 1999, 2000, 2001 by Silicon Graphics, Inc.
+ * Copyright (C) 1995, 1999-2001 Silicon Graphics, Inc.
+ * All rights reserved.
  *
  * References:
  *  o IOC3 ASIC specification 4.51, 1996-04-18
@@ -26,6 +27,7 @@
  *    which workarounds are required for them?  Do we ever have Lucent's?
  *  o For the 2.5 branch kill the mii-tool ioctls.
  */
+#include <linux/types.h>
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/kernel.h>
@@ -33,14 +35,6 @@
 #include <linux/errno.h>
 #include <linux/module.h>
 #include <linux/pci.h>
-
-#ifdef CONFIG_SERIAL
-#include <linux/serial.h>
-#include <asm/serial.h>
-#define IOC3_BAUD (22000000 / (3*16))
-#define IOC3_COM_FLAGS (ASYNC_BOOT_AUTOCONF | ASYNC_SKIP_TEST)
-#endif
-
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -52,13 +46,39 @@
 #include <asm/pgtable.h>
 #include <asm/uaccess.h>
 #include <asm/sn/types.h>
-#include <asm/sn/sn0/addrs.h>
-#include <asm/sn/sn0/hubni.h>
-#include <asm/sn/sn0/hubio.h>
+#include <asm/sn/addrs.h>
+#include <asm/sn/hack.h>
+#include <asm/sn/arch.h>
+#include <asm/sn/io.h>
 #include <asm/sn/klconfig.h>
 #include <asm/sn/ioc3.h>
-#include <asm/sn/sn0/ip27.h>
-#include <asm/pci/bridge.h>
+#include <asm/sn/pci/bridge.h>
+
+/* Generic MII registers defined in linux/mii.h, these below
+ * are DP83840 specific.
+ */
+#define MII_CSCONFIG            0x17     /* CS configuration            */
+
+/* The Carrier Sense config register. */
+#define CSCONFIG_RESV1          0x0001  /* Unused...                   */
+#define CSCONFIG_LED4           0x0002  /* Pin for full-dplx LED4      */
+#define CSCONFIG_LED1           0x0004  /* Pin for conn-status LED1    */
+#define CSCONFIG_RESV2          0x0008  /* Unused...                   */
+#define CSCONFIG_TCVDISAB       0x0010  /* Turns off the transceiver   */
+#define CSCONFIG_DFBYPASS       0x0020  /* Bypass disconnect function  */
+#define CSCONFIG_GLFORCE        0x0040  /* Good link force for 100mbps */
+#define CSCONFIG_CLKTRISTATE    0x0080  /* Tristate 25m clock          */
+#define CSCONFIG_RESV3          0x0700  /* Unused...                   */
+#define CSCONFIG_ENCODE         0x0800  /* 1=3DMLT-3, 0=3Dbinary          =
 */
+#define CSCONFIG_RENABLE        0x1000  /* Repeater mode enable        */
+#define CSCONFIG_TCDISABLE      0x2000  /* Disable timeout counter     */
+#define CSCONFIG_RESV4          0x4000  /* Unused...                   */
+#define CSCONFIG_NDISABLE       0x8000  /* Disable NRZI                */
+
+/* direct mapped dma's go to widget b in sn1, widget a in sn0
+ * both have Precise and Barrier flags set, sn1 also needs Swap=20
+ */
+/* #define DMA_WIDGET      0xb50UL */
=20
 /*
  * 64 RX buffers.  This is tunable in the range of 16 <=3D x < 512.  The
@@ -77,6 +97,8 @@
 /* Private per NIC data of the driver.  */
 struct ioc3_private {
 	struct ioc3 *regs;
+	struct pci_dev *pdev;
+	unsigned long dma_attributes;
 	int phy;
 	unsigned long *rxr;		/* pointer to receiver ring */
 	struct ioc3_etxd *txr;
@@ -113,6 +135,7 @@
 static inline void ioc3_stop(struct ioc3_private *ip);
 static void ioc3_init(struct ioc3_private *ip);
=20
+
 static const char ioc3_str[] =3D "IOC3 Ethernet";
=20
 /* We use this to acquire receive skb's that we can DMA directly into. */
@@ -136,9 +159,13 @@
 #define RX_BUF_ALLOC_SIZE	(1664 + RX_OFFSET + 128)
=20
 /* DMA barrier to separate cached and uncached accesses.  */
+#if defined(__ia64__)
+#include <asm/processor.h>
+#define BARRIER() ia64_sync_i(); ia64_srlz_i(); ia64_srlz_d()
+#else
 #define BARRIER()							\
 	__asm__("sync" ::: "memory")
-
+#endif /* __ia64__ */
=20
 #define IOC3_SIZE 0x100000
=20
@@ -160,221 +187,82 @@
 	return (pulse << 10) | (sample << 2);
 }
=20
-static int
-nic_wait(struct ioc3 *ioc3)
-{
-	u32 mcr;
-
-        do {
-                mcr =3D ioc3_r(mcr);
-        } while (!(mcr & 2));
-
-        return mcr & 1;
-}
-
-static int
-nic_reset(struct ioc3 *ioc3)
-{
-        int presence;
-
-	ioc3_w(mcr, mcr_pack(500, 65));
-	presence =3D nic_wait(ioc3);
-
-	ioc3_w(mcr, mcr_pack(0, 500));
-	nic_wait(ioc3);
-
-        return presence;
-}
-
-static inline int
-nic_read_bit(struct ioc3 *ioc3)
-{
-	int result;
-
-	ioc3_w(mcr, mcr_pack(6, 13));
-	result =3D nic_wait(ioc3);
-	ioc3_w(mcr, mcr_pack(0, 100));
-	nic_wait(ioc3);
-
-	return result;
-}
-
-static inline void
-nic_write_bit(struct ioc3 *ioc3, int bit)
-{
-	if (bit)
-		ioc3_w(mcr, mcr_pack(6, 110));
-	else
-		ioc3_w(mcr, mcr_pack(80, 30));
-
-	nic_wait(ioc3);
-}
-
-/*
- * Read a byte from an iButton device
- */
-static u32
-nic_read_byte(struct ioc3 *ioc3)
-{
-	u32 result =3D 0;
-	int i;
-
-	for (i =3D 0; i < 8; i++)
-		result =3D (result >> 1) | (nic_read_bit(ioc3) << 7);
-
-	return result;
-}
-
 /*
- * Write a byte to an iButton device
- */
-static void
-nic_write_byte(struct ioc3 *ioc3, int byte)
-{
-	int i, bit;
-
-	for (i =3D 8; i; i--) {
-		bit =3D byte & 1;
-		byte >>=3D 1;
-
-		nic_write_bit(ioc3, bit);
-	}
-}
-
-static u64
-nic_find(struct ioc3 *ioc3, int *last)
-{
-	int a, b, index, disc;
-	u64 address =3D 0;
-
-	nic_reset(ioc3);
-	/* Search ROM.  */
-	nic_write_byte(ioc3, 0xf0);
-
-	/* Algorithm from ``Book of iButton Standards''.  */
-	for (index =3D 0, disc =3D 0; index < 64; index++) {
-		a =3D nic_read_bit(ioc3);
-		b =3D nic_read_bit(ioc3);
-
-		if (a && b) {
-			printk("NIC search failed (not fatal).\n");
-			*last =3D 0;
-			return 0;
-		}
-
-		if (!a && !b) {
-			if (index =3D *last) {
-				address |=3D 1UL << index;
-			} else if (index > *last) {
-				address &=3D ~(1UL << index);
-				disc =3D index;
-			} else if ((address & (1UL << index)) =3D 0)
-				disc =3D index;
-			nic_write_bit(ioc3, address & (1UL << index));
-			continue;
-		} else {
-			if (a)
-				address |=3D 1UL << index;
-			else
-				address &=3D ~(1UL << index);
-			nic_write_bit(ioc3, a);
-			continue;
-		}
-	}
-
-	*last =3D disc;
-
-	return address;
-}
-
-static int nic_init(struct ioc3 *ioc3)
-{
-	const char *type;
-	u8 crc;
-	u8 serial[6];
-	int save =3D 0, i;
-
-	type =3D "unknown";
-
-	while (1) {
-		u64 reg;
-		reg =3D nic_find(ioc3, &save);
-
-		switch (reg & 0xff) {
-		case 0x91:
-			type =3D "DS1981U";
-			break;
-		default:
-			if (save =3D 0) {
-				/* Let the caller try again.  */
-				return -1;
-			}
-			continue;
-		}
-
-		nic_reset(ioc3);
-
-		/* Match ROM.  */
-		nic_write_byte(ioc3, 0x55);
-		for (i =3D 0; i < 8; i++)
-			nic_write_byte(ioc3, (reg >> (i << 3)) & 0xff);
-
-		reg >>=3D 8; /* Shift out type.  */
-		for (i =3D 0; i < 6; i++) {
-			serial[i] =3D reg & 0xff;
-			reg >>=3D 8;
-		}
-		crc =3D reg & 0xff;
-		break;
-	}
-
-	printk("Found %s NIC", type);
-	if (type !=3D "unknown") {
-		printk (" registration number %02x:%02x:%02x:%02x:%02x:%02x,"
-			" CRC %02x", serial[0], serial[1], serial[2],
-			serial[3], serial[4], serial[5], crc);
-	}
-	printk(".\n");
-
-	return 0;
-}
-
-/*
- * Read the NIC (Number-In-a-Can) device.
+ * Get the ether-address
  */
 static void ioc3_get_eaddr(struct ioc3_private *ip)
 {
+	int ibrick_mac_addr_get(nasid_t, char *);
 	struct ioc3 *ioc3 =3D ip->regs;
-	u8 nic[14];
-	int i;
-	int tries =3D 2; /* There may be some problem with the battery?  */
+	nasid_t nasid_of_ioc3;
+	char io7eaddr[20];
+	long mac;
+	int err_val, i;
=20
-	ioc3_w(gpcr_s, (1 << 21));
-
-	while (tries--) {
-		if (!nic_init(ioc3))
-			break;
-		udelay(500);
-	}
-
-	if (tries < 0) {
-		printk("Failed to read MAC address\n");
-		return;
-	}
+	/*
+	 * err_val =3D ibrick_mac_addr_get(get_nasid(), io7eaddr );
+	 *=20
+	 * BAD!!  The above call uses get_nasid() and assumes that
+	 * the ioc3 pointed to by struct ioc3 is hooked up to the
+	 * cbrick that we're running on.  The proper way to make this call
+	 * is to figure out which nasid the ioc3 is connected to
+	 * and use that to call ibrick_mac_addr_get.  Below is
+	 * a hack to do just that.
+	 */
=20
-	/* Read Memory.  */
-	nic_write_byte(ioc3, 0xf0);
-	nic_write_byte(ioc3, 0x00);
-	nic_write_byte(ioc3, 0x00);
+	/*
+	 * Get the nasid of the ioc3 from the ioc3's base addr.
+	 * FIXME: the 8 at the end assumes we're in memory mode,=20
+	 * not node mode (for that, we'd change it to a 9).
+	 * Is there a call to extract this info from a physical
+	 * addr somewhere in an sn header file already?  If so,
+	 * we should probably use that, or restructure this routine
+	 * to use pci_dev and generic numa nodeid getting stuff.
+	 */
+	nasid_of_ioc3 =3D (((unsigned long)ioc3 >> 33) & ~(-1 << 8));
+	err_val =3D ibrick_mac_addr_get(nasid_of_ioc3, io7eaddr );
=20
-	for (i =3D 13; i >=3D 0; i--)
-		nic[i] =3D nic_read_byte(ioc3);
=20
+	if (err_val) {
+		/* Couldn't read the eeprom; try OSLoadOptions. */
+		printk("WARNING: ibrick_mac_addr_get failed: %d\n", err_val);
+
+		/* this is where we hardwire the mac address
+ 		 * 1st ibrick had 08:00:69:11:34:75
+ 		 * 2nd ibrick had 08:00:69:11:35:35
+ 		 *
+ 		 * Eagan Machines:
+ 		 *      mankato1 08:00:69:11:BE:95
+ 		 *      warroad  08:00:69:11:bd:60
+ 		 *      duron    08:00:69:11:34:60
+ 		 *
+ 		 * an easy way to get the mac address is to hook
+ 		 * up an ip35, then from L1 do 'cti serial'
+ 		 * and then look for MAC line XXX THIS DOESN"T QUITE WORK!!
+ 		 */
+		printk("ioc3_get_eaddr: setting ethernet address to:\n -----> ");
+		ip->dev->dev_addr[0] =3D 0x8;
+		ip->dev->dev_addr[1] =3D 0x0;
+		ip->dev->dev_addr[2] =3D 0x69;
+		ip->dev->dev_addr[3] =3D 0x11;
+		ip->dev->dev_addr[4] =3D 0x34;
+		ip->dev->dev_addr[5] =3D 0x60;
+	}
+	else {
+		long simple_strtol(const char *,char **,unsigned int);
+
+		mac =3D simple_strtol(io7eaddr, (char **)0, 16);
+		ip->dev->dev_addr[0] =3D (mac >> 40) & 0xff;
+		ip->dev->dev_addr[1] =3D (mac >> 32) & 0xff;
+		ip->dev->dev_addr[2] =3D (mac >> 24) & 0xff;
+		ip->dev->dev_addr[3] =3D (mac >> 16) & 0xff;
+		ip->dev->dev_addr[4] =3D (mac >> 8) & 0xff;
+		ip->dev->dev_addr[5] =3D mac & 0xff;
+	}
 	printk("Ethernet address is ");
-	for (i =3D 2; i < 8; i++) {
-		ip->dev->dev_addr[i - 2] =3D nic[i];
-		printk("%02x", nic[i]);
-		if (i < 7)
+	for (i =3D 0; i < 6; i++) {
+		printk("%02x", ip->dev->dev_addr[i]);
+		if (i < 5)
 			printk(":");
 	}
 	printk(".\n");
@@ -411,7 +299,7 @@
=20
 static struct net_device_stats *ioc3_get_stats(struct net_device *dev)
 {
-	struct ioc3_private *ip =3D dev->priv;
+	struct ioc3_private *ip =3D (struct ioc3_private *) dev->priv;
 	struct ioc3 *ioc3 =3D ip->regs;
=20
 	ip->stats.collisions +=3D (ioc3->etcdc & ETCDC_COLLCNT_MASK);
@@ -434,10 +322,10 @@
=20
 	skb =3D ip->rx_skbs[rx_entry];
 	rxb =3D (struct ioc3_erxbuf *) (skb->data - RX_OFFSET);
-	w0 =3D rxb->w0;
+	w0 =3D ntohl(rxb->w0);
=20
 	while (w0 & ERXBUF_V) {
-		err =3D rxb->err;				/* It's valid ...  */
+		err =3D ntohl(rxb->err);			/* It's valid ...  */
 		if (err & ERXBUF_GOODPKT) {
 			len =3D ((w0 >> ERXBUF_BYTECNT_SHIFT) & 0x7ff) - 4;
 			skb_trim(skb, len);
@@ -478,8 +366,9 @@
 			ip->stats.rx_frame_errors++;
 next:
 		ip->rx_skbs[n_entry] =3D new_skb;
-		rxr[n_entry] =3D (0xa5UL << 56) |
+		rxr[n_entry] =3D (ip->dma_attributes) |
 		                ((unsigned long) rxb & TO_PHYS_MASK);
+		rxr[n_entry] =3D cpu_to_be64(rxr[n_entry]);
 		rxb->w0 =3D 0;				/* Clear valid flag */
 		n_entry =3D (n_entry + 1) & 511;		/* Update erpir */
=20
@@ -487,7 +376,7 @@
 		rx_entry =3D (rx_entry + 1) & 511;
 		skb =3D ip->rx_skbs[rx_entry];
 		rxb =3D (struct ioc3_erxbuf *) (skb->data - RX_OFFSET);
-		w0 =3D rxb->w0;
+		w0 =3D ntohl(rxb->w0);
 	}
 	ioc3->erpir =3D (n_entry << 3) | ERPIR_ARM;
 	ip->rx_pi =3D n_entry;
@@ -614,9 +503,10 @@
  * configurations and we stop when we see a link-up condition before the
  * maximum number of "peek" ticks have occurred.
  *
- * Once a valid link status has been detected we configure the IOC3 to spe=
ak
- * the most efficient protocol we could get a clean link for.  The priority
- * for link configurations, highest first is:
+ * Once a valid link status has been detected we configure the BigMAC and =
the
+ * rest of the Happy Meal to speak the most efficient protocol we could
+ * get a clean link for.  The priority for link configurations, highest fi=
rst
+ * is:
  *
  *     100 Base-T Full Duplex
  *     100 Base-T Half Duplex
@@ -971,11 +861,11 @@
 		mii_write(ip, MII_ADVERTISE, ip->sw_advertise);
=20
 		/*
-		 * XXX Currently no IOC3 card I know off supports 100BaseT4,
-		 * XXX and this is because the DP83840 does not support it,
-		 * XXX changes XXX would need to be made to the tx/rx logic in
-		 * XXX the driver as well so I completely skip checking for it
-		 * XXX in the BMSR for now.
+		 * XXX Currently no Happy Meal cards I know off support
+		 * XXX 100BaseT4, XXX and this is because the DP83840 does not
+		 * XXX support it, changes XXX would need to be made to the
+		 * XXX tx/rx logic in the driver as well so I completely skip
+		 * XXX checking for it in the BMSR for now.
 		 */
=20
 #ifdef AUTO_SWITCH_DEBUG
@@ -998,7 +888,7 @@
 		ip->sw_bmcr |=3D BMCR_ANRESTART;
 		mii_write(ip, MII_BMCR, ip->sw_bmcr);
=20
-		/* BMCR_ANRESTART self clears when the process has begun. */
+		/* MII_CR_ANRESTART self clears when the process has begun. */
=20
 		timeout =3D 64;  /* More than enough. */
 		while (--timeout) {
@@ -1008,11 +898,10 @@
 			udelay(10);
 		}
 		if (!timeout) {
-			printk(KERN_ERR "%s: IOC3 would not start auto "
-			       "negotiation BMCR=3D0x%04x\n",
-			       ip->dev->name, ip->sw_bmcr);
-			printk(KERN_NOTICE "%s: Performing force link "
-			       "detection.\n", ip->dev->name);
+			printk(KERN_ERR "%s: IOC3 would not start auto negotiation "
+			       "BMCR=3D0x%04x\n", ip->dev->name, ip->sw_bmcr);
+			printk(KERN_NOTICE "%s: Performing force link detection.\n",
+			       ip->dev->name);
 			goto force_link;
 		} else {
 			ip->timer_state =3D arbwait;
@@ -1020,9 +909,9 @@
 	} else {
 force_link:
 		/*
-		 * Force the link up, trying first a particular mode.  Either
-		 * we are here at the request of ethtool or because the IOC3
-		 * would not start to autoneg.
+		 * Force the link up, trying first a particular mode.
+		 * Either we are here at the request of ethtool or
+		 * because the Happy Meal would not start to autoneg.
 		 */
=20
 		/*
@@ -1168,8 +1057,6 @@
 		/* Allocate and initialize rx ring.  4kb =3D 512 entries  */
 		ip->rxr =3D (unsigned long *) get_free_page(GFP_ATOMIC);
 		rxr =3D (unsigned long *) ip->rxr;
-		if (!rxr)
-			printk("ioc3_alloc_rings(): get_free_page() failed!\n");
=20
 		/* Now the rx buffers.  The RX ring may be larger but
 		   we only allocate 16 buffers for now.  Need to tune
@@ -1189,8 +1076,9 @@
 			/* Because we reserve afterwards. */
 			skb_put(skb, (1664 + RX_OFFSET));
 			rxb =3D (struct ioc3_erxbuf *) skb->data;
-			rxr[i] =3D (0xa5UL << 56)
+			rxr[i] =3D (ip->dma_attributes)
 				| ((unsigned long) rxb & TO_PHYS_MASK);
+			rxr[i] =3D cpu_to_be64(rxr[i]);
 			skb_reserve(skb, RX_OFFSET);
 		}
 		ip->rx_ci =3D 0;
@@ -1199,9 +1087,7 @@
=20
 	if (ip->txr =3D NULL) {
 		/* Allocate and initialize tx rings.  16kb =3D 128 bufs.  */
-		ip->txr =3D (struct ioc3_etxd *)__get_free_pages(GFP_KERNEL, 2);
-		if (!ip->txr)
-			printk("ioc3_alloc_rings(): get_free_page() failed!\n");
+		ip->txr =3D (struct ioc3_etxd *)__get_free_pages(GFP_ATOMIC, 2);
 		ip->tx_pi =3D 0;
 		ip->tx_ci =3D 0;
 	}
@@ -1220,13 +1106,13 @@
 	ioc3_clean_tx_ring(ip);
=20
 	/* Now the rx ring base, consume & produce registers.  */
-	ring =3D (0xa5UL << 56) | ((unsigned long)ip->rxr & TO_PHYS_MASK);
+	ring =3D (ip->dma_attributes) | ((unsigned long)ip->rxr & TO_PHYS_MASK);
 	ioc3->erbr_h =3D ring >> 32;
 	ioc3->erbr_l =3D ring & 0xffffffff;
 	ioc3->ercir  =3D (ip->rx_ci << 3);
 	ioc3->erpir  =3D (ip->rx_pi << 3) | ERPIR_ARM;
=20
-	ring =3D (0xa5UL << 56) | ((unsigned long)ip->txr & TO_PHYS_MASK);
+	ring =3D (ip->dma_attributes) | ((unsigned long)ip->txr & TO_PHYS_MASK);
=20
 	ip->txqlen =3D 0;					/* nothing queued  */
=20
@@ -1262,6 +1148,38 @@
 	}
 }
=20
+static void ioc3_phyreset(struct net_device *dev)
+{
+	struct ioc3_private *ip =3D dev->priv;
+	struct ioc3 *ioc3 =3D ip->regs;
+
+	/*
+ 	 * phyunreset()
+ 	 */
+	ioc3->gpcr_s =3D GPCR_PHY_RESET;
+	ioc3->gpcr_s;
+	ioc3->gppr_5 =3D 1;
+	ioc3->gppr_5;
+
+	/*
+ 	 * phyreset()
+ 	 */
+	ioc3->gppr_5 =3D 0;
+	ioc3->gppr_5;
+	ioc3->gppr_5 =3D 1;
+	ioc3->gppr_5;
+
+	/* #ifdef Colin */
+	{
+		int rval, wval;
+		rval =3D mii_read(ip, MII_DCOUNTER);
+		wval =3D (rval & ~(1<<5)) | (1<<5);
+		mii_write(ip, MII_DCOUNTER, (u16) wval);
+	}
+	/* #endif */
+
+}
+
 static void ioc3_init(struct ioc3_private *ip)
 {
 	struct net_device *dev =3D ip->dev;
@@ -1271,16 +1189,40 @@
=20
 	ioc3->emcr =3D EMCR_RST;			/* Reset		*/
 	ioc3->emcr;				/* Flush WB		*/
-	udelay(4);				/* Give it time ...	*/
+	while ( ((ioc3->emcr) & EMCR_ARB_DIAG_IDLE) =3D 0) {
+		printk("Waiting for EMCR_ARB_DIAG_IDLE ..\n");
+		udelay(4);
+	}
+
 	ioc3->emcr =3D 0;
 	ioc3->emcr;
=20
+        /*
+         * Errata from IOC3 4.4 spec,
+         * must explicitly clear tx/rx consume and produce pointers.
+         */
+        ioc3->etcir =3D 0;
+        ioc3->ercir =3D 0;
+        ioc3->etpir =3D 0;
+        ioc3->erpir =3D 0;
+
 	/* Misc registers  */
 	ioc3->erbar =3D 0;
+	/* irix (sn) sets it this way..we don't really have to
+	 * while we do all dma's with barrier set (i.e. bit 56 in
+	 * dma address)=20
+	 */
+	ioc3->erbar =3D (int)(PCI64_ATTR_BAR >> 32);
 	ioc3->etcsr =3D (17<<ETCSR_IPGR2_SHIFT) | (11<<ETCSR_IPGR1_SHIFT) | 21;
 	ioc3->etcdc;				/* Clear on read */
 	ioc3->ercsr =3D 15;			/* RX low watermark  */
 	ioc3->ertr =3D 0;				/* Interrupt immediately */
+/*
+ * This is a tradeoff between altency and bandwidth; we mostly
+ * choose bandwidth for now.  This should be figured out dynamically as
+ * on IRIX; at this time no Linux driver does it however.
+ */
+ioc3->ertr =3D 100;
 	ioc3->emar_h =3D (dev->dev_addr[5] << 8) | dev->dev_addr[4];
 	ioc3->emar_l =3D (dev->dev_addr[3] << 24) | (dev->dev_addr[2] << 16) |
 	               (dev->dev_addr[1] <<  8) | dev->dev_addr[0];
@@ -1304,6 +1246,7 @@
 	struct ioc3 *ioc3 =3D ip->regs;
=20
 	ioc3->emcr =3D 0;				/* Shutup */
+	ioc3->emcr;
 	ioc3->eier =3D 0;				/* Disable interrupts */
 	ioc3->eier;				/* Flush */
 }
@@ -1311,7 +1254,7 @@
 static int
 ioc3_open(struct net_device *dev)
 {
-	struct ioc3_private *ip =3D dev->priv;
+	struct ioc3_private *ip;
=20
 	if (request_irq(dev->irq, ioc3_interrupt, SA_SHIRQ, ioc3_str, dev)) {
 		printk(KERN_ERR "%s: Can't get irq %d\n", dev->name, dev->irq);
@@ -1319,11 +1262,14 @@
 		return -EAGAIN;
 	}
=20
+	ip =3D (struct ioc3_private *) dev->priv;
+
 	ip->ehar_h =3D 0;
 	ip->ehar_l =3D 0;
 	ioc3_init(ip);
=20
 	netif_start_queue(dev);
+
 	return 0;
 }
=20
@@ -1340,70 +1286,12 @@
 	free_irq(dev->irq, dev);
=20
 	ioc3_free_rings(ip);
-	return 0;
-}
=20
-/*
- * MENET cards have four IOC3 chips, which are attached to two sets of
- * PCI slot resources each: the primary connections are on slots
- * 0..3 and the secondaries are on 4..7
- *
- * All four ethernets are brought out to connectors; six serial ports
- * (a pair from each of the first three IOC3s) are brought out to
- * MiniDINs; all other subdevices are left swinging in the wind, leave
- * them disabled.
- */
-static inline int ioc3_is_menet(struct pci_dev *pdev)
-{
-	struct pci_dev *dev;
-
-	return pdev->bus->parent =3D NULL
-	       && (dev =3D pci_find_slot(pdev->bus->number, PCI_DEVFN(0, 0)))
-	       && dev->vendor =3D PCI_VENDOR_ID_SGI
-	       && dev->device =3D PCI_DEVICE_ID_SGI_IOC3
-	       && (dev =3D pci_find_slot(pdev->bus->number, PCI_DEVFN(1, 0)))
-	       && dev->vendor =3D PCI_VENDOR_ID_SGI
-	       && dev->device =3D PCI_DEVICE_ID_SGI_IOC3
-	       && (dev =3D pci_find_slot(pdev->bus->number, PCI_DEVFN(2, 0)))
-	       && dev->vendor =3D PCI_VENDOR_ID_SGI
-	       && dev->device =3D PCI_DEVICE_ID_SGI_IOC3;
-}
-
-static void inline ioc3_serial_probe(struct pci_dev *pdev,
-				struct ioc3 *ioc3)
-{
-	struct serial_struct req;
-
-	/*
-	 * We need to recognice and treat the fourth MENET serial as it
-	 * does not have an SuperIO chip attached to it, therefore attempting
-	 * to access it will result in bus errors.  We call something an
-	 * MENET if PCI slot 0, 1, 2 and 3 of a master PCI bus all have an IOC3
-	 * in it.  This is paranoid but we want to avoid blowing up on a
-	 * showhorn PCI box that happens to have 4 IOC3 cards in it so it's
-	 * not paranoid enough ...
-	 */
-	if (ioc3_is_menet(pdev) && PCI_SLOT(pdev->devfn) =3D 3)
-		return;
-
-	/* Register to interrupt zero because we share the interrupt with
-	   the serial driver which we don't properly support yet.  */
-	memset(&req, 0, sizeof(req));
-	req.irq             =3D 0;
-	req.flags           =3D IOC3_COM_FLAGS;
-	req.io_type         =3D SERIAL_IO_MEM;
-	req.iomem_reg_shift =3D 0;
-	req.baud_base       =3D IOC3_BAUD;
-
-	req.iomem_base      =3D (unsigned char *) &ioc3->sregs.uarta;
-	register_serial(&req);
-
-	req.iomem_base      =3D (unsigned char *) &ioc3->sregs.uartb;
-	register_serial(&req);
+	return 0;
 }
=20
 static int __devinit ioc3_probe(struct pci_dev *pdev,
-	                        const struct pci_device_id *ent)
+                                const struct pci_device_id *ent)
 {
 	struct net_device *dev =3D NULL;
 	struct ioc3_private *ip;
@@ -1412,6 +1300,7 @@
 	u32 vendor, model, rev;
 	int err;
=20
+#if LINUX_VERSION_CODE >=3D 0x99999
 	dev =3D alloc_etherdev(sizeof(struct ioc3_private));
 	if (!dev)
 		return -ENOMEM;
@@ -1419,15 +1308,56 @@
 	err =3D pci_request_regions(pdev, "ioc3");
 	if (err)
 		goto out_free;
-
+#else
+	dev =3D init_etherdev(0, sizeof(struct ioc3_private));
+	if (!dev)
+		return -ENOMEM;
+#endif
 	SET_MODULE_OWNER(dev);
 	ip =3D dev->priv;
+
+	memset(ip, 0, sizeof(*ip));
 	ip->dev =3D dev;
+	ip->pdev =3D pdev;
+
+{
+	void *tempvirtaddr =3D NULL;
+	dma_addr_t tempdmaaddr =3D (dma_addr_t) NULL;
+
+	/*
+	 * IOC3 ethernet driver has been coded to do DMA in Big=20
+	 * Endian.  The current DMA interfaces for SN1 assumes that=20
+	 * all DMA are targeted to Little Endian(Swap attribute on).
+	 *
+	 * The other problem is that we need to make sure that the=20
+	 * IOC3 Ethernet driver is functional irrespective of whether=20
+	 * the IO device is connected via Port A or Port B.
+	 *
+	 * I am reluctant to do the "RIGHT" thing here for now because=20
+	 * it would mean a much greater effort in a driver that I do not=20
+	 * have much knowlwdge - Colin Ngam.
+	 */
+	tempvirtaddr =3D pci_alloc_consistent(pdev, 1, &tempdmaaddr);
+	if (!tempvirtaddr) {
+		printk("ioc3_pci_init: Failed to get DMA address attributes\n");
+		return(-1);
+	} else {
+		ip->dma_attributes =3D 0xff00000000000000 & (unsigned long) tempdmaaddr;
+		pci_free_consistent(pdev, 1, tempvirtaddr, tempdmaaddr);
+	}
+}
+
+	/*
+	 * This probably needs to be register_netdevice, or call
+	 * init_etherdev so that it calls register_netdevice. Quick
+	 * hack for now.
+	 */
+	netif_device_attach(dev);
=20
 	dev->irq =3D pdev->irq;
=20
-	ioc3_base =3D pci_resource_start(pdev, 0);
-	ioc3_size =3D pci_resource_len(pdev, 0);
+	ioc3_base =3D pdev->resource[0].start;
+	ioc3_size =3D pdev->resource[0].end - ioc3_base;
 	ioc3 =3D (struct ioc3 *) ioremap(ioc3_base, ioc3_size);
 	if (!ioc3) {
 		printk(KERN_CRIT "ioc3eth(%s): ioremap failed, goodbye.\n",
@@ -1435,15 +1365,14 @@
 		err =3D -ENOMEM;
 		goto out_res;
 	}
-	ip->regs =3D ioc3;
=20
-#ifdef CONFIG_SERIAL
-	ioc3_serial_probe(pdev, ioc3);
-#endif
+	ip->regs =3D ioc3;
=20
 	spin_lock_init(&ip->ioc3_lock);
=20
 	ioc3_stop(ip);
+	ip->emcr =3D 0;
+	ioc3_phyreset(dev);
 	ioc3_init(ip);
=20
 	init_timer(&ip->ioc3_timer);
@@ -1451,7 +1380,7 @@
=20
 	if (ip->phy =3D -1) {
 		printk(KERN_CRIT "ioc3-eth(%s): Didn't find a PHY, goodbye.\n",
-		       pdev->slot_name);
+		       dev->name);
 		err =3D -ENODEV;
 		goto out_stop;
 	}
@@ -1469,9 +1398,11 @@
 	dev->do_ioctl		=3D ioc3_ioctl;
 	dev->set_multicast_list	=3D ioc3_set_multicast_list;
=20
+#if LINUX_VERSION_CODE >=3D 0x99999
 	err =3D register_netdev(dev);
 	if (err)
 		goto out_stop;
+#endif
=20
 	vendor =3D (ip->sw_physid1 << 12) | (ip->sw_physid2 >> 4);
 	model  =3D (ip->sw_physid2 >> 4) & 0x3f;
@@ -1488,8 +1419,10 @@
 	free_irq(dev->irq, dev);
 	ioc3_free_rings(ip);
 out_res:
+#if LINUX_VERSION_CODE >=3D 0x99999
 	pci_release_regions(pdev);
 out_free:
+#endif
 	kfree(dev);
 	return err;
 }
@@ -1501,7 +1434,9 @@
 	struct ioc3 *ioc3 =3D ip->regs;
=20
 	iounmap(ioc3);
+#if LINUX_VERSION_CODE >=3D 0x99999
 	pci_release_regions(pdev);
+#endif
 	kfree(dev);
 }
=20
@@ -1512,10 +1447,10 @@
 MODULE_DEVICE_TABLE(pci, ioc3_pci_tbl);
=20
 static struct pci_driver ioc3_driver =3D {
-	name:		"ioc3-eth",
-	id_table:	ioc3_pci_tbl,
-	probe:		ioc3_probe,
-	remove:		ioc3_remove_one,
+    name:	"ioc3-eth",
+    id_table:	ioc3_pci_tbl,
+    probe:	ioc3_probe,
+    remove:	ioc3_remove_one,
 };
=20
 static int __init ioc3_init_module(void)
@@ -1554,8 +1489,8 @@
 			memset(desc->data + len, 0, ETH_ZLEN - len);
 			len =3D ETH_ZLEN;
 		}
-		desc->cmd    =3D len | ETXD_INTWHENDONE | ETXD_D0V;
-		desc->bufcnt =3D len;
+		desc->cmd    =3D htonl(len | ETXD_INTWHENDONE | ETXD_D0V);
+		desc->bufcnt =3D htonl(len);
 	} else if ((data ^ (data + len)) & 0x4000) {
 		unsigned long b2, s1, s2;
=20
@@ -1563,16 +1498,19 @@
 		s1 =3D b2 - data;
 		s2 =3D data + len - b2;
=20
-		desc->cmd    =3D len | ETXD_INTWHENDONE | ETXD_B1V | ETXD_B2V;
-		desc->bufcnt =3D (s1 << ETXD_B1CNT_SHIFT) |
-		               (s2 << ETXD_B2CNT_SHIFT);
-		desc->p1     =3D (0xa5UL << 56) | (data & TO_PHYS_MASK);
-		desc->p2     =3D (0xa5UL << 56) | (data & TO_PHYS_MASK);
+		desc->cmd    =3D htonl(len | ETXD_INTWHENDONE | ETXD_B1V | ETXD_B2V);
+		desc->bufcnt =3D htonl((s1 << ETXD_B1CNT_SHIFT) |
+		               (s2 << ETXD_B2CNT_SHIFT));
+		desc->p1     =3D (ip->dma_attributes) | (data & TO_PHYS_MASK);
+		desc->p2     =3D (ip->dma_attributes) | (data & TO_PHYS_MASK);
+		desc->p1 =3D cpu_to_be64(desc->p1);
+		desc->p2 =3D cpu_to_be64(desc->p2);
 	} else {
 		/* Normal sized packet that doesn't cross a page boundary. */
-		desc->cmd    =3D len | ETXD_INTWHENDONE | ETXD_B1V;
-		desc->bufcnt =3D len << ETXD_B1CNT_SHIFT;
-		desc->p1     =3D (0xa5UL << 56) | (data & TO_PHYS_MASK);
+		desc->cmd    =3D htonl(len | ETXD_INTWHENDONE | ETXD_B1V);
+		desc->bufcnt =3D htonl(len << ETXD_B1CNT_SHIFT);
+		desc->p1     =3D (ip->dma_attributes) | (data & TO_PHYS_MASK);
+		desc->p1 =3D cpu_to_be64(desc->p1);
 	}
=20
 	BARRIER();
@@ -1647,7 +1585,7 @@
 /* We provide both the mii-tools and the ethtool ioctls.  */
 static int ioc3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct ioc3_private *ip =3D dev->priv;
+	struct ioc3_private *ip =3D (struct ioc3_private *) dev->priv;
 	struct ethtool_cmd *ep_user =3D (struct ethtool_cmd *) rq->ifr_data;
 	u16 *data =3D (u16 *)&rq->ifr_data;
 	struct ioc3 *ioc3 =3D ip->regs;
diff -Naur 2.4.16-ia64/linux/include/asm-ia64/acpi-ext.h 16i.sn/linux/inclu=
de/asm-ia64/acpi-ext.h
--- 2.4.16-ia64/linux/include/asm-ia64/acpi-ext.h	Sun Dec  2 22:22:09 2001
+++ 16i.sn/linux/include/asm-ia64/acpi-ext.h	Sun Dec  2 22:42:22 2001
@@ -297,7 +297,7 @@
=20
 extern int pxm_to_nid_map[MAX_PXM_DOMAINS]; /* _PXM to logical node ID map=
 */
 extern int nid_to_pxm_map[PLAT_MAX_COMPACT_NODES]; /* logical node ID to _=
PXM map */
-extern int numnodes;			/* total number of nodes in system */
+extern int numnodes;		/* total number of nodes in system */
 extern int num_memory_chunks;		/* total number of memory chunks */
=20
 /*
diff -Naur 2.4.16-ia64/linux/include/asm-ia64/sn/mmzone_temp.h 16i.sn/linux=
/include/asm-ia64/sn/mmzone_temp.h
--- 2.4.16-ia64/linux/include/asm-ia64/sn/mmzone_temp.h	Sun Dec  2 22:22:09=
 2001
+++ 16i.sn/linux/include/asm-ia64/sn/mmzone_temp.h	Sun Dec  2 22:42:07 2001
@@ -22,6 +22,10 @@
 #error "Unknown architecture"
 #endif
=20
+/*
+ * Temporary hack
+ */
+#define num_compact_nodes	numnodes
=20
 /*
  * General Concepts:
diff -Naur /dev/null 16i.sn/linux/drivers/char/sgi-l1_protocol.c
--- /dev/null	Sat Mar 24 04:37:44 2001
+++ 16i.sn/linux/drivers/char/sgi-l1_protocol.c	Sun Dec  2 22:58:29 2001
@@ -0,0 +1,2581 @@
+/*
+ * $Id$
+ *
+ * This file is subject to the terms and conditions of the GNU General Pub=
lic
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2000 - 2001 Silicon Graphics, Inc. All rights reserved.
+ *
+ * This driver was originally based off the drivers/char/serial.c driver.
+ *
+ *  Copyright (C) 1991, 1992  Linus Torvalds
+ *  Copyright (C) 1992, 1993, 1994, 1995, 1996, 1997,=20
+ * 		1998, 1999  Theodore Ts'o
+ */
+
+/*
+ * Serial driver configuration section.  Here are the various options:
+ *
+ * SERIAL_PARANOIA_CHECK
+ * 		Check the magic number for the async_structure where
+ * 		ever possible.
+ */
+
+#include <linux/config.h>
+#include <linux/version.h>
+
+#undef SERIAL_PARANOIA_CHECK
+#define CONFIG_SERIAL_NOPAUSE_IO
+#define SERIAL_DO_RESTART
+
+/* Set of debugging defines */
+
+#undef SERIAL_DEBUG_INTR
+#undef SERIAL_DEBUG_OPEN
+#undef SERIAL_DEBUG_FLOW
+#undef SERIAL_DEBUG_RS_WAIT_UNTIL_SENT
+#undef SERIAL_DEBUG_PCI
+#undef SERIAL_DEBUG_AUTOCONF
+
+/* Sanity checks */
+
+#define RS_STROBE_TIME (10*HZ)
+#define RS_ISR_PASS_LIMIT 256
+
+/*
+ * End of serial driver configuration section.
+ */
+
+#ifdef MODVERSIONS
+#include <linux/modversions.h>
+#endif
+#include <linux/module.h>
+
+#include <linux/types.h>
+#ifdef LOCAL_HEADERS
+#include "serial_local.h"
+#else
+#include <linux/serial.h>
+#include <linux/serialP.h>
+#include <linux/serial_reg.h>
+#include <asm/sn/uart16550.h>
+#include <asm/serial.h>
+#define LOCAL_VERSTRING ""
+#endif
+
+#include <linux/errno.h>
+#include <linux/signal.h>
+#include <linux/sched.h>
+#include <linux/timer.h>
+#include <linux/interrupt.h>
+#include <linux/tty.h>
+#include <linux/tty_flip.h>
+#include <linux/major.h>
+#include <linux/string.h>
+#include <linux/fcntl.h>
+#include <linux/ptrace.h>
+#include <linux/ioport.h>
+#include <linux/mm.h>
+#include <linux/malloc.h>
+#if (LINUX_VERSION_CODE >=3D 131343)
+#include <linux/init.h>
+#endif
+#if (LINUX_VERSION_CODE >=3D 131336)
+#include <asm/uaccess.h>
+#endif
+#include <linux/delay.h>
+#include <linux/console.h>
+#ifdef CONFIG_MAGIC_SYSRQ
+#include <linux/sysrq.h>
+#endif
+
+static char *serial_name =3D "SGI L1 Protocol Serial driver";
+static char *serial_version =3D "2.0";
+static char *serial_revdate =3D "2001-04-19";
+
+#define USING_L1_FUNCS	1
+
+static DECLARE_TASK_QUEUE(tq_serial);
+
+
+/* We need to know when it IS data and when it is not */
+#define L1_REG_DAT_BIT		(0x800)
+#define L1_REG_DAT		(REG_DAT | L1_REG_DAT_BIT)
+
+#if defined(CONFIG_KDB)
+#include <linux/kdb.h>
+/*
+ * kdb_serial_line records the serial line number of the
+ * first serial console.  kdb_info will be set upon receipt
+ * of the first ^A (which cannot happen until the port is
+ * opened and the interrupt handler attached).  To enter
+ * kdb before this on a serial console-only system, you must
+ * use the 'kdb=EArly' flag to lilo and set the appropriate
+ * breakpoints.
+ */
+
+static int  kdb_serial_line =3D -1;
+#endif	/* CONFIG_KDB */
+/*
+ * All of the compatibilty code so we can compile serial.c against
+ * older kernels is hidden in serial_compat.h
+ */
+#if defined(LOCAL_HEADERS) || (LINUX_VERSION_CODE < 0x020317) /* 2.3.23 */
+#include "serial_compat.h"
+#endif
+
+#include <asm/system.h>
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/bitops.h>
+#include <asm/sn/simulator.h>
+
+#ifdef CONFIG_MAC_SERIAL
+#define SERIAL_DEV_OFFSET	2
+#else
+#define SERIAL_DEV_OFFSET	0
+#endif
+
+#ifdef SERIAL_INLINE
+#define _INLINE_ inline
+#else
+#define _INLINE_
+#endif
+
+#undef RS_TABLE_SIZE
+#define RS_TABLE_SIZE 64
+
+static struct tty_driver l1_serial_driver, l1_callout_driver;
+static int l1_cons_serial_refcount;
+
+extern int l1_get_intr_value(void);
+
+static struct timer_list serial_timer;
+
+/* serial subtype definitions */
+#ifndef SERIAL_TYPE_NORMAL
+#define SERIAL_TYPE_NORMAL	1
+#define SERIAL_TYPE_CALLOUT	2
+#endif
+
+/* number of characters left in xmit buffer before we ask for more */
+#define WAKEUP_CHARS 256
+
+/*
+ * IRQ_timeout		- How long the timeout should be for each IRQ
+ * 				should be after the IRQ has been active.
+ */
+
+static struct async_struct *IRQ_ports[NR_IRQS];
+static int IRQ_timeout[NR_IRQS];
+static struct console sgiconsole;
+static int lsr_break_flag =3D 0;
+#if defined(CONFIG_MAGIC_SYSRQ) && !defined(MODULE)
+static unsigned long break_pressed; /* break, really ... */
+#endif
+
+static void autoconfig(struct serial_state * state);
+static void change_speed(struct async_struct *info, struct termios *old);
+static void l1_cons_wait_until_sent(struct tty_struct *tty, int timeout);
+
+/*
+ * Here we define the default xmit fifo size used for each type of
+ * UART
+ */
+static struct serial_uart_config uart_config[] =3D {
+	{ "unknown", 1, 0 },=20
+	{ "8250", 1, 0 },=20
+	{ "16450", 1, 0 },=20
+	{ "16550", 1, 0 },=20
+	{ "16550A", 100, 0 },
+	{ 0, 0}
+};
+
+static struct serial_state l1_table[RS_TABLE_SIZE] =3D {
+	SERIAL_PORT_DFNS	/* Defined in serial.h */
+};
+
+#define NR_PORTS	(sizeof(l1_table)/sizeof(struct serial_state))
+
+#define HIGH_BITS_OFFSET ((sizeof(long)-sizeof(int))*8)
+
+static struct tty_struct *l1_cons_serial_table[NR_PORTS];
+static struct termios *l1_cons_serial_termios[NR_PORTS];
+static struct termios *l1_cons_serial_termios_locked[NR_PORTS];
+
+
+#if defined(MODULE) && defined(SERIAL_DEBUG_MCOUNT)
+#define DBG_CNT(s) printk("(%s): [%x] refc=3D%d, serc=3D%d, ttyc=3D%d -> %=
s\n", \
+ kdevname(tty->device), (info->flags), l1_cons_serial_refcount,info->count=
,tty->count,s)
+#else
+#define DBG_CNT(s)
+#endif
+
+/*
+ * l1_tmp_buffer is used as a temporary buffer by serial_write.  We need to
+ * lock it in case the copy_from_user blocks while swapping in a page,
+ * and some other program tries to do a serial write at the same time.
+ * Since the lock will only come under contention when the system is
+ * swapping and available memory is low, it makes sense to share one
+ * buffer across all the serial ports, since it significantly saves
+ * memory if large numbers of serial ports are open.
+ */
+static unsigned char *l1_tmp_buffer;
+#ifdef DECLARE_MUTEX
+static DECLARE_MUTEX(l1_tmp_buffer_sem);
+#else
+static struct semaphore l1_tmp_buffer_sem =3D MUTEX;
+#endif
+
+
+static inline int
+serial_paranoia_check(struct async_struct *info, kdev_t device, const char=
 *routine)
+{
+#ifdef SERIAL_PARANOIA_CHECK
+	static const char *badmagic =3D "Warning: bad magic number for serial str=
uct (%s) in %s\n";
+	static const char *badinfo  =3D "Warning: null async_struct for (%s) in %=
s\n";
+
+	if (!info) {
+		printk(badinfo, kdevname(device), routine);
+		return 1;
+	}
+	if (info->magic !=3D SERIAL_MAGIC) {
+		printk(badmagic, kdevname(device), routine);
+		return 1;
+	}
+#endif
+	return 0;
+}
+
+static _INLINE_ unsigned int
+serial_in(struct async_struct *info, int p_offset)
+{
+	int offset =3D p_offset & (L1_REG_DAT_BIT - 1);
+
+	switch (info->io_type) {
+	case SERIAL_IO_MEM:
+		if ( IS_RUNNING_ON_SIMULATOR() ) {
+			return readb((unsigned long) info->iomem_base +
+				(offset<<info->iomem_reg_shift));
+		}
+		else {
+			if ( p_offset =3D L1_REG_DAT ) {
+				/* Text */
+				unsigned int value =3D 0;
+				extern int l1_serial_in(void);
+				value =3D (unsigned int)l1_serial_in();
+				return(value);
+			}
+			else {
+				int l1_control_in(int);
+				return(l1_control_in(offset));
+			}
+		}
+	default:
+		return inb(info->port + offset);
+	}
+}
+
+static _INLINE_ void
+serial_out(struct async_struct *info, int p_offset, int value)
+{
+	int offset =3D p_offset & (L1_REG_DAT_BIT - 1);
+
+	switch (info->io_type) {
+	case SERIAL_IO_MEM:
+		if ( IS_RUNNING_ON_SIMULATOR() ) {
+			writeb(value, (unsigned long) info->iomem_base +
+				(offset<<info->iomem_reg_shift));
+		}
+		else {
+			if ( p_offset =3D L1_REG_DAT ) {
+				/* Text */
+				extern int l1_serial_out(char *, int);
+				char ch =3D (char)value;
+				(void)l1_serial_out(&ch, 1);
+			}
+			else {
+				void l1_control_out(int offset, int value);
+				l1_control_out(offset, value);
+			}
+		}
+		break;
+	default:
+		outb(value, info->port+offset);
+	}
+}
+
+static void
+l1_cons_start(struct tty_struct *tty)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+
+	if (serial_paranoia_check(info, tty->device, "l1_cons_start"))
+		return;
+}
+
+/*
+ * ----------------------------------------------------------------------
+ *
+ * Here starts the interrupt handling routines.  All of the following
+ * subroutines are declared as inline and are folded into
+ * rs_interrupt().  They were separated out for readability's sake.
+ *
+ * Note: rs_interrupt() is a "fast" interrupt, which means that it
+ * runs with interrupts turned off.  People who may want to modify
+ * rs_interrupt() should try to keep the interrupt handler as fast as
+ * possible.  After you are done making modifications, it is not a bad
+ * idea to do:
+ *=20
+ * gcc -S -DKERNEL -Wall -Wstrict-prototypes -O6 -fomit-frame-pointer seri=
al.c
+ *
+ * and look at the resulting assemble code in serial.s.
+ *
+ * 				- Ted Ts'o (tytso@mit.edu), 7-Mar-93
+ * -----------------------------------------------------------------------
+ */
+
+/*
+ * This routine is used by the interrupt handler to schedule
+ * processing in the software interrupt portion of the driver.
+ */
+static _INLINE_ void
+l1_cons_sched_event(struct async_struct *info, int event)
+{
+	info->event |=3D 1 << event;
+	queue_task(&info->tqueue, &tq_serial);
+	mark_bh(SERIAL_BH);
+}
+
+static _INLINE_ void
+receive_chars(struct async_struct *info, int *status, struct pt_regs * reg=
s)
+{
+	struct tty_struct *tty =3D info->tty;
+	unsigned char ch;
+	int ignored =3D 0;
+	struct	async_icount *icount;
+
+	icount =3D &info->state->icount;
+	do {
+		ch =3D (unsigned char)serial_in(info, L1_REG_DAT);
+#if defined(CONFIG_KDB)
+		if ((info->line =3D kdb_serial_line)
+		 && (ch =3D 1)  	/* CNTRL-A */
+		 && kdb_on) {
+			kdb(KDB_REASON_KEYBOARD, 0, (kdb_eframe_t)regs);
+			break;
+		}
+#endif	/* CONFIG_KDB */
+		if (tty->flip.count >=3D TTY_FLIPBUF_SIZE)
+			goto ignore_char;
+		*tty->flip.char_buf_ptr =3D ch;
+		icount->rx++;
+	=09
+		*tty->flip.flag_buf_ptr =3D 0;
+		if (*status & (LSR_BRKDET | LSR_PARERR | LSR_FRMERR | LSR_OVRRUN)) {
+			/*
+			 * For statistics only
+			 */
+			if (*status & LSR_BRKDET) {
+				*status &=3D ~(LSR_FRMERR | LSR_PARERR);
+				icount->brk++;
+#if defined(CONFIG_MAGIC_SYSRQ) && !defined(MODULE)
+				if (info->line =3D sgiconsole.index) {
+					if (!break_pressed) {
+						break_pressed =3D jiffies;
+						goto ignore_char;
+					}
+					break_pressed =3D 0;
+				}
+#endif
+				if (info->flags & ASYNC_SAK)
+					do_SAK(tty);
+			} else if (*status & LSR_PARERR)
+				icount->parity++;
+			else if (*status & LSR_FRMERR)
+				icount->frame++;
+			if (*status & LSR_OVRRUN)
+				icount->overrun++;
+
+			/*
+			 * Now check to see if character should be
+			 * ignored, and mask off conditions which
+			 * should be ignored.
+			 */
+			if (*status & info->ignore_status_mask) {
+				if (++ignored > 100)
+					break;
+				goto ignore_char;
+			}
+			*status &=3D info->read_status_mask;
+	=09
+			if (info->line =3D sgiconsole.index) {
+				/* Recover the break flag from console xmit */
+				*status |=3D lsr_break_flag;
+				lsr_break_flag =3D 0;
+			}
+
+			if (*status & (LSR_BRKDET)) {
+				*tty->flip.flag_buf_ptr =3D TTY_BREAK;
+			} else if (*status & LSR_PARERR)
+				*tty->flip.flag_buf_ptr =3D TTY_PARITY;
+			else if (*status & LSR_FRMERR)
+				*tty->flip.flag_buf_ptr =3D TTY_FRAME;
+
+			if (*status & LSR_OVRRUN) {
+				/*
+				 * Overrun is special, since it's
+				 * reported immediately, and doesn't
+				 * affect the current character
+				 */
+				tty->flip.count++;
+				tty->flip.flag_buf_ptr++;
+				tty->flip.char_buf_ptr++;
+				*tty->flip.flag_buf_ptr =3D TTY_OVERRUN;
+				if (tty->flip.count >=3D TTY_FLIPBUF_SIZE)
+					goto ignore_char;
+			}
+		}
+#if defined(CONFIG_MAGIC_SYSRQ) && !defined(MODULE)
+		if (break_pressed && info->line =3D sgiconsole.index) {
+			if (ch !=3D 0 &&
+			    time_before(jiffies, break_pressed + HZ*5)) {
+				handle_sysrq(ch, regs, NULL, NULL);
+				break_pressed =3D 0;
+				goto ignore_char;
+			}
+			break_pressed =3D 0;
+		}
+#endif
+		tty->flip.flag_buf_ptr++;
+		tty->flip.char_buf_ptr++;
+		tty->flip.count++;
+	ignore_char:
+		*status =3D serial_in(info, REG_LSR);
+	} while (*status & LSR_RCA);
+#if (LINUX_VERSION_CODE > 131394) /* 2.1.66 */
+	tty_flip_buffer_push(tty);
+#else
+	queue_task(&tty->flip.tqueue, &tq_timer);
+#endif=09
+}
+
+static _INLINE_ void
+transmit_chars(struct async_struct *info, int *intr_done)
+{
+	int xmit_count;
+	char *start;
+	extern int l1_serial_out(char *, int);
+
+	if (info->xmit.head =3D info->xmit.tail || info->tty->stopped || info->tt=
y->hw_stopped) {
+		/* Nothing to do */
+		return;
+	}
+	start =3D (char *)&info->xmit.buf[info->xmit.tail];
+	xmit_count =3D 0;
+	while ( 1 ) {
+		if ( IS_RUNNING_ON_SIMULATOR() ) {
+			serial_out(info, L1_REG_DAT, info->xmit.buf[info->xmit.tail]);
+			info->xmit.tail =3D (info->xmit.tail + 1) & (SERIAL_XMIT_SIZE-1);
+		}
+		else {
+			xmit_count++;
+			if ( (++info->xmit.tail) & ~(SERIAL_XMIT_SIZE - 1) ) {
+				/* end of the buffer - flush and reset */
+				(void)l1_serial_out(start, xmit_count);
+				info->xmit.tail =3D 0;
+				start =3D (char *)&info->xmit.buf[info->xmit.tail];
+				xmit_count =3D 0;
+			}
+		}
+		info->state->icount.tx++;
+		if (info->xmit.head =3D info->xmit.tail)
+			break;
+	}
+	if ( !IS_RUNNING_ON_SIMULATOR() && xmit_count ) {
+		(void)l1_serial_out(start, xmit_count);
+	}
+=09
+	if (CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE) < WAKEUP=
_CHARS)
+		l1_cons_sched_event(info, RS_EVENT_WRITE_WAKEUP);
+
+	if (intr_done)
+		*intr_done =3D 0;
+}
+
+/*
+ * This is the serial driver's interrupt routine
+ */
+
+static void
+l1_cons_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+{
+	int status;
+	struct async_struct * info;
+=09
+	info =3D IRQ_ports[irq];
+	if (!info || !info->tty)
+		return;
+
+	status =3D serial_in(info, REG_LSR);
+	if (status & LSR_RCA)
+		receive_chars(info, &status, regs);
+	if (status & LSR_XHRE)
+		transmit_chars(info, 0);
+
+	info->last_active =3D jiffies;
+}
+
+
+/*
+ * -------------------------------------------------------------------
+ * Here ends the serial interrupt routines.
+ * -------------------------------------------------------------------
+ */
+
+/*
+ * This routine is used to handle the "bottom half" processing for the
+ * serial driver, known also the "software interrupt" processing.
+ * This processing is done at the kernel interrupt level, after the
+ * rs_interrupt() has returned, BUT WITH INTERRUPTS TURNED ON.  This
+ * is where time-consuming activities which can not be done in the
+ * interrupt driver proper are done; the interrupt driver schedules
+ * them using l1_cons_sched_event(), and they get done here.
+ */
+static void
+do_serial_bh(void)
+{
+	run_task_queue(&tq_serial);
+}
+
+static void
+do_softint(void *private_)
+{
+	struct async_struct	*info =3D (struct async_struct *) private_;
+	struct tty_struct	*tty;
+=09
+	tty =3D info->tty;
+	if (!tty)
+		return;
+
+	if (test_and_clear_bit(RS_EVENT_WRITE_WAKEUP, &info->event)) {
+		if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
+		    tty->ldisc.write_wakeup)
+			(tty->ldisc.write_wakeup)(tty);
+		wake_up_interruptible(&tty->write_wait);
+#ifdef SERIAL_HAVE_POLL_WAIT
+		wake_up_interruptible(&tty->poll_wait);
+#endif
+	}
+}
+
+/*
+ * This subroutine is called when the RS_TIMER goes off.  It is used
+ * by the serial driver to handle ports that do not have an interrupt
+ * (irq=3D0).  This doesn't work very well for 16450's, but gives barely
+ * passable results for a 16550A.  (Although at the expense of much
+ * CPU overhead).
+ */
+static void
+l1_cons_timer(unsigned long dummy)
+{
+	/* Special case for irq =3D 0. That is the same as polled mode */
+	if (IRQ_ports[0]) {
+		l1_cons_interrupt(0, NULL, NULL);
+
+		mod_timer(&serial_timer, jiffies + IRQ_timeout[0]);
+	}
+}
+
+/*
+ * ---------------------------------------------------------------
+ * Low level utility subroutines for the serial driver:  routines to
+ * figure out the appropriate timeout for an interrupt chain, routines
+ * to initialize and startup a serial port, and routines to shutdown a
+ * serial port.  Useful stuff like that.
+ * ---------------------------------------------------------------
+ */
+
+/*
+ * This routine figures out the correct timeout for a particular IRQ.
+ * It uses the smallest timeout of all of the serial ports in a
+ * particular interrupt chain.  Now only used for IRQ 0....
+ */
+static void
+figure_IRQ_timeout(int irq)
+{
+	struct	async_struct	*info;
+	int	timeout =3D 60*HZ;	/* 60 seconds =3D=3D a long time :-) */
+
+	info =3D IRQ_ports[irq];
+	if (!info) {
+		IRQ_timeout[irq] =3D 60*HZ;
+		return;
+	}
+	while (info) {
+		if (info->timeout < timeout)
+			timeout =3D info->timeout;
+		info =3D info->next_port;
+	}
+	if (!irq)
+		timeout =3D timeout / 2;
+	IRQ_timeout[irq] =3D timeout ? timeout : 1;
+}
+
+//#define CONSOLE_POLLING_ALSO
+
+#ifdef CONSOLE_POLLING_ALSO
+static void
+l1_cons_null(int irq, void *dev_id, struct pt_regs *regs)
+{
+	/* as the name implies */
+}
+#endif
+
+static int
+startup(struct async_struct * info)
+{
+	unsigned long flags;
+	int	retval=3D0;
+	struct serial_state *state=3D info->state;
+	unsigned long page;
+	void l1_connect_intr(void *, void *);
+
+	page =3D get_zeroed_page(GFP_KERNEL);
+	if (!page)
+		return -ENOMEM;
+
+	save_flags(flags); cli();
+
+	if (info->flags & ASYNC_INITIALIZED) {
+		free_page(page);
+		goto errout;
+	}
+
+	if (!CONFIGURED_SERIAL_PORT(state) || !state->type) {
+		if (info->tty)
+			set_bit(TTY_IO_ERROR, &info->tty->flags);
+		free_page(page);
+		goto errout;
+	}
+	if (info->xmit.buf)
+		free_page(page);
+	else
+		info->xmit.buf =3D (unsigned char *) page;
+
+#ifdef SERIAL_DEBUG_OPEN
+	printk("starting up ttys%d (irq %d)...", info->line, state->irq);
+#endif
+
+	if (state->irq && (IRQ_ports[state->irq])) {
+		/* IRQ in use */
+		retval =3D -EBUSY;
+		goto errout;
+	}
+
+	/*
+	 * Insert serial port into IRQ chain.
+	 */
+	info->prev_port =3D 0;
+	info->next_port =3D IRQ_ports[state->irq];
+	if (info->next_port)
+		info->next_port->prev_port =3D info;
+	IRQ_ports[state->irq] =3D info;
+
+	if (info->tty)
+		clear_bit(TTY_IO_ERROR, &info->tty->flags);
+	info->xmit.head =3D info->xmit.tail =3D 0;
+
+	/*
+	 * Set up serial timers...
+	 */
+	mod_timer(&serial_timer, jiffies + 2*HZ/100);
+
+	/*
+	 * Set up the tty->alt_speed kludge
+	 */
+#if (LINUX_VERSION_CODE >=3D 131394) /* Linux 2.1.66 */
+	if (info->tty) {
+		if ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_HI)
+			info->tty->alt_speed =3D 57600;
+		if ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_VHI)
+			info->tty->alt_speed =3D 115200;
+		if ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_SHI)
+			info->tty->alt_speed =3D 230400;
+		if ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_WARP)
+			info->tty->alt_speed =3D 460800;
+	}
+#endif
+=09
+	/*
+	 * and set the speed of the serial port
+	 */
+	change_speed(info, 0);
+
+	/*
+	 * Call the lower-level callback function for incoming packets and
+	 * register for the interrupt.
+	 */
+	figure_IRQ_timeout(state->irq);
+
+	if ( state->irq ) {
+		if ( !(IS_RUNNING_ON_SIMULATOR()) )
+			l1_connect_intr((void *)l1_cons_interrupt, (void *)l1_cons_interrupt);
+	}
+#ifdef CONSOLE_POLLING_ALSO
+	if ( !(IS_RUNNING_ON_SIMULATOR()) )
+		l1_connect_intr((void *)l1_cons_null, (void *)l1_cons_null);
+#endif
+	info->flags |=3D ASYNC_INITIALIZED;
+	restore_flags(flags);
+	return 0;
+=09
+errout:
+	restore_flags(flags);
+	return retval;
+}
+
+/*
+ * This routine will shutdown a serial port; interrupts are disabled, and
+ * DTR is dropped if the hangup on close termio flag is on.
+ */
+static void
+shutdown(struct async_struct * info)
+{
+	unsigned long	flags;
+	struct serial_state *state;
+	void l1_unconnect_intr(void);
+
+
+	if (!(info->flags & ASYNC_INITIALIZED))
+		return;
+
+	state =3D info->state;
+
+#ifdef SERIAL_DEBUG_OPEN
+	printk("Shutting down serial port %d (irq %d)....", info->line,
+	       state->irq);
+#endif
+=09
+	save_flags(flags); cli(); /* Disable interrupts */
+
+	/*
+	 * clear delta_msr_wait queue to avoid mem leaks: we may free the irq
+	 * here so the queue might never be waken up
+	 */
+	wake_up_interruptible(&info->delta_msr_wait);
+=09
+	/*
+	 * First unlink the serial port from the IRQ chain...
+	 */
+	if (info->next_port)
+		info->next_port->prev_port =3D info->prev_port;
+	if (info->prev_port)
+		info->prev_port->next_port =3D info->next_port;
+	else
+		IRQ_ports[state->irq] =3D info->next_port;
+	figure_IRQ_timeout(state->irq);
+
+	if (info->xmit.buf) {
+		unsigned long pg =3D (unsigned long) info->xmit.buf;
+		info->xmit.buf =3D 0;
+		free_page(pg);
+	}
+
+	if (info->tty)
+		set_bit(TTY_IO_ERROR, &info->tty->flags);
+
+	if ( !(IS_RUNNING_ON_SIMULATOR()) )
+		l1_unconnect_intr();
+	info->flags &=3D ~ASYNC_INITIALIZED;
+	restore_flags(flags);
+}
+
+#if (LINUX_VERSION_CODE < 131394) /* Linux 2.1.66 */
+static int baud_table[] =3D {
+	0, 50, 75, 110, 134, 150, 200, 300,
+	600, 1200, 1800, 2400, 4800, 9600, 19200,
+	38400, 57600, 115200, 230400, 460800, 0 };
+
+static int
+tty_get_baud_rate(struct tty_struct *tty)
+{
+	struct async_struct * info =3D (struct async_struct *)tty->driver_data;
+	unsigned int cflag, i;
+
+	cflag =3D tty->termios->c_cflag;
+
+	i =3D cflag & CBAUD;
+	if (i & CBAUDEX) {
+		i &=3D ~CBAUDEX;
+		if (i < 1 || i > 2)=20
+			tty->termios->c_cflag &=3D ~CBAUDEX;
+		else
+			i +=3D 15;
+	}
+	if (i =3D 15) {
+		if ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_HI)
+			i +=3D 1;
+		if ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_VHI)
+			i +=3D 2;
+	}
+	return baud_table[i];
+}
+#endif
+
+/*
+ * This routine is called to set the UART divisor registers to match
+ * the specified baud rate for a serial port.
+ */
+static void
+change_speed(struct async_struct *info,
+			 struct termios *old_termios)
+{
+	int	quot =3D 0, baud_base, baud;
+	unsigned cflag, cval;
+	int	bits;
+	unsigned long	flags;
+
+	if (!info->tty || !info->tty->termios)
+		return;
+	cflag =3D info->tty->termios->c_cflag;
+	if (!CONFIGURED_SERIAL_PORT(info))
+		return;
+
+	/* byte size and parity */
+	switch (cflag & CSIZE) {
+	      case CS5: cval =3D 0x00; bits =3D 7; break;
+	      case CS6: cval =3D 0x01; bits =3D 8; break;
+	      case CS7: cval =3D 0x02; bits =3D 9; break;
+	      case CS8: cval =3D 0x03; bits =3D 10; break;
+	      /* Never happens, but GCC is too dumb to figure it out */
+	      default:  cval =3D 0x00; bits =3D 7; break;
+	      }
+	if (cflag & CSTOPB) {
+		cval |=3D 0x04;
+		bits++;
+	}
+	if (cflag & PARENB) {
+		cval |=3D LCR_PAREN;
+		bits++;
+	}
+	if (!(cflag & PARODD))
+		cval |=3D LCR_PAREVN;
+#ifdef CMSPAR
+	if (cflag & CMSPAR)
+		cval |=3D LCR_PARMARK;
+#endif
+
+	/* Determine divisor based on baud rate */
+	baud =3D tty_get_baud_rate(info->tty);
+	if (!baud)
+		baud =3D 9600;	/* B0 transition handled in l1_cons_set_termios */
+	baud_base =3D info->state->baud_base;
+
+	if (baud =3D 38400 &&
+	    ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_CUST))
+		quot =3D info->state->custom_divisor;
+	else {
+		if (baud =3D 134)
+			/* Special case since 134 is really 134.5 */
+			quot =3D (2*baud_base / 269);
+		else if (baud)
+			quot =3D baud_base / baud;
+	}
+	/* If the quotient is zero refuse the change */
+	if (!quot && old_termios) {
+		info->tty->termios->c_cflag &=3D ~CBAUD;
+		info->tty->termios->c_cflag |=3D (old_termios->c_cflag & CBAUD);
+		baud =3D tty_get_baud_rate(info->tty);
+		if (!baud)
+			baud =3D 9600;
+		if (baud =3D 38400 &&
+		    ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_CUST))
+			quot =3D info->state->custom_divisor;
+		else {
+			if (baud =3D 134)
+				/* Special case since 134 is really 134.5 */
+				quot =3D (2*baud_base / 269);
+			else if (baud)
+				quot =3D baud_base / baud;
+		}
+	}
+	/* As a last resort, if the quotient is zero, default to 9600 bps */
+	if (!quot)
+		quot =3D baud_base / 9600;
+	/*
+	 * Work around a bug in the Oxford Semiconductor 952 rev B
+	 * chip which causes it to seriously miscalculate baud rates
+	 * when DLL is 0.
+	 */
+	info->quot =3D quot;
+	info->timeout =3D ((info->xmit_fifo_size*HZ*bits*quot) / baud_base);
+	info->timeout +=3D HZ/50;		/* Add .02 seconds of slop */
+
+	if (cflag & CRTSCTS) {
+		info->flags |=3D ASYNC_CTS_FLOW;
+	} else
+		info->flags &=3D ~ASYNC_CTS_FLOW;
+	if (cflag & CLOCAL)
+		info->flags &=3D ~ASYNC_CHECK_CD;
+	else {
+		info->flags |=3D ASYNC_CHECK_CD;
+	}
+
+	/*
+	 * Set up parity check flag
+	 */
+#define RELEVANT_IFLAG(iflag) (iflag & (IGNBRK|BRKINT|IGNPAR|PARMRK|INPCK))
+
+	info->read_status_mask =3D LSR_OVRRUN | LSR_XHRE | LSR_RCA;
+	if (I_INPCK(info->tty))
+		info->read_status_mask |=3D LSR_FRMERR | LSR_PARERR;
+	if (I_BRKINT(info->tty) || I_PARMRK(info->tty))
+		info->read_status_mask |=3D LSR_BRKDET;
+=09
+	/*
+	 * Characters to ignore
+	 */
+	info->ignore_status_mask =3D 0;
+	if (I_IGNPAR(info->tty))
+		info->ignore_status_mask |=3D LSR_PARERR | LSR_FRMERR;
+	if (I_IGNBRK(info->tty)) {
+		info->ignore_status_mask |=3D LSR_BRKDET;
+		/*
+		 * If we're ignore parity and break indicators, ignore=20
+		 * overruns too.  (For real raw support).
+		 */
+		if (I_IGNPAR(info->tty))
+			info->ignore_status_mask |=3D LSR_OVRRUN;
+	}
+	/*
+	 * !!! ignore all characters if CREAD is not set
+	 */
+	if ((cflag & CREAD) =3D 0)
+		info->ignore_status_mask |=3D LSR_RCA;
+#ifdef L1_SET_BAUD
+	{
+		void l1_set_baud(int);
+		l1_set_baud(baud);
+		info->LCR =3D cval;				/* Save LCR */
+	}
+#else
+	save_flags(flags); cli();
+	serial_out(info, REG_LCR, cval | LCR_DLAB);	/* set DLAB */
+	serial_out(info, REG_DLL, quot & 0xff);	/* LS of divisor */
+	serial_out(info, REG_DLH, quot >> 8);		/* MS of divisor */
+	serial_out(info, REG_LCR, cval);		/* reset DLAB */
+	restore_flags(flags);
+#endif	/* L1_SET_BAUD */
+}
+
+static void
+l1_cons_put_char(struct tty_struct *tty, unsigned char ch)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+	unsigned long flags;
+
+	if (serial_paranoia_check(info, tty->device, "l1_cons_put_char"))
+		return;
+
+	if (!tty || !info->xmit.buf)
+		return;
+
+	save_flags(flags); cli();
+	if (CIRC_SPACE(info->xmit.head,
+		       info->xmit.tail,
+		       SERIAL_XMIT_SIZE) =3D 0) {
+		restore_flags(flags);
+		return;
+	}
+
+	info->xmit.buf[info->xmit.head] =3D ch;
+	info->xmit.head =3D (info->xmit.head + 1) & (SERIAL_XMIT_SIZE-1);
+	restore_flags(flags);
+	transmit_chars(info, 0);
+}
+
+static int
+l1_cons_write(struct tty_struct * tty, int from_user,
+		    const unsigned char *buf, int count)
+{
+	int	c, ret =3D 0;
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+	unsigned long flags;
+
+
+	if (serial_paranoia_check(info, tty->device, "l1_cons_write"))
+		return 0;
+
+	if (!tty || !info->xmit.buf || !l1_tmp_buffer)
+		return 0;
+
+	save_flags(flags);
+	if (from_user) {
+		down(&l1_tmp_buffer_sem);
+		while (1) {
+			int c1;
+			c =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_S=
IZE);
+			if (count < c)
+				c =3D count;
+			if (c <=3D 0)
+				break;
+
+			c -=3D copy_from_user(l1_tmp_buffer, buf, c);
+			if (!c) {
+				if (!ret)
+					ret =3D -EFAULT;
+				break;
+			}
+			cli();
+			c1 =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_=
SIZE);
+			if (c1 < c)
+				c =3D c1;
+			memcpy(info->xmit.buf + info->xmit.head, l1_tmp_buffer, c);
+			info->xmit.head =3D ((info->xmit.head + c) & (SERIAL_XMIT_SIZE-1));
+			restore_flags(flags);
+			buf +=3D c;
+			count -=3D c;
+			ret +=3D c;
+		}
+		up(&l1_tmp_buffer_sem);
+	} else {
+		cli();
+		while (1) {
+			c =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_S=
IZE);
+			if (count < c)
+				c =3D count;
+			if (c <=3D 0) {
+				break;
+			}
+			memcpy(info->xmit.buf + info->xmit.head, buf, c);
+			info->xmit.head =3D ((info->xmit.head + c) & (SERIAL_XMIT_SIZE-1));
+			buf +=3D c;
+			count -=3D c;
+			ret +=3D c;
+		}
+		restore_flags(flags);
+	}
+	if ( (info->xmit.head !=3D info->xmit.tail) && !tty->stopped && !tty->hw_=
stopped ) {
+		transmit_chars(info, 0);
+	}
+	return ret;
+}
+
+static int
+l1_cons_write_room(struct tty_struct *tty)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+
+	if (serial_paranoia_check(info, tty->device, "l1_cons_write_room"))
+		return 0;
+	return CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
+}
+
+static int
+l1_cons_chars_in_buffer(struct tty_struct *tty)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+			=09
+	if (serial_paranoia_check(info, tty->device, "l1_cons_chars_in_buffer"))
+		return 0;
+	return CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
+}
+
+static void
+l1_cons_flush_buffer(struct tty_struct *tty)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+	unsigned long flags;
+=09
+	if (serial_paranoia_check(info, tty->device, "l1_cons_flush_buffer"))
+		return;
+	save_flags(flags); cli();
+	info->xmit.head =3D info->xmit.tail =3D 0;
+	restore_flags(flags);
+	wake_up_interruptible(&tty->write_wait);
+#ifdef SERIAL_HAVE_POLL_WAIT
+	wake_up_interruptible(&tty->poll_wait);
+#endif
+	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
+	    tty->ldisc.write_wakeup)
+		(tty->ldisc.write_wakeup)(tty);
+}
+
+/*
+ * ------------------------------------------------------------
+ * l1_cons_ioctl() and friends
+ * ------------------------------------------------------------
+ */
+
+static int
+get_serial_info(struct async_struct * info, struct serial_struct * retinfo)
+{
+	struct serial_struct tmp;
+	struct serial_state *state =3D info->state;
+  =20
+	if (!retinfo)
+		return -EFAULT;
+	memset(&tmp, 0, sizeof(tmp));
+	tmp.type =3D state->type;
+	tmp.line =3D state->line;
+	tmp.port =3D state->port;
+	if (HIGH_BITS_OFFSET)
+		tmp.port_high =3D state->port >> HIGH_BITS_OFFSET;
+	else
+		tmp.port_high =3D 0;
+	tmp.irq =3D state->irq;
+	tmp.flags =3D state->flags;
+	tmp.xmit_fifo_size =3D state->xmit_fifo_size;
+	tmp.baud_base =3D state->baud_base;
+	tmp.close_delay =3D state->close_delay;
+	tmp.closing_wait =3D state->closing_wait;
+	tmp.custom_divisor =3D state->custom_divisor;
+	tmp.hub6 =3D state->hub6;
+	tmp.io_type =3D state->io_type;
+	if (copy_to_user(retinfo,&tmp,sizeof(*retinfo)))
+		return -EFAULT;
+	return 0;
+}
+
+static int
+set_serial_info(struct async_struct * info, struct serial_struct * new_inf=
o)
+{
+	struct serial_struct new_serial;
+ 	struct serial_state old_state, *state;
+	unsigned int		i,change_irq,change_port;
+	int 			retval =3D 0;
+	unsigned long		new_port;
+
+	if (copy_from_user(&new_serial,new_info,sizeof(new_serial)))
+		return -EFAULT;
+	state =3D info->state;
+	old_state =3D *state;
+
+	new_port =3D new_serial.port;
+	if (HIGH_BITS_OFFSET)
+		new_port +=3D (unsigned long) new_serial.port_high << HIGH_BITS_OFFSET;
+
+	change_irq =3D new_serial.irq !=3D state->irq;
+	change_port =3D (new_port !=3D ((int) state->port)) ||
+		(new_serial.hub6 !=3D state->hub6);
+ =20
+	if (!capable(CAP_SYS_ADMIN)) {
+		if (change_irq || change_port ||
+		    (new_serial.baud_base !=3D state->baud_base) ||
+		    (new_serial.type !=3D state->type) ||
+		    (new_serial.close_delay !=3D state->close_delay) ||
+		    (new_serial.xmit_fifo_size !=3D state->xmit_fifo_size) ||
+		    ((new_serial.flags & ~ASYNC_USR_MASK) !+		     (state->flags & ~ASYN=
C_USR_MASK)))
+			return -EPERM;
+		state->flags =3D ((state->flags & ~ASYNC_USR_MASK) |
+			       (new_serial.flags & ASYNC_USR_MASK));
+		info->flags =3D ((info->flags & ~ASYNC_USR_MASK) |
+			       (new_serial.flags & ASYNC_USR_MASK));
+		state->custom_divisor =3D new_serial.custom_divisor;
+		goto check_and_exit;
+	}
+
+	if ( IS_RUNNING_ON_SIMULATOR() )
+		new_serial.irq =3D 0;
+	else
+		new_serial.irq =3D l1_get_intr_value();
+
+	if ((new_serial.irq >=3D NR_IRQS) || (new_serial.irq < 0) ||
+	    (new_serial.baud_base < 9600)|| (new_serial.type < PORT_UNKNOWN) ||
+	    (new_serial.type > PORT_MAX) || (new_serial.type =3D PORT_CIRRUS) ||
+	    (new_serial.type =3D PORT_STARTECH)) {
+		return -EINVAL;
+	}
+
+	if ((new_serial.type !=3D state->type) || (new_serial.xmit_fifo_size <=3D=
 0))
+		new_serial.xmit_fifo_size =3D uart_config[new_serial.type].dfl_xmit_fifo=
_size;
+
+	/* Make sure address is not already in use */
+	if (new_serial.type) {
+		for (i =3D 0 ; i < NR_PORTS; i++)
+			if ((state !=3D &l1_table[i]) &&
+			    (l1_table[i].port =3D new_port) &&
+			    l1_table[i].type)
+				return -EADDRINUSE;
+	}
+
+	if ((change_port || change_irq) && (state->count > 1))
+		return -EBUSY;
+
+	/*
+	 * OK, past this point, all the error checking has been done.
+	 * At this point, we start making changes.....
+	 */
+
+	state->baud_base =3D new_serial.baud_base;
+	state->flags =3D ((state->flags & ~ASYNC_FLAGS) |
+			(new_serial.flags & ASYNC_FLAGS));
+	info->flags =3D ((state->flags & ~ASYNC_INTERNAL_FLAGS) |
+		       (info->flags & ASYNC_INTERNAL_FLAGS));
+	state->custom_divisor =3D new_serial.custom_divisor;
+	state->close_delay =3D new_serial.close_delay * HZ/100;
+	state->closing_wait =3D new_serial.closing_wait * HZ/100;
+#if (LINUX_VERSION_CODE > 0x20100)
+	info->tty->low_latency =3D (info->flags & ASYNC_LOW_LATENCY) ? 1 : 0;
+#endif
+	info->xmit_fifo_size =3D state->xmit_fifo_size +		new_serial.xmit_fifo_si=
ze;
+
+	if ((state->type !=3D PORT_UNKNOWN) && state->port) {
+		release_region(state->port,8);
+	}
+	state->type =3D new_serial.type;
+	if (change_port || change_irq) {
+		/*
+		 * We need to shutdown the serial port at the old
+		 * port/irq combination.
+		 */
+		shutdown(info);
+		state->irq =3D new_serial.irq;
+		info->port =3D state->port =3D new_port;
+	}
+	if ((state->type !=3D PORT_UNKNOWN) && state->port) {
+			request_region(state->port,8,"serial(set)");
+	}
+
+=09
+check_and_exit:
+	if (!state->port || !state->type)
+		return 0;
+	if (info->flags & ASYNC_INITIALIZED) {
+		if (((old_state.flags & ASYNC_SPD_MASK) !+		     (state->flags & ASYNC_S=
PD_MASK)) ||
+		    (old_state.custom_divisor !=3D state->custom_divisor)) {
+#if (LINUX_VERSION_CODE >=3D 131394) /* Linux 2.1.66 */
+			if ((state->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_HI)
+				info->tty->alt_speed =3D 57600;
+			if ((state->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_VHI)
+				info->tty->alt_speed =3D 115200;
+			if ((state->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_SHI)
+				info->tty->alt_speed =3D 230400;
+			if ((state->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_WARP)
+				info->tty->alt_speed =3D 460800;
+#endif
+			change_speed(info, 0);
+		}
+	} else
+		retval =3D startup(info);
+	return retval;
+}
+
+
+/*
+ * get_lsr_info - get line status register info
+ *
+ * Purpose: Let user call ioctl() to get info when the UART physically
+ * 	    is emptied.  On bus types like RS485, the transmitter must
+ * 	    release the bus after transmitting. This must be done when
+ * 	    the transmit shift register is empty, not be done when the
+ * 	    transmit holding register is empty.  This functionality
+ * 	    allows an RS485 driver to be written in user space.=20
+ */
+static int
+get_lsr_info(struct async_struct * info, unsigned int *value)
+{
+	unsigned char status;
+	unsigned int result;
+
+	status =3D serial_in(info, REG_LSR);
+	result =3D ((status & LSR_XSRE) ? TIOCSER_TEMT : 0);
+
+	/*
+	 * If we're about to load something into the transmit
+	 * register, we'll pretend the transmitter isn't empty to
+	 * avoid a race condition (depending on when the transmit
+	 * interrupt happens).
+	 */
+	if ( ((CIRC_CNT(info->xmit.head, info->xmit.tail,
+		       SERIAL_XMIT_SIZE) > 0) &&
+	     !info->tty->stopped && !info->tty->hw_stopped))
+		result &=3D TIOCSER_TEMT;
+
+	if (copy_to_user(value, &result, sizeof(int)))
+		return -EFAULT;
+	return 0;
+}
+
+
+static int
+do_autoconfig(struct async_struct * info)
+{
+	int retval;
+=09
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+=09
+	if (info->state->count > 1)
+		return -EBUSY;
+=09
+	shutdown(info);
+
+	autoconfig(info->state);
+	if ( IS_RUNNING_ON_SIMULATOR() )
+		info->state->irq =3D 0;
+	else
+		info->state->irq =3D l1_get_intr_value();
+
+	retval =3D startup(info);
+	if (retval)
+		return retval;
+	return 0;
+}
+
+static int
+l1_cons_ioctl(struct tty_struct *tty, struct file * file, unsigned int cmd=
, unsigned long arg)
+{
+	struct async_struct * info =3D (struct async_struct *)tty->driver_data;
+	struct async_icount cprev, cnow;	/* kernel counter temps */
+	struct serial_icounter_struct icount;
+	unsigned long flags;
+#if (LINUX_VERSION_CODE < 131394) /* Linux 2.1.66 */
+	int retval, tmp;
+#endif
+=09
+	if (serial_paranoia_check(info, tty->device, "l1_cons_ioctl"))
+		return -ENODEV;
+
+	if ((cmd !=3D TIOCGSERIAL) && (cmd !=3D TIOCSSERIAL) &&
+	    (cmd !=3D TIOCSERCONFIG) && (cmd !=3D TIOCSERGSTRUCT) &&
+	    (cmd !=3D TIOCMIWAIT) && (cmd !=3D TIOCGICOUNT)) {
+		if (tty->flags & (1 << TTY_IO_ERROR))
+		    return -EIO;
+	}
+=09
+	switch (cmd) {
+		case TIOCGSERIAL:
+			return get_serial_info(info, (struct serial_struct *) arg);
+		case TIOCSSERIAL:
+			return set_serial_info(info, (struct serial_struct *) arg);
+		case TIOCSERCONFIG:
+			return do_autoconfig(info);
+
+		case TIOCSERGETLSR: /* Get line status register */
+			return get_lsr_info(info, (unsigned int *) arg);
+
+		case TIOCSERGSTRUCT:
+			if (copy_to_user((struct async_struct *) arg,
+					 info, sizeof(struct async_struct)))
+				return -EFAULT;
+			return 0;
+			=09
+		/*
+		 * Wait for any of the 4 modem inputs (DCD,RI,DSR,CTS) to change
+		 * - mask passed in arg for lines of interest
+ 		 *   (use |'ed TIOCM_RNG/DSR/CD/CTS for masking)
+		 * Caller should use TIOCGICOUNT to see which one it was
+		 */
+		case TIOCMIWAIT:
+			save_flags(flags); cli();
+			/* note the counters on entry */
+			cprev =3D info->state->icount;
+			restore_flags(flags);
+			while (1) {
+				interruptible_sleep_on(&info->delta_msr_wait);
+				/* see if a signal did it */
+				if (signal_pending(current))
+					return -ERESTARTSYS;
+				save_flags(flags); cli();
+				cnow =3D info->state->icount; /* atomic copy */
+				restore_flags(flags);
+				if (cnow.rng =3D cprev.rng && cnow.dsr =3D cprev.dsr &&=20
+				    cnow.dcd =3D cprev.dcd && cnow.cts =3D cprev.cts)
+					return -EIO; /* no change =3D> error */
+				if ( ((arg & TIOCM_RNG) && (cnow.rng !=3D cprev.rng)) ||
+				     ((arg & TIOCM_DSR) && (cnow.dsr !=3D cprev.dsr)) ||
+				     ((arg & TIOCM_CD)  && (cnow.dcd !=3D cprev.dcd)) ||
+				     ((arg & TIOCM_CTS) && (cnow.cts !=3D cprev.cts)) ) {
+					return 0;
+				}
+				cprev =3D cnow;
+			}
+			/* NOTREACHED */
+
+		/*=20
+		 * Get counter of input serial line interrupts (DCD,RI,DSR,CTS)
+		 * Return: write counters to the user passed counter struct
+		 * NB: both 1->0 and 0->1 transitions are counted except for
+		 *     RI where only 0->1 is counted.
+		 */
+		case TIOCGICOUNT:
+			save_flags(flags); cli();
+			cnow =3D info->state->icount;
+			restore_flags(flags);
+			icount.cts =3D cnow.cts;
+			icount.dsr =3D cnow.dsr;
+			icount.rng =3D cnow.rng;
+			icount.dcd =3D cnow.dcd;
+			icount.rx =3D cnow.rx;
+			icount.tx =3D cnow.tx;
+			icount.frame =3D cnow.frame;
+			icount.overrun =3D cnow.overrun;
+			icount.parity =3D cnow.parity;
+			icount.brk =3D cnow.brk;
+			icount.buf_overrun =3D cnow.buf_overrun;
+		=09
+			if (copy_to_user((void *)arg, &icount, sizeof(icount)))
+				return -EFAULT;
+			return 0;
+		case TIOCSERGWILD:
+		case TIOCSERSWILD:
+			/* "setserial -W" is called in Debian boot */
+			printk ("TIOCSER?WILD ioctl obsolete, ignored.\n");
+			return 0;
+
+		default:
+			return -ENOIOCTLCMD;
+		}
+	return 0;
+}
+
+static void
+l1_cons_set_termios(struct tty_struct *tty, struct termios *old_termios)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+	unsigned int cflag =3D tty->termios->c_cflag;
+=09
+	if (   (cflag =3D old_termios->c_cflag)
+	    && (   RELEVANT_IFLAG(tty->termios->c_iflag)=20
+		=3D RELEVANT_IFLAG(old_termios->c_iflag)))
+	  return;
+
+	change_speed(info, old_termios);
+
+	/* Handle turning off CRTSCTS */
+	if ((old_termios->c_cflag & CRTSCTS) &&
+	    !(tty->termios->c_cflag & CRTSCTS)) {
+		tty->hw_stopped =3D 0;
+		l1_cons_start(tty);
+	}
+}
+
+/*
+ * ------------------------------------------------------------
+ * l1_cons_close()
+ *=20
+ * This routine is called when the serial port gets closed.  First, we
+ * wait for the last remaining data to be sent.  Then, we unlink its
+ * async structure from the interrupt chain if necessary, and we free
+ * that IRQ if nothing is left in the chain.
+ * ------------------------------------------------------------
+ */
+static void
+l1_cons_close(struct tty_struct *tty, struct file * filp)
+{
+	struct async_struct * info =3D (struct async_struct *)tty->driver_data;
+	struct serial_state *state;
+	unsigned long flags;
+
+	if (!info || serial_paranoia_check(info, tty->device, "l1_cons_close"))
+		return;
+
+	state =3D info->state;
+=09
+	save_flags(flags); cli();
+=09
+	if (tty_hung_up_p(filp)) {
+		DBG_CNT("before DEC-hung");
+		MOD_DEC_USE_COUNT;
+		restore_flags(flags);
+		return;
+	}
+=09
+#ifdef SERIAL_DEBUG_OPEN
+	printk("l1_cons_close ttys%d, count =3D %d\n", info->line, state->count);
+#endif
+	if ((tty->count =3D 1) && (state->count !=3D 1)) {
+		/*
+		 * Uh, oh.  tty->count is 1, which means that the tty
+		 * structure will be freed.  state->count should always
+		 * be one in these conditions.  If it's greater than
+		 * one, we've got real problems, since it means the
+		 * serial port won't be shutdown.
+		 */
+		printk("l1_cons_close: bad serial port count; tty->count is 1, "
+		       "state->count is %d\n", state->count);
+		state->count =3D 1;
+	}
+	if (--state->count < 0) {
+		printk("l1_cons_close: bad serial port count for ttys%d: %d\n",
+		       info->line, state->count);
+		state->count =3D 0;
+	}
+	if (state->count) {
+		DBG_CNT("before DEC-2");
+		MOD_DEC_USE_COUNT;
+		restore_flags(flags);
+		return;
+	}
+	info->flags |=3D ASYNC_CLOSING;
+	restore_flags(flags);
+	/*
+	 * Save the termios structure, since this port may have
+	 * separate termios for callout and dialin.
+	 */
+	if (info->flags & ASYNC_NORMAL_ACTIVE)
+		info->state->normal_termios =3D *tty->termios;
+	if (info->flags & ASYNC_CALLOUT_ACTIVE)
+		info->state->callout_termios =3D *tty->termios;
+	/*
+	 * Now we wait for the transmit buffer to clear; and we notify=20
+	 * the line discipline to only process XON/XOFF characters.
+	 */
+	tty->closing =3D 1;
+	if (info->closing_wait !=3D ASYNC_CLOSING_WAIT_NONE)
+		tty_wait_until_sent(tty, info->closing_wait);
+	/*
+	 * At this point we stop accepting input.  To do this, we
+	 * disable the receive line status interrupts, and tell the
+	 * interrupt driver to stop checking the data ready bit in the
+	 * line status register.
+	 */
+	info->read_status_mask &=3D ~LSR_RCA;
+	if (info->flags & ASYNC_INITIALIZED) {
+		/*
+		 * Before we drop DTR, make sure the UART transmitter
+		 * has completely drained; this is especially
+		 * important if there is a transmit FIFO!
+		 */
+		l1_cons_wait_until_sent(tty, info->timeout);
+	}
+	shutdown(info);
+	if (tty->driver.flush_buffer)
+		tty->driver.flush_buffer(tty);
+	if (tty->ldisc.flush_buffer)
+		tty->ldisc.flush_buffer(tty);
+	tty->closing =3D 0;
+	info->event =3D 0;
+	info->tty =3D 0;
+	if (info->blocked_open) {
+		if (info->close_delay) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			schedule_timeout(info->close_delay);
+		}
+		wake_up_interruptible(&info->open_wait);
+	}
+	info->flags &=3D ~(ASYNC_NORMAL_ACTIVE|ASYNC_CALLOUT_ACTIVE|
+			 ASYNC_CLOSING);
+	wake_up_interruptible(&info->close_wait);
+	MOD_DEC_USE_COUNT;
+}
+
+/*
+ * l1_cons_wait_until_sent() --- wait until the transmitter is empty
+ */
+static void
+l1_cons_wait_until_sent(struct tty_struct *tty, int timeout)
+{
+	struct async_struct * info =3D (struct async_struct *)tty->driver_data;
+	unsigned long orig_jiffies, char_time;
+	int lsr;
+=09
+	if (serial_paranoia_check(info, tty->device, "l1_cons_wait_until_sent"))
+		return;
+
+	if (info->state->type =3D PORT_UNKNOWN)
+		return;
+
+	if (info->xmit_fifo_size =3D 0)
+		return; /* Just in case.... */
+
+	orig_jiffies =3D jiffies;
+	/*
+	 * Set the check interval to be 1/5 of the estimated time to
+	 * send a single character, and make it at least 1.  The check
+	 * interval should also be less than the timeout.
+	 *=20
+	 * Note: we have to use pretty tight timings here to satisfy
+	 * the NIST-PCTS.
+	 */
+	char_time =3D (info->timeout - HZ/50) / info->xmit_fifo_size;
+	char_time =3D char_time / 5;
+	if (char_time =3D 0)
+		char_time =3D 1;
+	if (timeout && timeout < char_time)
+		char_time =3D timeout;
+	/*
+	 * If the transmitter hasn't cleared in twice the approximate
+	 * amount of time to send the entire FIFO, it probably won't
+	 * ever clear.  This assumes the UART isn't doing flow
+	 * control, which is currently the case.  Hence, if it ever
+	 * takes longer than info->timeout, this is probably due to a
+	 * UART bug of some kind.  So, we clamp the timeout parameter at
+	 * 2*info->timeout.
+	 */
+	if (!timeout || timeout > 2*info->timeout)
+		timeout =3D 2*info->timeout;
+#ifdef SERIAL_DEBUG_RS_WAIT_UNTIL_SENT
+	printk("In l1_cons_wait_until_sent(%d) check=3D%lu...", timeout, char_tim=
e);
+	printk("jiff=3D%lu...", jiffies);
+#endif
+	while (!((lsr =3D serial_in(info, REG_LSR)) & LSR_XSRE)) {
+#ifdef SERIAL_DEBUG_RS_WAIT_UNTIL_SENT
+		printk("lsr =3D %d (jiff=3D%lu)...", lsr, jiffies);
+#endif
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(char_time);
+		if (signal_pending(current))
+			break;
+		if (timeout && time_after(jiffies, orig_jiffies + timeout))
+			break;
+	}
+	set_current_state(TASK_RUNNING);
+#ifdef SERIAL_DEBUG_RS_WAIT_UNTIL_SENT
+	printk("lsr =3D %x (jiff=3D%lu)...done\n", lsr, jiffies);
+#endif
+}
+
+/*
+ * l1_cons_hangup() --- called by tty_hangup() when a hangup is signaled.
+ */
+static void
+l1_cons_hangup(struct tty_struct *tty)
+{
+	struct async_struct * info =3D (struct async_struct *)tty->driver_data;
+	struct serial_state *state =3D info->state;
+=09
+	if (serial_paranoia_check(info, tty->device, "l1_cons_hangup"))
+		return;
+
+	state =3D info->state;
+=09
+	l1_cons_flush_buffer(tty);
+	if (info->flags & ASYNC_CLOSING)
+		return;
+	shutdown(info);
+	info->event =3D 0;
+	state->count =3D 0;
+	info->flags &=3D ~(ASYNC_NORMAL_ACTIVE|ASYNC_CALLOUT_ACTIVE);
+	info->tty =3D 0;
+	wake_up_interruptible(&info->open_wait);
+}
+
+/*
+ * ------------------------------------------------------------
+ * l1_cons_open() and friends
+ * ------------------------------------------------------------
+ */
+static int
+block_til_ready(struct tty_struct *tty, struct file * filp,
+			   struct async_struct *info)
+{
+	DECLARE_WAITQUEUE(wait, current);
+	struct serial_state *state =3D info->state;
+	int		retval;
+	int		do_clocal =3D 0, extra_count =3D 0;
+	unsigned long	flags;
+
+	/*
+	 * If the device is in the middle of being closed, then block
+	 * until it's done, and then try again.
+	 */
+	if (tty_hung_up_p(filp) ||
+	    (info->flags & ASYNC_CLOSING)) {
+		if (info->flags & ASYNC_CLOSING)
+			interruptible_sleep_on(&info->close_wait);
+#ifdef SERIAL_DO_RESTART
+		return ((info->flags & ASYNC_HUP_NOTIFY) ?
+			-EAGAIN : -ERESTARTSYS);
+#else
+		return -EAGAIN;
+#endif
+	}
+
+	/*
+	 * If this is a callout device, then just make sure the normal
+	 * device isn't being used.
+	 */
+	if (tty->driver.subtype =3D SERIAL_TYPE_CALLOUT) {
+		if (info->flags & ASYNC_NORMAL_ACTIVE)
+			return -EBUSY;
+		if ((info->flags & ASYNC_CALLOUT_ACTIVE) &&
+		    (info->flags & ASYNC_SESSION_LOCKOUT) &&
+		    (info->session !=3D current->session))
+		    return -EBUSY;
+		if ((info->flags & ASYNC_CALLOUT_ACTIVE) &&
+		    (info->flags & ASYNC_PGRP_LOCKOUT) &&
+		    (info->pgrp !=3D current->pgrp))
+		    return -EBUSY;
+		info->flags |=3D ASYNC_CALLOUT_ACTIVE;
+		return 0;
+	}
+=09
+	/*
+	 * If non-blocking mode is set, or the port is not enabled,
+	 * then make the check up front and then exit.
+	 */
+	if ((filp->f_flags & O_NONBLOCK) ||
+	    (tty->flags & (1 << TTY_IO_ERROR))) {
+		if (info->flags & ASYNC_CALLOUT_ACTIVE)
+			return -EBUSY;
+		info->flags |=3D ASYNC_NORMAL_ACTIVE;
+		return 0;
+	}
+
+	if (info->flags & ASYNC_CALLOUT_ACTIVE) {
+		if (state->normal_termios.c_cflag & CLOCAL)
+			do_clocal =3D 1;
+	} else {
+		if (tty->termios->c_cflag & CLOCAL)
+			do_clocal =3D 1;
+	}
+=09
+	/*
+	 * Block waiting for the carrier detect and the line to become
+	 * free (i.e., not in use by the callout).  While we are in
+	 * this loop, state->count is dropped by one, so that
+	 * l1_cons_close() knows when to free things.  We restore it upon
+	 * exit, either normal or abnormal.
+	 */
+	retval =3D 0;
+	add_wait_queue(&info->open_wait, &wait);
+#ifdef SERIAL_DEBUG_OPEN
+	printk("block_til_ready before block: ttys%d, count =3D %d\n",
+	       state->line, state->count);
+#endif
+	save_flags(flags); cli();
+	if (!tty_hung_up_p(filp)) {
+		extra_count =3D 1;
+		state->count--;
+	}
+	restore_flags(flags);
+	info->blocked_open++;
+	while (1) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (tty_hung_up_p(filp) ||
+		    !(info->flags & ASYNC_INITIALIZED)) {
+#ifdef SERIAL_DO_RESTART
+			if (info->flags & ASYNC_HUP_NOTIFY)
+				retval =3D -EAGAIN;
+			else
+				retval =3D -ERESTARTSYS;=09
+#else
+			retval =3D -EAGAIN;
+#endif
+			break;
+		}
+		if (!(info->flags & ASYNC_CALLOUT_ACTIVE) &&
+		    !(info->flags & ASYNC_CLOSING) &&
+		    (do_clocal || (serial_in(info, REG_MSR) &
+				   MSR_DCD)))
+			break;
+		if (signal_pending(current)) {
+			retval =3D -ERESTARTSYS;
+			break;
+		}
+#ifdef SERIAL_DEBUG_OPEN
+		printk("block_til_ready blocking: ttys%d, count =3D %d\n",
+		       info->line, state->count);
+#endif
+		schedule();
+	}
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(&info->open_wait, &wait);
+	if (extra_count)
+		state->count++;
+	info->blocked_open--;
+#ifdef SERIAL_DEBUG_OPEN
+	printk("block_til_ready after blocking: ttys%d, count =3D %d\n",
+	       info->line, state->count);
+#endif
+	if (retval)
+		return retval;
+	info->flags |=3D ASYNC_NORMAL_ACTIVE;
+	return 0;
+}
+
+static int
+get_async_struct(int line, struct async_struct **ret_info)
+{
+	struct async_struct *info;
+	struct serial_state *sstate;
+
+	sstate =3D l1_table + line;
+	sstate->count++;
+	if (sstate->info) {
+		*ret_info =3D sstate->info;
+		return 0;
+	}
+	info =3D kmalloc(sizeof(struct async_struct), GFP_KERNEL);
+	if (!info) {
+		sstate->count--;
+		return -ENOMEM;
+	}
+	memset(info, 0, sizeof(struct async_struct));
+	init_waitqueue_head(&info->open_wait);
+	init_waitqueue_head(&info->close_wait);
+	init_waitqueue_head(&info->delta_msr_wait);
+	info->magic =3D SERIAL_MAGIC;
+	info->port =3D sstate->port;
+	info->flags =3D sstate->flags;
+	info->io_type =3D sstate->io_type;
+	info->iomem_base =3D sstate->iomem_base;
+	info->iomem_reg_shift =3D sstate->iomem_reg_shift;
+	info->xmit_fifo_size =3D sstate->xmit_fifo_size;
+	info->line =3D line;
+	info->tqueue.routine =3D do_softint;
+	info->tqueue.data =3D info;
+	info->state =3D sstate;
+	if (sstate->info) {
+		kfree(info);
+		*ret_info =3D sstate->info;
+		return 0;
+	}
+	*ret_info =3D sstate->info =3D info;
+	return 0;
+}
+
+/*
+ * This routine is called whenever a serial port is opened.  It
+ * enables interrupts for a serial port, linking in its async structure in=
to
+ * the IRQ chain.   It also performs the serial-specific
+ * initialization for the tty structure.
+ */
+static int
+l1_cons_open(struct tty_struct *tty, struct file * filp)
+{
+	struct async_struct	*info;
+	int 			retval, line;
+	unsigned long		page;
+
+	MOD_INC_USE_COUNT;
+	line =3D MINOR(tty->device) - tty->driver.minor_start;
+	if ((line < 0) || (line >=3D NR_PORTS)) {
+		MOD_DEC_USE_COUNT;
+		return -ENODEV;
+	}
+	retval =3D get_async_struct(line, &info);
+	if (retval) {
+		MOD_DEC_USE_COUNT;
+		return retval;
+	}
+	tty->driver_data =3D info;
+	info->tty =3D tty;
+	if (serial_paranoia_check(info, tty->device, "l1_cons_open"))
+		return -ENODEV;
+
+#ifdef SERIAL_DEBUG_OPEN
+	printk("l1_cons_open %s%d, count =3D %d\n", tty->driver.name, info->line,
+	       info->state->count);
+#endif
+#if (LINUX_VERSION_CODE > 0x20100)
+	info->tty->low_latency =3D (info->flags & ASYNC_LOW_LATENCY) ? 1 : 0;
+#endif
+
+	if (!l1_tmp_buffer) {
+		page =3D get_zeroed_page(GFP_KERNEL);
+		if (!page) {
+			MOD_DEC_USE_COUNT;
+			return -ENOMEM;
+		}
+		if (l1_tmp_buffer)
+			free_page(page);
+		else
+			l1_tmp_buffer =3D (unsigned char *) page;
+	}
+
+	/*
+	 * If the port is the middle of closing, bail out now
+	 */
+	if (tty_hung_up_p(filp) ||
+	    (info->flags & ASYNC_CLOSING)) {
+		if (info->flags & ASYNC_CLOSING)
+			interruptible_sleep_on(&info->close_wait);
+		MOD_DEC_USE_COUNT;
+#ifdef SERIAL_DO_RESTART
+		return ((info->flags & ASYNC_HUP_NOTIFY) ?
+			-EAGAIN : -ERESTARTSYS);
+#else
+		return -EAGAIN;
+#endif
+	}
+
+	/* Start up serial port */
+
+	retval =3D startup(info);
+	if (retval) {
+		MOD_DEC_USE_COUNT;
+		return retval;
+	}
+
+	retval =3D block_til_ready(tty, filp, info);
+	if (retval) {
+#ifdef SERIAL_DEBUG_OPEN
+		printk("l1_cons_open returning after block_til_ready with %d\n",
+		       retval);
+#endif
+		MOD_DEC_USE_COUNT;
+		return retval;
+	}
+
+	if ((info->state->count =3D 1) &&
+	    (info->flags & ASYNC_SPLIT_TERMIOS)) {
+		if (tty->driver.subtype =3D SERIAL_TYPE_NORMAL)
+			*tty->termios =3D info->state->normal_termios;
+		else=20
+			*tty->termios =3D info->state->callout_termios;
+		change_speed(info, 0);
+	}
+	if (sgiconsole.cflag && sgiconsole.index =3D line) {
+		tty->termios->c_cflag =3D sgiconsole.cflag;
+		sgiconsole.cflag =3D 0;
+		change_speed(info, 0);
+	}
+	info->session =3D current->session;
+	info->pgrp =3D current->pgrp;
+
+#ifdef SERIAL_DEBUG_OPEN
+	printk("l1_cons_open ttys%d successful...", info->line);
+#endif
+	return 0;
+}
+
+/*
+ * /proc fs routines....
+ */
+
+static inline int
+line_info(char *buf, struct serial_state *state)
+{
+	struct async_struct *info =3D state->info, scr_info;
+	char	stat_buf[30], control, status;
+	int	ret;
+
+	ret =3D sprintf(buf, "%d: uart:%s port:%lX irq:%d",
+		      state->line, uart_config[state->type].name,=20
+		      state->port, state->irq);
+
+	if (!state->port || (state->type =3D PORT_UNKNOWN)) {
+		ret +=3D sprintf(buf+ret, "\n");
+		return ret;
+	}
+
+	/*
+	 * Figure out the current RS-232 lines
+	 */
+	if (!info) {
+		info =3D &scr_info;	/* This is just for serial_{in,out} */
+
+		info->magic =3D SERIAL_MAGIC;
+		info->port =3D state->port;
+		info->flags =3D state->flags;
+		info->quot =3D 0;
+		info->tty =3D 0;
+	}
+	status =3D serial_in(info, REG_MSR);
+	control =3D info !=3D &scr_info ? info->MCR : serial_in(info, REG_MCR);
+
+	stat_buf[0] =3D 0;
+	stat_buf[1] =3D 0;
+	if (control & MCR_RTS)
+		strcat(stat_buf, "|RTS");
+	if (status & MSR_CTS)
+		strcat(stat_buf, "|CTS");
+	if (control & MCR_DTR)
+		strcat(stat_buf, "|DTR");
+	if (status & MSR_DSR)
+		strcat(stat_buf, "|DSR");
+	if (status & MSR_DCD)
+		strcat(stat_buf, "|CD");
+	if (status & MSR_RI)
+		strcat(stat_buf, "|RI");
+
+	if (info->quot) {
+		ret +=3D sprintf(buf+ret, " baud:%d",
+			       state->baud_base / info->quot);
+	}
+
+	ret +=3D sprintf(buf+ret, " tx:%d rx:%d",
+		      state->icount.tx, state->icount.rx);
+
+	if (state->icount.frame)
+		ret +=3D sprintf(buf+ret, " fe:%d", state->icount.frame);
+=09
+	if (state->icount.parity)
+		ret +=3D sprintf(buf+ret, " pe:%d", state->icount.parity);
+=09
+	if (state->icount.brk)
+		ret +=3D sprintf(buf+ret, " brk:%d", state->icount.brk);=09
+
+	if (state->icount.overrun)
+		ret +=3D sprintf(buf+ret, " oe:%d", state->icount.overrun);
+
+	/*
+	 * Last thing is the RS-232 status lines
+	 */
+	ret +=3D sprintf(buf+ret, " %s\n", stat_buf+1);
+	return ret;
+}
+
+static int
+l1_cons_read_proc(char *page, char **start, off_t off, int count,
+		 int *eof, void *data)
+{
+	int i, len =3D 0, l;
+	off_t	begin =3D 0;
+
+	len +=3D sprintf(page, "serinfo:1.0 driver:%s%s revision:%s\n",
+		       serial_version, LOCAL_VERSTRING, serial_revdate);
+	for (i =3D 0; i < NR_PORTS && len < 4000; i++) {
+		l =3D line_info(page + len, &l1_table[i]);
+		len +=3D l;
+		if (len+begin > off+count)
+			goto done;
+		if (len+begin < off) {
+			begin +=3D len;
+			len =3D 0;
+		}
+	}
+	*eof =3D 1;
+done:
+	if (off >=3D len+begin)
+		return 0;
+	*start =3D page + (off-begin);
+	return ((count < begin+len-off) ? count : begin+len-off);
+}
+
+/*
+ * ---------------------------------------------------------------------
+ * l1_cons_init() and friends
+ *
+ * l1_cons_init() is called at boot-time to initialize the serial driver.
+ * ---------------------------------------------------------------------
+ */
+
+/*
+ * This routine prints out the appropriate serial driver version
+ * number, and identifies which options were configured into this
+ * driver.
+ */
+static char serial_options[] __initdata +#ifdef SERIAL_OPT
+       " enabled\n";
+#else
+       " no serial options enabled\n";
+#endif
+#undef SERIAL_OPT
+
+static _INLINE_ void show_serial_version(void)
+{
+ 	printk(KERN_INFO "%s version %s%s (%s) with%s", serial_name,
+	       serial_version, LOCAL_VERSTRING, serial_revdate,
+	       serial_options);
+}
+
+#define SERIAL_IN(x,c)		0
+#define SERIAL_INP(x,c)		0
+#define SERIAL_OUT(x,c,v)
+#define SERIAL_OUTP(x,c,v)
+
+/*
+ * This routine is called by l1_cons_init() to initialize a specific serial
+ * port.  It determines what type of UART chip this serial port is
+ * using: 8250, 16450, 16550, 16550A.  The important question is
+ * whether or not this UART is a 16550A or not, since this will
+ * determine whether or not we can use its FIFO features or not.
+ */
+static void
+autoconfig(struct serial_state * state)
+{
+	struct async_struct *info, scr_info;
+	unsigned long flags;
+
+	state->type =3D PORT_UNKNOWN;
+
+#ifdef SERIAL_DEBUG_AUTOCONF
+	printk("Testing ttyS%d (0x%04lx, 0x%04x)...\n", state->line,
+	       state->port, (unsigned) state->iomem_base);
+#endif
+
+	if (!CONFIGURED_SERIAL_PORT(state))
+		return;
+	=09
+	info =3D &scr_info;	/* This is just for serial_{in,out} */
+
+	info->magic =3D SERIAL_MAGIC;
+	info->state =3D state;
+	info->port =3D state->port;
+	info->flags =3D state->flags;
+	info->io_type =3D state->io_type;
+	info->iomem_base =3D state->iomem_base;
+	info->iomem_reg_shift =3D state->iomem_reg_shift;
+
+	save_flags(flags); cli();
+	state->type =3D PORT_16550A;
+	state->xmit_fifo_size =3D	uart_config[state->type].dfl_xmit_fifo_size;
+
+	if (info->port) {
+		request_region(info->port,8,"serial(auto)");
+	}
+	restore_flags(flags);
+}
+
+/*
+ * The serial driver boot-time initialization code!
+ */
+static int __init
+l1_cons_init(void)
+{
+	int i;
+	struct serial_state * state;
+
+	if (serial_timer.function) {
+		printk("RS_TIMER already set, another serial driver "
+		       "already loaded?\n");
+#ifdef MODULE
+		printk("Can't load serial driver module over built-in "
+		       "serial driver\n");
+#endif
+		return -EBUSY;
+	}
+
+	init_bh(SERIAL_BH, do_serial_bh);
+	init_timer(&serial_timer);
+	serial_timer.function =3D l1_cons_timer;
+	mod_timer(&serial_timer, jiffies + RS_STROBE_TIME);
+
+	for (i =3D 0; i < NR_IRQS; i++) {
+		IRQ_ports[i] =3D 0;
+		IRQ_timeout[i] =3D 0;
+	}
+	show_serial_version();
+
+	/* Initialize the tty_driver structure */
+=09
+	memset(&l1_serial_driver, 0, sizeof(struct tty_driver));
+	l1_serial_driver.magic =3D TTY_DRIVER_MAGIC;
+#if (LINUX_VERSION_CODE > 0x20100)
+	l1_serial_driver.driver_name =3D "serial";
+#endif
+#if (LINUX_VERSION_CODE > 0x2032D && defined(CONFIG_DEVFS_FS))
+	l1_serial_driver.name =3D "tts/%d";
+#else
+	l1_serial_driver.name =3D "ttyS";
+#endif
+	l1_serial_driver.major =3D TTY_MAJOR;
+	l1_serial_driver.minor_start =3D 64 + SERIAL_DEV_OFFSET;
+	l1_serial_driver.num =3D NR_PORTS;
+	l1_serial_driver.type =3D TTY_DRIVER_TYPE_SERIAL;
+	l1_serial_driver.subtype =3D SERIAL_TYPE_NORMAL;
+	l1_serial_driver.init_termios =3D tty_std_termios;
+	l1_serial_driver.init_termios.c_cflag =3D B9600 | CS8 | CREAD | HUPCL | C=
LOCAL;
+	l1_serial_driver.flags =3D TTY_DRIVER_REAL_RAW | TTY_DRIVER_NO_DEVFS;
+	l1_serial_driver.refcount =3D &l1_cons_serial_refcount;
+	l1_serial_driver.table =3D l1_cons_serial_table;
+	l1_serial_driver.termios =3D l1_cons_serial_termios;
+	l1_serial_driver.termios_locked =3D l1_cons_serial_termios_locked;
+
+	l1_serial_driver.open =3D l1_cons_open;
+	l1_serial_driver.close =3D l1_cons_close;
+	l1_serial_driver.write =3D l1_cons_write;
+	l1_serial_driver.put_char =3D l1_cons_put_char;
+	l1_serial_driver.write_room =3D l1_cons_write_room;
+	l1_serial_driver.chars_in_buffer =3D l1_cons_chars_in_buffer;
+	l1_serial_driver.flush_buffer =3D l1_cons_flush_buffer;
+	l1_serial_driver.ioctl =3D l1_cons_ioctl;
+	l1_serial_driver.set_termios =3D l1_cons_set_termios;
+	l1_serial_driver.hangup =3D l1_cons_hangup;
+#if (LINUX_VERSION_CODE >=3D 131343)
+	l1_serial_driver.wait_until_sent =3D l1_cons_wait_until_sent;
+	l1_serial_driver.read_proc =3D l1_cons_read_proc;
+#endif
+=09
+	/*
+	 * The callout device is just like normal device except for
+	 * major number and the subtype code.
+	 */
+	l1_callout_driver =3D l1_serial_driver;
+#if (LINUX_VERSION_CODE > 0x2032D && defined(CONFIG_DEVFS_FS))
+	l1_callout_driver.name =3D "cua/%d";
+#else
+	l1_callout_driver.name =3D "cua";
+#endif
+	l1_callout_driver.major =3D TTYAUX_MAJOR;
+	l1_callout_driver.subtype =3D SERIAL_TYPE_CALLOUT;
+#if (LINUX_VERSION_CODE >=3D 131343)
+	l1_callout_driver.read_proc =3D 0;
+	l1_callout_driver.proc_entry =3D 0;
+#endif
+
+	if (tty_register_driver(&l1_serial_driver))
+		panic("Couldn't register serial driver\n");
+	if (tty_register_driver(&l1_callout_driver))
+		panic("Couldn't register callout driver\n");
+=09
+	for (i =3D 0, state =3D l1_table; i < NR_PORTS; i++,state++) {
+		state->magic =3D SSTATE_MAGIC;
+		state->line =3D i;
+		state->type =3D PORT_UNKNOWN;
+		state->custom_divisor =3D 0;
+		state->close_delay =3D 5*HZ/10;
+		state->closing_wait =3D 30*HZ;
+		state->callout_termios =3D l1_callout_driver.init_termios;
+		state->normal_termios =3D l1_serial_driver.init_termios;
+		state->icount.cts =3D state->icount.dsr =3D=20
+		state->icount.rng =3D state->icount.dcd =3D 0;
+		state->icount.rx =3D state->icount.tx =3D 0;
+		state->icount.frame =3D state->icount.parity =3D 0;
+		state->icount.overrun =3D state->icount.brk =3D 0;
+		state->irq =3D irq_cannonicalize(state->irq);
+		if (state->port && check_region(state->port,8))
+			continue;
+
+		if (state->flags & ASYNC_BOOT_AUTOCONF)
+			autoconfig(state);
+	}
+	for (i =3D 0, state =3D l1_table; i < NR_PORTS; i++,state++) {
+		if (state->type =3D PORT_UNKNOWN)
+			continue;
+		if ( IS_RUNNING_ON_SIMULATOR() )
+			state->irq =3D 0;
+		else
+			state->irq =3D l1_get_intr_value();
+		printk(KERN_INFO "ttyS%02d%s at 0x%04lx (irq =3D %d) is a %s\n",
+		       state->line + SERIAL_DEV_OFFSET,
+		       (state->flags & ASYNC_FOURPORT) ? " FourPort" : "",
+		       state->port, state->irq,
+		       uart_config[state->type].name);
+		tty_register_devfs(&l1_serial_driver, 0,
+				   l1_serial_driver.minor_start + state->line);
+		tty_register_devfs(&l1_callout_driver, 0,
+				   l1_callout_driver.minor_start + state->line);
+	}
+	return 0;
+}
+
+static void __exit
+l1_cons_fini(void)=20
+{
+	unsigned long flags;
+	int e1, e2;
+	int i;
+	struct async_struct *info;
+
+	/* printk("Unloading %s: version %s\n", serial_name, serial_version); */
+	del_timer_sync(&serial_timer);
+	save_flags(flags); cli();
+        remove_bh(SERIAL_BH);
+	if ((e1 =3D tty_unregister_driver(&l1_serial_driver)))
+		printk("serial: failed to unregister serial driver (%d)\n",
+		       e1);
+	if ((e2 =3D tty_unregister_driver(&l1_callout_driver)))
+		printk("serial: failed to unregister callout driver (%d)\n",=20
+		       e2);
+	restore_flags(flags);
+
+	for (i =3D 0; i < NR_PORTS; i++) {
+		if ((info =3D l1_table[i].info)) {
+			l1_table[i].info =3D NULL;
+			kfree(info);
+		}
+		if ((l1_table[i].type !=3D PORT_UNKNOWN) && l1_table[i].port) {
+				release_region(l1_table[i].port, 8);
+		}
+	}
+	if (l1_tmp_buffer) {
+		unsigned long pg =3D (unsigned long) l1_tmp_buffer;
+		l1_tmp_buffer =3D NULL;
+		free_page(pg);
+	}
+}
+
+module_init(l1_cons_init);
+module_exit(l1_cons_fini);
+
+
+/*
+ * ------------------------------------------------------------
+ * Serial console driver
+ * ------------------------------------------------------------
+ */
+
+#define BOTH_EMPTY (LSR_XSRE | LSR_XHRE)
+
+static struct async_struct async_sgiconsole;
+
+/*
+ *	Wait for transmitter & holding register to empty
+ */
+static inline void
+wait_for_xmitr(struct async_struct *info)
+{
+	if ( IS_RUNNING_ON_SIMULATOR() ) {
+		int status, tmout =3D 1000000;
+
+		do {
+			status =3D serial_in(info, REG_LSR);
+
+			if (status & LSR_BRKDET)
+				lsr_break_flag =3D LSR_BRKDET;
+
+			if (--tmout =3D 0)
+				break;
+		} while((status & BOTH_EMPTY) !=3D BOTH_EMPTY);
+	}
+	return;
+}
+
+/*
+ *	Print a string to the serial port trying not to disturb
+ *	any possible real use of the port...
+ *
+ *	The console_lock must be held when we get here.
+ */
+static void
+l1_cons_serial_console_write(struct console *co, const char *s, unsigned c=
ount)
+{
+	static struct async_struct *info =3D &async_sgiconsole;
+	unsigned i, xmit_count;
+	const char *start =3D s;
+
+
+	/* output adding in CRs if needed */
+	for (xmit_count =3D 0, i =3D 0; i < count; i++, s++, xmit_count++) {
+
+		/*
+		 *	Send the character out.
+		 *	If a LF, also do CR...
+		 */
+		if ( IS_RUNNING_ON_SIMULATOR() ) {
+			wait_for_xmitr(info);
+			serial_out(info, L1_REG_DAT, *s);
+		}
+		if (*s =3D 10) {
+			char ch =3D 13;
+			wait_for_xmitr(info);
+			if ( IS_RUNNING_ON_SIMULATOR() ) {
+				serial_out(info, L1_REG_DAT, 13);
+			}
+			else {
+				extern int l1_serial_out(char *, int);
+				(void)l1_serial_out((char *)start, xmit_count);
+				start =3D s;
+				xmit_count =3D 0;
+				(void)l1_serial_out(&ch, 1);
+			}
+		}
+	}
+	if ( !IS_RUNNING_ON_SIMULATOR() ) {
+		if ( xmit_count ) {
+			extern int l1_serial_out(char *, int);
+			(void)l1_serial_out((char *)start, xmit_count);
+		}
+	}
+}
+
+/*
+ *	Receive character from the serial port
+ */
+static int
+l1_cons_serial_console_wait_key(struct console *co)
+{
+	static struct async_struct *info;
+	int c;
+	void l1_connect_intr(void *, void *);
+	void l1_unconnect_intr(void);
+
+	info =3D &async_sgiconsole;
+
+	/* Turn off callback usage */
+	if ( !(IS_RUNNING_ON_SIMULATOR()) )
+		l1_unconnect_intr();
+
+	while ((serial_in(info, REG_LSR) & LSR_RCA) =3D 0)
+			;
+	c =3D serial_in(info, L1_REG_DAT);
+
+	if ( !(IS_RUNNING_ON_SIMULATOR()) )
+		l1_connect_intr((void *)l1_cons_interrupt, (void *)l1_cons_interrupt);
+
+	return c;
+}
+
+static kdev_t
+l1_cons_serial_console_device(struct console *c)
+{
+	return MKDEV(TTY_MAJOR, 64 + c->index);
+}
+
+/*
+ *	Setup initial baud/bits/parity. We do two things here:
+ *	- construct a cflag setting for the first l1_cons_open()
+ *	- initialize the serial port
+ *	Return non-zero if we didn't find a serial port.
+ */
+static int __init
+l1_cons_serial_console_setup(struct console *co, char *options)
+{
+	static struct async_struct *info;
+	struct serial_state *state;
+	unsigned cval;
+	int	baud =3D 9600;
+	int	bits =3D 8;
+	int	parity =3D 'n';
+	int	cflag =3D CREAD | HUPCL | CLOCAL;
+	int	quot =3D 0;
+	char	*s;
+
+/*
+ * Finally, I am trying for the l1_table to be exported, so that arch code
+ * can set the different fields in here. Without that, compile time knowle=
dge=20
+ * is used to set port addresses, which is not possible on SN1. If this do=
es
+ * not happen, we might want to do this via serial.h as before.
+ * Before, I used to encoded in the IO_SWIZ_BASE into the port address,
+ * so that check_region() on ioport_resource worked. serial_in/out had been
+ * properly hacked up to handle this port address. Currently, we put the
+ * serial port in io_mem mode, so check_region() does not happen, and we
+ * can remove the SN1 hacks from serial_in/out.
+ * Operate ttyS0 at irq=3D0, ie polled mode, else when users start using /=
dev/
+ * console, the serial driver had to be hacked to do more frequent polling
+ * (not sure why, maybe SN1 was not allowing in serial intrs).=20
+ *							Kanoj
+ */
+	extern u64 master_node_bedrock_address;
+
+	memset(l1_table, 0, sizeof(struct serial_state)*RS_TABLE_SIZE);
+	l1_table[0].magic =3D 0;
+	l1_table[0].baud_base =3D 124800;
+	l1_table[0].port =3D 0;
+	l1_table[0].irq =3D 0;
+	l1_table[0].io_type =3D SERIAL_IO_MEM;
+	l1_table[0].flags =3D (ASYNC_BOOT_AUTOCONF | ASYNC_SKIP_TEST);
+#if defined(CONFIG_IA64_SGI_SN2)
+	l1_table[0].iomem_base =3D (u8 *)master_node_bedrock_address;
+#else
+	l1_table[0].iomem_base =3D (u8 *)(master_node_bedrock_address + 0x80);
+#endif
+	l1_table[0].iomem_reg_shift =3D 3;
+	if (options) {
+		baud =3D simple_strtoul(options, NULL, 10);
+		s =3D options;
+		while(*s >=3D '0' && *s <=3D '9')
+			s++;
+		if (*s) parity =3D *s++;
+		if (*s) bits   =3D *s - '0';
+	}
+
+	/*
+	 *	Now construct a cflag setting.
+	 */
+	switch(baud) {
+		case 1200:
+			cflag |=3D B1200;
+			break;
+		case 2400:
+			cflag |=3D B2400;
+			break;
+		case 4800:
+			cflag |=3D B4800;
+			break;
+		case 19200:
+			cflag |=3D B19200;
+			break;
+		case 38400:
+			cflag |=3D B38400;
+			break;
+		case 57600:
+			cflag |=3D B57600;
+			break;
+		case 115200:
+			cflag |=3D B115200;
+			break;
+		case 9600:
+		default:
+			cflag |=3D B9600;
+			break;
+	}
+	switch(bits) {
+		case 7:
+			cflag |=3D CS7;
+			break;
+		default:
+		case 8:
+			cflag |=3D CS8;
+			break;
+	}
+	switch(parity) {
+		case 'o': case 'O':
+			cflag |=3D PARODD;
+			break;
+		case 'e': case 'E':
+			cflag |=3D PARENB;
+			break;
+	}
+	co->cflag =3D cflag;
+
+	/*
+	 *	Divisor, bytesize and parity
+	 */
+	state =3D l1_table + co->index;
+	info =3D &async_sgiconsole;
+	info->magic =3D SERIAL_MAGIC;
+	info->state =3D state;
+	info->port =3D state->port;
+	info->flags =3D state->flags;
+	info->io_type =3D state->io_type;
+	info->iomem_base =3D state->iomem_base;
+	info->iomem_reg_shift =3D state->iomem_reg_shift;
+	quot =3D state->baud_base / baud;
+	cval =3D cflag & (CSIZE | CSTOPB);
+
+	cval >>=3D 4;
+	if (cflag & PARENB)
+		cval |=3D LCR_PAREN;
+	if (!(cflag & PARODD))
+		cval |=3D LCR_PAREVN;
+
+	/*
+	 *	Disable UART interrupts, set DTR and RTS high
+	 *	and set speed.
+	 */
+#ifndef L1_SET_BAUD
+	serial_out(info, REG_LCR, cval | LCR_DLAB);	/* set DLAB */
+	serial_out(info, REG_DLL, quot & 0xff);	/* LS of divisor */
+	serial_out(info, REG_DLH, quot >> 8);		/* MS of divisor */
+	serial_out(info, REG_LCR, cval);		/* reset DLAB */
+#else
+	{
+		void l1_set_baud(int);
+		l1_set_baud(baud);
+	}
+#endif	/* L1_SET_BAUD */
+
+#if defined(CONFIG_KDB)
+	/*
+	 * Remember the line number of the first serial
+	 * console.  We'll make this the kdb serial console too.
+	 */
+	if (kdb_serial_line =3D -1) {
+		kdb_serial_line =3D co->index;
+		kdb_port =3D state->port;
+	}
+#endif	/* CONFIG_KDB */
+
+	return 0;
+}
+
+static struct console sgiconsole =3D {
+	name:		"ttyS",
+	write:		l1_cons_serial_console_write,
+	device:		l1_cons_serial_console_device,
+	wait_key:	l1_cons_serial_console_wait_key,
+	setup:		l1_cons_serial_console_setup,
+	flags:		CON_PRINTBUFFER,
+	index:		-1,
+};
+
+/*
+ *	Register console.
+ */
+void __init
+sgi_l1_proto_serial_console_init(void)
+{
+	register_console(&sgiconsole);
+}
diff -Naur /dev/null 16i.sn/linux/drivers/sgi/sn/fetchop.c
--- /dev/null	Sat Mar 24 04:37:44 2001
+++ 16i.sn/linux/drivers/sgi/sn/fetchop.c	Sun Dec  2 22:58:29 2001
@@ -0,0 +1,348 @@
+/*
+ * SN1 Platform FetchOp Support
+ *
+ * This file is subject to the terms and conditions of the GNU General Pub=
lic
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2000-2001 Silicon Graphics, Inc. All rights reserved.
+ */
+
+/*
+ * SN1 FetchOp Device Driver
+ *=20
+ * This driver exports the SN fetchop facility to user processes.
+ * Fetchops are atomic memory operations that are implemented in the
+ * memory controller on SGI SN hardware.
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/devfs_fs_kernel.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/proc_fs.h>
+#include <asm/system.h>
+#include <asm/pgtable.h>
+#include <asm/sn/sgi.h>
+#include <asm/sn/addrs.h>
+#include <asm/sn/arch.h>
+#include <asm/sn/fetchop.h>
+#include <asm/sn/arch.h>
+#include <asm/sn/addrs.h>
+#ifdef CONFIG_IA64_SGI_SN1
+#include <asm/sn/sn1/hubmd.h>
+#include <asm/sn/sn1/hubmd_next.h>
+#include <asm/sn/sn1/hubio.h>
+#include <asm/sn/sn1/hubio_next.h>
+#endif
+
+
+#define DRIVER_ID_STR	"SGI Fetchop Device Driver"
+#define REVISION	"1.00"
+
+#define FOPS_PER_PAGE	(PAGE_SIZE/FETCHOP_VAR_SIZE)
+
+static int fetchop_mmap(struct file *file, struct vm_area_struct *vma);
+static int fetchop_release(struct inode *inode, struct file *file);
+
+static struct file_operations fetchop_fops =3D {
+	owner:		THIS_MODULE,
+	mmap:		fetchop_mmap,
+	release:	fetchop_release,
+};
+
+static spinlock_t	fetchop_lock =3D SPIN_LOCK_UNLOCKED;
+static long		fetchop_mapped_pages_limit;
+
+static struct {
+	long	map_count;	/* Number of active mmap's */
+	long	pages_mapped;	/* Number of pages mapped */
+} fetchop_stat;
+
+static struct proc_dir_entry *proc_fetchop;
+
+
+#ifdef CONFIG_IA64_SGI_SN1
+/*
+ * fetchop_flush
+ *
+ * This function is called when a page that has been used for fetchops
+ * is about to be freed. The fetchop cache in the node that owns the
+ * memory must be flushed of any fetchop entries that are contained
+ * in the page about to be freed.
+ *
+ *  NOTE: only SN1 has a fetchop cache
+ */
+void
+fetchop_flush(struct page *page)
+{
+	int 			nasid;
+	md_fandop_cac_stat0_u_t	fop_cache_stat;
+	unsigned long		fop_page_addr;
+	volatile unsigned long	fop_cache_addr;
+	int i;
+
+	fop_page_addr =3D __pa(page_address(page));
+	nasid =3D NASID_GET(fop_page_addr);
+
+	for (i =3D 0; i < 2; i++) {
+		fop_cache_stat.md_fandop_cac_stat0_regval =3D=20
+			REMOTE_HUB_L(nasid, i ? MD_FANDOP_CAC_STAT0 : MD_FANDOP_CAC_STAT1);
+
+		if (!fop_cache_stat.md_fandop_cac_stat0_fld_s.fcs_valid)
+			continue;
+	=09
+		/*
+		 * FANDOP cache is valid. Check if the cached address is
+	 	 * in the page passed in.=20
+	 	 * MD_FANDOP_CAC_STAT register provides node local address.=20
+	 	 * Before comparing with page address generated via pfn,
+		 * update fop_cache_addr to be true physical address.
+		 */
+		fop_cache_addr =3D (fop_cache_stat.md_fandop_cac_stat0_fld_s.fcs_addr
+					<< MFC_ADDR_SHFT);
+		fop_cache_addr =3D TO_NODE(nasid, fop_cache_addr);
+
+		/*
+ 	 	* If cached address is in the same page as pfd,
+	 	* flush it.
+	 	*/
+		if ((fop_cache_addr >=3D fop_page_addr) &&=20
+	    			(fop_cache_addr < (fop_page_addr + PAGE_SIZE)) ) {=20
+	=09
+			/*
+		 	* Get MSPEC address for the cached address, and
+		 	* read from the FLUSH offset.=20
+		 	*/
+			fop_cache_addr =3D TO_NODE_MSPEC(nasid, fop_cache_addr);
+			fop_cache_addr +=3D FETCHOP_CLEAR_CACHE;
+
+			/* Read the flush offset */
+			*(volatile unsigned long *)fop_cache_addr;=20
+		}
+	}
+}
+#else
+#define fetchop_flush(p)
+#endif
+
+
+/*
+ * fetchop_free_pages
+ *
+ * Free all fetchop pages that are linked to a file struct.
+ */
+static int
+fetchop_free_pages(struct page *page)
+{
+	struct page	*next_page;
+	int		count=3D0;
+
+	while (page) {
+		next_page =3D page->next_hash;
+		page->next_hash =3D NULL;
+		fetchop_flush(page);
+		__free_page(page);
+		page =3D next_page;
+		count++;
+	}
+	return count;
+
+}
+
+/*
+ * fetchop_initialize_page
+ *
+ * Initial a page that is about to be used for fetchops.=20
+ * The page must be:
+ *	- zeroed out
+ *	- the protection word for each fetchop must be set to -1 to
+ *	  enable cross node access)
+ *	- the page must be flushed from all caches include L4s.
+ */
+static void
+fetchop_initialize_page(void *addr)
+{
+	long	*p, *pe;
+
+	clear_page(addr);
+	for (p=3D(long*)addr, pe=3Dp+PAGE_SIZE/8; p<pe; p+=3D8)
+		*p =3D 0xffffffffffffffffUL;
+
+	sn_flush_all_caches((long)addr, PAGE_SIZE);
+}
+
+
+/*
+ * fetchop_update_stats
+ *
+ * Update ststistics of the number of fetchop mappings & pages.
+ * If creating a new mapping, ensure that we dont exceed the maximum allow=
ed
+ * number of fetchop pages.
+ */
+static int
+fetchop_update_stats(int mmap, long count)
+{
+	int	ret=3D0;
+
+	spin_lock(&fetchop_lock);
+	if (count > 0 && fetchop_stat.pages_mapped + count > fetchop_mapped_pages=
_limit)  {
+		ret =3D -1;
+	} else {
+		fetchop_stat.map_count +=3D mmap;
+		fetchop_stat.pages_mapped +=3D count;
+	}
+	spin_unlock(&fetchop_lock);
+
+	return ret;
+}
+
+
+/*
+ * fetchop_mmap
+ *
+ * Called when mmaping /dev/fetchop. Creates fetchop pages and map them to
+ * user space.
+ */
+static int
+fetchop_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	unsigned long vm_start;
+	unsigned long mspec_addr;
+	struct page *page;
+
+	if (vma->vm_pgoff !=3D 0)
+		return -EINVAL;
+
+	if ((vma->vm_flags&VM_WRITE) =3D 0)
+		return -EPERM;
+
+	if (fetchop_update_stats(1, (vma->vm_end - vma->vm_start)/PAGE_SIZE) < 0)
+		return -ENOSPC;
+
+	vma->vm_flags |=3D (VM_IO | VM_SHM | VM_LOCKED | VM_NONCACHED);
+	vma->vm_page_prot =3D pgprot_noncached(vma->vm_page_prot);
+	vm_start =3D vma->vm_start;
+
+	while (vm_start < vma->vm_end) {
+		page =3D alloc_page(GFP_USER);
+		if (!page) {
+			fetchop_free_pages(file->private_data);
+			return -ENOMEM;
+		}
+		page->next_hash =3D file->private_data;
+		file->private_data =3D page;
+
+		fetchop_initialize_page(page_address(page));
+		mspec_addr =3D __pa(TO_MSPEC(__pa(page_address(page))));
+=09
+		if (remap_page_range(vm_start, mspec_addr, PAGE_SIZE, vma->vm_page_prot)=
) {
+			fetchop_free_pages(file->private_data);
+			return -EAGAIN;
+		}
+		vm_start +=3D PAGE_SIZE;
+	}
+
+
+	=09
+	return 0;
+}
+
+/*
+ * fetchop_release
+ *
+ * Called when destroying a /dev/fetchop mapping. Frees all
+ * fetchop pages belonging to the file.
+ */
+static int
+fetchop_release(struct inode *inode, struct file *file)
+{
+	int		count;
+
+	count =3D fetchop_free_pages(file->private_data);
+	if (count)
+		fetchop_update_stats(-1, -count);
+
+	return 0;
+}
+
+/*
+ * fetchop_read_proc
+ *
+ * Implements /proc/fetchop. Return statistics about fetchops.
+ */
+static int
+fetchop_read_proc(char *buffer, char **start, off_t off, int count, int *e=
of, void *data)
+{
+	int len =3D 0;
+
+	len +=3D sprintf(buffer + len, "Mappings               : %ld\n", fetchop_=
stat.map_count);
+	len +=3D sprintf(buffer + len, "Current fetchop pages  : %ld\n", fetchop_=
stat.pages_mapped);
+	len +=3D sprintf(buffer + len, "Maximum fetchop pages  : %ld\n", fetchop_=
mapped_pages_limit);
+
+
+	if (len <=3D off+count) *eof =3D 1;
+	*start =3D buffer + off;
+	len   -=3D off;
+	if (len>count) len =3D count;
+	if (len<0) len =3D 0;
+	return len;
+}
+
+static int
+fetchop_write_proc (struct file *file, const char *userbuf, unsigned long =
count, void *data)
+{
+    extern long atoi(char *);
+    char        buf[80];
+
+    if (copy_from_user(buf, userbuf, count < sizeof(buf) ? count : sizeof(=
buf)))
+        return -EFAULT;
+    fetchop_mapped_pages_limit =3D atoi(buf);
+
+    return count;
+}
+
+
+/*
+ * fetchop_init
+ *
+ * Called at boot time to initialize the fetchop facility.
+ */
+int __init
+fetchop_init(void)
+{
+	devfs_handle_t	hnd;
+
+	if (!(hnd=DEvfs_register(NULL, FETCHOP_BASENAME, DEVFS_FL_AUTO_DEVNUM,=20
+			0, 0, S_IFCHR | S_IRUGO | S_IWUGO, &fetchop_fops, NULL))) {
+		printk("%s:  failed to register device\n", DRIVER_ID_STR);
+		return -1;
+	}
+
+	fetchop_mapped_pages_limit =3D num_physpages/100;
+
+	if ((proc_fetchop =3D create_proc_entry(FETCHOP_BASENAME, 0644, NULL)) =
=3D NULL) {
+		printk("%s: unable to create proc entry", DRIVER_ID_STR);
+		return -1;
+	}
+	proc_fetchop->read_proc =3D fetchop_read_proc;
+	proc_fetchop->write_proc =3D fetchop_write_proc;
+
+	printk("%s: v%s\n", DRIVER_ID_STR, REVISION);
+#ifdef BRINGUP
+	{
+		unsigned int maj, minor;
+		devfs_get_maj_min(hnd, &maj, &minor);
+		printk("   maj %d, min %d\n", maj, minor);
+	}
+#endif
+
+	return 0;
+}
+
+module_init(fetchop_init);
+
diff -Naur /dev/null 16i.sn/linux/drivers/sgi/sn/hires_clock.c
--- /dev/null	Sat Mar 24 04:37:44 2001
+++ 16i.sn/linux/drivers/sgi/sn/hires_clock.c	Sun Dec  2 22:58:29 2001
@@ -0,0 +1,119 @@
+/*
+ * SN Platform HiRes Clock Support
+ *
+ * This file is subject to the terms and conditions of the GNU General Pub=
lic
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2000-2001 Silicon Graphics, Inc.  All rights reserved.
+ */
+
+
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/ioctl.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/mm.h>
+#include <linux/devfs_fs_kernel.h>
+#include <asm/sn/addrs.h>
+#include <asm/sn/clksupport.h>
+#include <asm/sn/hires_clock.h>
+
+
+#define DRIVER_ID_STR	"SGI Hi Res Clock Driver"
+#define REVISION	"0.94"
+
+#define CLOCK_BITS	55		/* RT_COUNTER has 55 bits on SN/SN2  */
+
+static int hires_ioctl(struct inode *inode, struct file *file, unsigned in=
t cmd, unsigned long arg);
+static int hires_mmap(struct file *file, struct vm_area_struct *vma);
+
+static int	hires_pico_interval;		/* clock interval in picosec/tick */
+
+static struct file_operations hires_fops =3D {
+	owner:	THIS_MODULE,
+	mmap:	hires_mmap,
+	ioctl:	hires_ioctl,
+};
+
+static int
+hires_ioctl(struct inode *inode, struct file *file, unsigned int cmd, unsi=
gned long arg)
+{
+	int		ret=3D-ENOTTY;
+
+	switch (cmd) {
+		case HIRES_IOCQGETOFFSET:
+			ret =3D (((long)RTC_COUNTER_ADDR) & (PAGE_SIZE-1))/8;
+			break;
+		case HIRES_IOCQGETPICOSEC:
+			ret =3D hires_pico_interval;
+			break;
+		case HIRES_IOCQGETCLOCKBITS:
+			ret =3D CLOCK_BITS;
+			break;
+	}
+	return ret;
+}
+
+
+static int
+hires_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	unsigned long hires_addr;
+
+	if (vma->vm_end - vma->vm_start !=3D PAGE_SIZE)
+		return -EINVAL;
+
+	if (vma->vm_flags&VM_WRITE)
+		return -EPERM;
+
+	vma->vm_flags |=3D (VM_IO | VM_SHM | VM_LOCKED | VM_NONCACHED);
+	vma->vm_page_prot =3D pgprot_noncached(vma->vm_page_prot);
+
+	hires_addr =3D (long)__pa(RTC_COUNTER_ADDR);
+	hires_addr &=3D ~(PAGE_SIZE-1);
+	hires_addr &=3D 0xfffffffffffffffUL;
+=09
+	if (remap_page_range(vma->vm_start, hires_addr, PAGE_SIZE, vma->vm_page_p=
rot)) {
+		printk("SGI Hi Res Clock Driver, failed\n");
+		return -EAGAIN;
+	}
+=09
+
+	return 0;
+}
+
+int __init
+hires_init(void)
+{
+	devfs_handle_t	hnd;
+
+	if (sn_rtc_cycles_per_second < 100000) {
+		printk("%s: unable to determine clock frequency\n", DRIVER_ID_STR);
+		return -1;
+	}
+	hires_pico_interval =3D (1000000000000UL + sn_rtc_cycles_per_second/2) / =
sn_rtc_cycles_per_second;
+
+	if (!(hnd=DEvfs_register(NULL, HIRES_BASENAME, DEVFS_FL_AUTO_DEVNUM,=20
+			0, 0, S_IFCHR | S_IRUGO, &hires_fops, NULL))) {
+		printk("%s: failed to register device\n", DRIVER_ID_STR);
+		return -1;
+	}
+
+	printk("%s: v%s. (%d ns/tick)\n", DRIVER_ID_STR, REVISION, hires_pico_int=
erval/1000);
+#ifdef BRINGUP
+        {
+		unsigned int maj, minor;
+		devfs_get_maj_min(hnd, &maj, &minor);
+		printk("   maj %d, min %d\n", maj, minor);
+	}
+#endif
+
+	return 0;
+}
+
+module_init(hires_init);
+
diff -Naur /dev/null 16i.sn/linux/drivers/sgi/sn/Makefile
--- /dev/null	Sat Mar 24 04:37:44 2001
+++ 16i.sn/linux/drivers/sgi/sn/Makefile	Sun Dec  2 22:58:29 2001
@@ -0,0 +1,21 @@
+#
+# Makefile for the linux kernel.
+#
+# Note! Dependencies are done automagically by 'make dep', which also
+# removes any old dependencies. DON'T put your own dependencies here
+# unless it's something special (ie not a .c file).
+#
+# Note 2! The CFLAGS definitions are now in the main makefile...
+
+EXTRA_CFLAGS    :=3D -DSN -I. -DBRINGUP \
+                   -DNUMA_BASE -DSIMULATED_KLGRAPH \
+		   -DNUMA_MIGR_CONTROL -DLITTLE_ENDIAN
+
+
+O_TARGET  :=3D sn_drivers.a
+
+obj-y 				+obj-$(CONFIG_IA64_SGI_SN) 	+=3D hires_clock.o
+obj-$(CONFIG_IA64_SGI_SN)	+=3D fetchop.o
+
+include $(TOPDIR)/Rules.make
diff -Naur /dev/null 16i.sn/linux/include/asm-ia64/mmzone.h
--- /dev/null	Sat Mar 24 04:37:44 2001
+++ 16i.sn/linux/include/asm-ia64/mmzone.h	Sun Dec  2 22:42:20 2001
@@ -0,0 +1,17 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Pub=
lic
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2001 Silicon Graphics, Inc.  All rights reserved.
+ */
+#ifndef _ASM_IA64_MMZONE_H
+#define _ASM_IA64_MMZONE_H
+
+/*
+ * This will be replaced once new CONFIG_DISCONTIGMEM code is ready to
+ * be accepted into the ia64 code base.
+ */
+#include <asm/sn/mmzone_temp.h>
+
+#endif /* _ASM_IA64_MMZONE_H */

