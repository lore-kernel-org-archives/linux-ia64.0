From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 13 Dec 2002 17:36:53 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.20)
Message-Id: <marc-linux-ia64-105590709805561@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The linux-2.4.20-ia64-021210 patch broke the ski simulator kernel.
The attached additional patch fixes the problem, and also incorporates
the 2.5 simscsi code that auto-detects the simulated disk size, so you
don't need a 1G image.  Note that I also adopted the 2.5 config
symbols.

Sorry for the inconvenience.

Bjorn


diff -u -urN linux-2.4.20-ia64-021210/arch/ia64/config.in linux-ski/arch/ia=
64/config.in
--- linux-2.4.20-ia64-021210/arch/ia64/config.in	2002-12-10 14:23:20.000000=
000 -0700
+++ linux-ski/arch/ia64/config.in	2002-12-13 10:03:28.000000000 -0700
@@ -250,10 +250,10 @@
   mainmenu_option next_comment
   comment 'Simulated drivers'
=20
-  bool 'Simulated Ethernet ' CONFIG_SIMETH
-  bool 'Simulated serial driver support' CONFIG_SIM_SERIAL
+  bool 'Simulated Ethernet ' CONFIG_HP_SIMETH
+  bool 'Simulated serial driver support' CONFIG_HP_SIMSERIAL
   if [ "$CONFIG_SCSI" !=3D "n" ]; then
-    bool 'Simulated SCSI disk' CONFIG_SCSI_SIM
+    bool 'Simulated SCSI disk' CONFIG_HP_SIMSCSI
   fi
   endmenu
 fi
diff -u -urN linux-2.4.20-ia64-021210/arch/ia64/hp/sim/Makefile linux-ski/a=
rch/ia64/hp/sim/Makefile
--- linux-2.4.20-ia64-021210/arch/ia64/hp/sim/Makefile	2002-12-10 14:23:20.=
000000000 -0700
+++ linux-ski/arch/ia64/hp/sim/Makefile	2002-12-13 10:04:07.000000000 -0700
@@ -12,8 +12,4 @@
 obj-y :=3D hpsim_console.o hpsim_irq.o hpsim_setup.o
 obj-$(CONFIG_IA64_GENERIC) +=3D hpsim_machvec.o
=20
-obj-$(CONFIG_HP_SIMETH)	+=3D simeth.o
-obj-$(CONFIG_HP_SIMSERIAL) +=3D simserial.o
-obj-$(CONFIG_HP_SIMSCSI) +=3D simscsi.o
-
 include $(TOPDIR)/Rules.make
diff -u -urN linux-2.4.20-ia64-021210/arch/ia64/hp/sim/simeth.c linux-ski/a=
rch/ia64/hp/sim/simeth.c
--- linux-2.4.20-ia64-021210/arch/ia64/hp/sim/simeth.c	2002-12-10 14:23:20.=
000000000 -0700
+++ linux-ski/arch/ia64/hp/sim/simeth.c	1969-12-31 17:00:00.000000000 -0700
@@ -1,533 +0,0 @@
-/*
- * Simulated Ethernet Driver
- *
- * Copyright (C) 1999-2001 Hewlett-Packard Co
- * Copyright (C) 1999-2001 Stephane Eranain <eranian@hpl.hp.com>
- */
-#include <linux/config.h>
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/types.h>
-#include <linux/in.h>
-#include <linux/string.h>
-#include <linux/init.h>
-#include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/inetdevice.h>
-#include <linux/if_ether.h>
-#include <linux/if_arp.h>
-#include <linux/skbuff.h>
-#include <linux/notifier.h>
-#include <asm/bitops.h>
-#include <asm/system.h>
-#include <asm/irq.h>
-
-#define SIMETH_RECV_MAX	10
-
-/*
- * Maximum possible received frame for Ethernet.
- * We preallocate an sk_buff of that size to avoid costly=20
- * memcpy for temporary buffer into sk_buff. We do basically
- * what's done in other drivers, like eepro with a ring.
- * The difference is, of course, that we don't have real DMA !!!
- */
-#define SIMETH_FRAME_SIZE	ETH_FRAME_LEN=09
-
-
-#define SSC_NETDEV_PROBE		100
-#define SSC_NETDEV_SEND			101
-#define SSC_NETDEV_RECV			102
-#define SSC_NETDEV_ATTACH		103
-#define SSC_NETDEV_DETACH		104
-
-#define NETWORK_INTR			8
-
-struct simeth_local {
-	struct net_device_stats stats;
-	int 			simfd;	 /* descriptor in the simulator */
-};
-
-static int simeth_probe1(void);
-static int simeth_open(struct net_device *dev);
-static int simeth_close(struct net_device *dev);
-static int simeth_tx(struct sk_buff *skb, struct net_device *dev);
-static int simeth_rx(struct net_device *dev);
-static struct net_device_stats *simeth_get_stats(struct net_device *dev);
-static void simeth_interrupt(int irq, void *dev_id, struct pt_regs * regs);
-static void set_multicast_list(struct net_device *dev);
-static int simeth_device_event(struct notifier_block *this,unsigned long e=
vent, void *ptr);
-
-static char *simeth_version=3D"0.3";
-
-/*
- * This variable is used to establish a mapping between the Linux/ia64 ker=
nel
- * and the host linux kernel.
- *
- * As of today, we support only one card, even though most of the code
- * is ready for many more. The mapping is then:
- *	linux/ia64 -> linux/x86
- * 	   eth0    -> eth1
- *
- * In the future, we some string operations, we could easily support up
- * to 10 cards (0-9).
- *
- * The default mapping can be changed on the kernel command line by
- * specifying simeth=3DethX (or whatever string you want).
- */
-static char *simeth_device=3D"eth0";	 /* default host interface to use */
-
-
-
-static volatile unsigned int card_count; /* how many cards "found" so far =
*/
-static int simeth_debug;		/* set to 1 to get debug information */
-
-/*
- * Used to catch IFF_UP & IFF_DOWN events
- */
-static struct notifier_block simeth_dev_notifier =3D {
-	simeth_device_event,
-	0
-};
-
-
-/*
- * Function used when using a kernel command line option.
- *
- * Format: simeth=3Dinterface_name (like eth0)
- */
-static int __init
-simeth_setup(char *str)
-{
-	simeth_device =3D str;
-	return 1;
-}
-
-__setup("simeth=3D", simeth_setup);
-
-/*
- * Function used to probe for simeth devices when not installed
- * as a loadable module
- */
-
-int __init
-simeth_probe (void)
-{
-	int r;
-
-	printk("simeth: v%s\n", simeth_version);
-
-	r =3D simeth_probe1();
-
-	if (r =3D 0) register_netdevice_notifier(&simeth_dev_notifier);
-
-	return r;
-}
-
-extern long ia64_ssc (long, long, long, long, int);
-extern void ia64_ssc_connect_irq (long intr, long irq);
-
-static inline int
-netdev_probe(char *name, unsigned char *ether)
-{
-	return ia64_ssc(__pa(name), __pa(ether), 0,0, SSC_NETDEV_PROBE);
-}
-
-
-static inline int
-netdev_connect(int irq)
-{
-	/* XXX Fix me
-	 * this does not support multiple cards
-	 * also no return value
-	 */
-	ia64_ssc_connect_irq(NETWORK_INTR, irq);
-	return 0;
-}
-
-static inline int
-netdev_attach(int fd, int irq, unsigned int ipaddr)
-{
-	/* this puts the host interface in the right mode (start interupting) */
-	return ia64_ssc(fd, ipaddr, 0,0, SSC_NETDEV_ATTACH);
-}
-
-
-static inline int
-netdev_detach(int fd)
-{
-	/*
-	 * inactivate the host interface (don't interrupt anymore) */
-	return ia64_ssc(fd, 0,0,0, SSC_NETDEV_DETACH);
-}
-
-static inline int
-netdev_send(int fd, unsigned char *buf, unsigned int len)
-{
-	return ia64_ssc(fd, __pa(buf), len, 0, SSC_NETDEV_SEND);
-}
-
-static inline int
-netdev_read(int fd, unsigned char *buf, unsigned int len)
-{
-	return ia64_ssc(fd, __pa(buf), len, 0, SSC_NETDEV_RECV);
-}
-
-/*
- * Function shared with module code, so cannot be in init section
- *
- * So far this function "detects" only one card (test_&_set) but could=20
- * be extended easily.
- *
- * Return:
- * 	- -ENODEV is no device found
- *	- -ENOMEM is no more memory
- *	- 0 otherwise
- */
-static int
-simeth_probe1(void)
-{
-	unsigned char mac_addr[ETH_ALEN];
-	struct simeth_local *local;
-	struct net_device *dev;
-	int fd, i;
-
-	/*
-	 * XXX Fix me
-	 * let's support just one card for now
-	 */
-	if (test_and_set_bit(0, &card_count))
-		return -ENODEV;
-
-	/*
-	 * check with the simulator for the device
-	 */
-	fd =3D netdev_probe(simeth_device, mac_addr);
-	if (fd =3D -1)
-		return -ENODEV;
-
-	dev =3D init_etherdev(NULL, sizeof(struct simeth_local));
-	if (!dev)
-		return -ENOMEM;
-
-	memcpy(dev->dev_addr, mac_addr, sizeof(mac_addr));
-
-	dev->irq =3D ia64_alloc_vector();
-
-	/*
-	 * attach the interrupt in the simulator, this does enable interrupts
-	 * until a netdev_attach() is called
-	 */
-	netdev_connect(dev->irq);
-
-	memset(dev->priv, 0, sizeof(struct simeth_local));
-
-	local =3D dev->priv;
-	local->simfd =3D fd; /* keep track of underlying file descriptor */
-
-	dev->open		=3D simeth_open;
-	dev->stop		=3D simeth_close;
-	dev->hard_start_xmit	=3D simeth_tx;
-	dev->get_stats		=3D simeth_get_stats;
-	dev->set_multicast_list =3D set_multicast_list; /* no yet used */
-
-	/* Fill in the fields of the device structure with ethernet-generic value=
s. */
-	ether_setup(dev);
-
-	printk("%s: hosteth=3D%s simfd=3D%d, HwAddr", dev->name, simeth_device, l=
ocal->simfd);
-	for(i =3D 0; i < ETH_ALEN; i++) {
-		printk(" %2.2x", dev->dev_addr[i]);
-	}
-	printk(", IRQ %d\n", dev->irq);
-
-		return 0;
-}
-
-/*
- * actually binds the device to an interrupt vector
- */
-static int
-simeth_open(struct net_device *dev)
-{
-	if (request_irq(dev->irq, simeth_interrupt, 0, "simeth", dev)) {
-		printk ("simeth: unable to get IRQ %d.\n", dev->irq);
-		return -EAGAIN;
-	}
-
-	netif_start_queue(dev);
-
-	return 0;
-}
-
-/* copied from lapbether.c */
-static __inline__ int dev_is_ethdev(struct net_device *dev)
-{
-       return ( dev->type =3D ARPHRD_ETHER && strncmp(dev->name, "dummy", =
5));
-}
-
-
-/*
- * Handler for IFF_UP or IFF_DOWN
- *
- * The reason for that is that we don't want to be interrupted when the
- * interface is down. There is no way to unconnect in the simualtor. Inste=
ad
- * we use this function to shutdown packet processing in the frame filter =

- * in the simulator. Thus no interrupts are generated
- *
- *
- * That's also the place where we pass the IP address of this device to the
- * simulator so that that we can start filtering packets for it
- *
- * There may be a better way of doing this, but I don't know which yet.
- */
-static int
-simeth_device_event(struct notifier_block *this,unsigned long event, void =
*ptr)
-{
-	struct net_device *dev =3D (struct net_device *)ptr;
-	struct simeth_local *local;
-	struct in_device *in_dev;
-	struct in_ifaddr **ifap =3D NULL;
-	struct in_ifaddr *ifa =3D NULL;
-	int r;
-
-
-	if ( ! dev ) {
-		printk(KERN_WARNING "simeth_device_event dev=3D0\n");
-		return NOTIFY_DONE;
-	}
-
-	if ( event !=3D NETDEV_UP && event !=3D NETDEV_DOWN ) return NOTIFY_DONE;
-
-	/*
-	 * Check whether or not it's for an ethernet device
-	 *
-	 * XXX Fixme: This works only as long as we support one
-	 * type of ethernet device.
-	 */
-	if ( !dev_is_ethdev(dev) ) return NOTIFY_DONE;
-
-	if ((in_dev=DEv->ip_ptr) !=3D NULL) {
-		for (ifap=3D&in_dev->ifa_list; (ifa=3D*ifap) !=3D NULL; ifap=3D&ifa->ifa=
_next)
-			if (strcmp(dev->name, ifa->ifa_label) =3D 0) break;
-	}
-	if ( ifa =3D NULL ) {
-		printk("simeth_open: can't find device %s's ifa\n", dev->name);
-		return NOTIFY_DONE;
-	}
-
-	printk("simeth_device_event: %s ipaddr=3D0x%x\n", dev->name, htonl(ifa->i=
fa_local));
-
-	/*
-	 * XXX Fix me
-	 * if the device was up, and we're simply reconfiguring it, not sure
-	 * we get DOWN then UP.
-	 */
-
-	local =3D dev->priv;
-	/* now do it for real */
-	r =3D event =3D NETDEV_UP ?=20
-		netdev_attach(local->simfd, dev->irq, htonl(ifa->ifa_local)):
-		netdev_detach(local->simfd);
-
-	printk("simeth: netdev_attach/detach: event=3D%s ->%d\n", event =3D NETDE=
V_UP ? "attach":"detach", r);
-
-	return NOTIFY_DONE;
-}
-
-static int
-simeth_close(struct net_device *dev)
-{
-	netif_stop_queue(dev);
-
-	free_irq(dev->irq, dev);
-
-	return 0;
-}
-
-/*
- * Only used for debug
- */
-static void
-frame_print(unsigned char *from, unsigned char *frame, int len)
-{
-	int i;
-
-	printk("%s: (%d) %02x", from, len, frame[0] & 0xff);
-	for(i=3D1; i < 6; i++ ) {
-		printk(":%02x", frame[i] &0xff);
-	}
-	printk(" %2x", frame[6] &0xff);
-	for(i=3D7; i < 12; i++ ) {
-		printk(":%02x", frame[i] &0xff);
-	}
-	printk(" [%02x%02x]\n", frame[12], frame[13]);
-
-	for(i=14; i < len; i++ ) {
-		printk("%02x ", frame[i] &0xff);
-		if ( (i%10)=3D0) printk("\n");
-	}
-	printk("\n");
-}
-
-
-/*
- * Function used to transmit of frame, very last one on the path before
- * going to the simulator.
- */
-static int
-simeth_tx(struct sk_buff *skb, struct net_device *dev)
-{
-	struct simeth_local *local =3D (struct simeth_local *)dev->priv;
-
-#if 0
-	/* ensure we have at least ETH_ZLEN bytes (min frame size) */
-	unsigned int length =3D ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
-	/* Where do the extra padding bytes comes from inthe skbuff ? */
-#else
-	/* the real driver in the host system is going to take care of that
-	 * or maybe it's the NIC itself.
-	 */
-	unsigned int length =3D skb->len;
-#endif
-
-	local->stats.tx_bytes +=3D skb->len;
-	local->stats.tx_packets++;
-
-
-	if (simeth_debug > 5) frame_print("simeth_tx", skb->data, length);
-
-	netdev_send(local->simfd, skb->data, length);
-
-	/*
-	 * we are synchronous on write, so we don't simulate a
-	 * trasnmit complete interrupt, thus we don't need to arm a tx
-	 */
-
-	dev_kfree_skb(skb);
-	return 0;
-}
-
-static inline struct sk_buff *=20
-make_new_skb(struct net_device *dev)
-{
-	struct sk_buff *nskb;
-
-	/*
-	 * The +2 is used to make sure that the IP header is nicely
-	 * aligned (on 4byte boundary I assume 14+2=16)
-	 */
-	nskb =3D dev_alloc_skb(SIMETH_FRAME_SIZE + 2);
-	if ( nskb =3D NULL ) {
-		printk(KERN_NOTICE "%s: memory squeeze. dropping packet.\n", dev->name);
-		return NULL;
-	}
-	nskb->dev =3D dev;
-
-	skb_reserve(nskb, 2);	/* Align IP on 16 byte boundaries */
-
-	skb_put(nskb,SIMETH_FRAME_SIZE);
-
-	return nskb;
-}
-
-/*
- * called from interrupt handler to process a received frame
- */
-static int
-simeth_rx(struct net_device *dev)
-{
-	struct simeth_local	*local;
-	struct sk_buff		*skb;
-	int			len;
-	int			rcv_count =3D SIMETH_RECV_MAX;
-
-	local =3D (struct simeth_local *)dev->priv;
-	/*
-	 * the loop concept has been borrowed from other drivers
-	 * looks to me like it's a throttling thing to avoid pushing to many
-	 * packets at one time into the stack. Making sure we can process them
-	 * upstream and make forward progress overall
-	 */
-	do {=20
-		if ( (skb=3Dmake_new_skb(dev)) =3D NULL ) {
-			printk(KERN_NOTICE "%s: memory squeeze. dropping packet.\n", dev->name);
-			local->stats.rx_dropped++;
-			return 0;
-		}
-		/*
-		 * Read only one frame at a time
-		 */
-		len =3D netdev_read(local->simfd, skb->data, SIMETH_FRAME_SIZE);
-		if ( len =3D 0 ) {
-			if ( simeth_debug > 0 ) printk(KERN_WARNING "%s: count=3D%d netdev_read=
=3D0\n", dev->name, SIMETH_RECV_MAX-rcv_count);
-			break;
-		}
-#if 0
-		/*
-		 * XXX Fix me
-		 * Should really do a csum+copy here
-		 */
-		memcpy(skb->data, frame, len);
-#endif
-		skb->protocol =3D eth_type_trans(skb, dev);
-
-		if ( simeth_debug > 6 ) frame_print("simeth_rx", skb->data, len);
-
-		/*
-		 * push the packet up & trigger software interrupt
-		 */
-		netif_rx(skb);
-
-		local->stats.rx_packets++;
-		local->stats.rx_bytes +=3D len;
-
-	} while ( --rcv_count );
-
-	return len; /* 0 =3D nothing left to read, otherwise, we can try again */
-}
-
-/*
- * Interrupt handler (Yes, we can do it too !!!)
- */
-static void
-simeth_interrupt(int irq, void *dev_id, struct pt_regs * regs)
-{
-	struct net_device *dev =3D dev_id;
-
-	if ( dev =3D NULL ) {
-		printk(KERN_WARNING "simeth: irq %d for unknown device\n", irq);
-		return;
-	}
-
-	/*
-	 * very simple loop because we get interrupts only when receving
-	 */
-	while (simeth_rx(dev));
-}
-
-static struct net_device_stats *
-simeth_get_stats(struct net_device *dev)
-{
-	struct simeth_local  *local =3D (struct simeth_local *) dev->priv;
-
-	return &local->stats;
-}
-
-/* fake multicast ability */
-static void
-set_multicast_list(struct net_device *dev)
-{
-	printk(KERN_WARNING "%s: set_multicast_list called\n", dev->name);
-}
-
-#ifdef CONFIG_NET_FASTROUTE
-static int
-simeth_accept_fastpath(struct net_device *dev, struct dst_entry *dst)
-{
-	printk(KERN_WARNING "%s: simeth_accept_fastpath called\n", dev->name);
-	return -1;
-}
-#endif
-
-__initcall(simeth_probe);
diff -u -urN linux-2.4.20-ia64-021210/arch/ia64/hp/sim/simscsi.c linux-ski/=
arch/ia64/hp/sim/simscsi.c
--- linux-2.4.20-ia64-021210/arch/ia64/hp/sim/simscsi.c	2002-12-10 14:23:20=
.000000000 -0700
+++ linux-ski/arch/ia64/hp/sim/simscsi.c	1969-12-31 17:00:00.000000000 -0700
@@ -1,384 +0,0 @@
-/*
- * Simulated SCSI driver.
- *
- * Copyright (C) 1999, 2001 Hewlett-Packard Co
- * Copyright (C) 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
- *
- * 99/12/18 David Mosberger	Added support for READ10/WRITE10 needed by lin=
ux v2.3.33
- */
-#include <linux/config.h>
-#include <linux/blk.h>
-#include <linux/init.h>
-#include <linux/interrupt.h>
-#include <linux/kernel.h>
-#include <linux/timer.h>
-
-#include <scsi/scsi.h>
-
-#include <asm/irq.h>
-
-#include "scsi.h"
-#include "sd.h"
-#include "hosts.h"
-#include "simscsi.h"
-
-#define DEBUG_SIMSCSI	1
-
-/* Simulator system calls: */
-
-#define SSC_OPEN			50
-#define SSC_CLOSE			51
-#define SSC_READ			52
-#define SSC_WRITE			53
-#define SSC_GET_COMPLETION		54
-#define SSC_WAIT_COMPLETION		55
-
-#define SSC_WRITE_ACCESS		2
-#define SSC_READ_ACCESS			1
-
-#ifdef DEBUG_SIMSCSI
-  int simscsi_debug;
-# define DBG	simscsi_debug
-#else
-# define DBG	0
-#endif
-
-#if 0
-struct timer_list disk_timer;
-#else
-static void simscsi_interrupt (unsigned long val);
-DECLARE_TASKLET(simscsi_tasklet, simscsi_interrupt, 0);
-#endif
-
-struct disk_req {
-	unsigned long addr;
-	unsigned len;
-};
-
-struct disk_stat {
-	int fd;
-	unsigned count;
-};
-
-extern long ia64_ssc (long arg0, long arg1, long arg2, long arg3, int nr);
-
-static int desc[8] =3D { -1, -1, -1, -1, -1, -1, -1, -1 };
-
-static struct queue_entry {
-	Scsi_Cmnd *sc;
-} queue[SIMSCSI_REQ_QUEUE_LEN];
-
-static int rd, wr;
-static atomic_t num_reqs =3D ATOMIC_INIT(0);
-
-/* base name for default disks */
-static char *simscsi_root =3D DEFAULT_SIMSCSI_ROOT;
-
-#define MAX_ROOT_LEN	128
-
-/*
- * used to setup a new base for disk images
- * to use /foo/bar/disk[a-z] as disk images
- * you have to specify simscsi=3D/foo/bar/disk on the command line
- */
-static int __init
-simscsi_setup (char *s)
-{
-	/* XXX Fix me we may need to strcpy() ? */
-	if (strlen(s) > MAX_ROOT_LEN) {
-		printk("simscsi_setup: prefix too long---using default %s\n", simscsi_ro=
ot);
-	}
-	simscsi_root =3D s;
-	return 1;
-}
-
-__setup("simscsi=3D", simscsi_setup);
-
-static void
-simscsi_interrupt (unsigned long val)
-{
-	unsigned long flags;
-	Scsi_Cmnd *sc;
-
-	spin_lock_irqsave(&io_request_lock, flags);
-	{
-		while ((sc =3D queue[rd].sc) !=3D 0) {
-			atomic_dec(&num_reqs);
-			queue[rd].sc =3D 0;
-			if (DBG)
-				printk("simscsi_interrupt: done with %ld\n", sc->serial_number);
-			(*sc->scsi_done)(sc);
-			rd =3D (rd + 1) % SIMSCSI_REQ_QUEUE_LEN;
-		}
-	}
-	spin_unlock_irqrestore(&io_request_lock, flags);
-}
-
-int
-simscsi_detect (Scsi_Host_Template *templ)
-{
-	templ->proc_name =3D "simscsi";
-#if 0
-	init_timer(&disk_timer);
-	disk_timer.function =3D simscsi_interrupt;
-#endif
-	return 1;	/* fake one SCSI host adapter */
-}
-
-int
-simscsi_release (struct Scsi_Host *host)
-{
-	return 0;	/* this is easy...  */
-}
-
-const char *
-simscsi_info (struct Scsi_Host *host)
-{
-	return "simulated SCSI host adapter";
-}
-
-int
-simscsi_abort (Scsi_Cmnd *cmd)
-{
-	printk ("simscsi_abort: unimplemented\n");
-	return SCSI_ABORT_SUCCESS;
-}
-
-int
-simscsi_reset (Scsi_Cmnd *cmd, unsigned int reset_flags)
-{
-	printk ("simscsi_reset: unimplemented\n");
-	return SCSI_RESET_SUCCESS;
-}
-
-int
-simscsi_biosparam (Disk *disk, kdev_t n, int ip[])
-{
-	int size =3D disk->capacity;
-
-	ip[0] =3D 64;
-	ip[1] =3D 32;
-	ip[2] =3D size >> 11;
-	return 0;
-}
-
-static void
-simscsi_readwrite (Scsi_Cmnd *sc, int mode, unsigned long offset, unsigned=
 long len)
-{
-	struct disk_stat stat;
-	struct disk_req req;
-
-	req.addr =3D __pa(sc->request_buffer);
-	req.len  =3D len;			/* # of bytes to transfer */
-
-	if (sc->request_bufflen < req.len)
-		return;
-
-	stat.fd =3D desc[sc->target];
-	if (DBG)
-		printk("simscsi_%s @ %lx (off %lx, len %lu) ->",
-		       mode =3D SSC_READ ? "read":"write", req.addr, offset, len);
-	ia64_ssc(stat.fd, 1, __pa(&req), offset, mode);
-	ia64_ssc(__pa(&stat), 0, 0, 0, SSC_WAIT_COMPLETION);
-
-	if (stat.count =3D req.len) {
-		sc->result =3D GOOD;
-	} else {
-		sc->result =3D DID_ERROR << 16;
-	}
-	if (DBG)
-		printk("%d\n", sc->result);
-}
-
-static void
-simscsi_sg_readwrite (Scsi_Cmnd *sc, int mode, unsigned long offset)
-{
-	int list_len =3D sc->use_sg;
-	struct scatterlist *sl =3D (struct scatterlist *)sc->buffer;
-	struct disk_stat stat;
-	struct disk_req req;
-
-	stat.fd =3D desc[sc->target];
-
-	while (list_len) {
-		req.addr =3D __pa(sl->address);
-		req.len  =3D sl->length;
-		if (DBG)
-			printk("simscsi_sg_%s @ %lx (off %lx) use_sg=3D%d len=3D%d\n",
-			       mode =3D SSC_READ ? "read":"write", req.addr, offset,
-			       list_len, sl->length);
-		ia64_ssc(stat.fd, 1, __pa(&req), offset, mode);
-		ia64_ssc(__pa(&stat), 0, 0, 0, SSC_WAIT_COMPLETION);
-
-		/* should not happen in our case */
-		if (stat.count !=3D req.len) {
-			sc->result =3D DID_ERROR << 16;
-			return;
-		}
-		offset +=3D  sl->length;
-		sl++;
-		list_len--;
-	}
-	sc->result =3D GOOD;
-}
-
-/*
- * function handling both READ_6/WRITE_6 (non-scatter/gather mode)
- * commands.
- * Added 02/26/99 S.Eranian
- */
-static void
-simscsi_readwrite6 (Scsi_Cmnd *sc, int mode)
-{
-	unsigned long offset;
-
-	offset =3D (((sc->cmnd[1] & 0x1f) << 16) | (sc->cmnd[2] << 8) | sc->cmnd[=
3])*512;
-	if (sc->use_sg > 0)
-		simscsi_sg_readwrite(sc, mode, offset);
-	else
-		simscsi_readwrite(sc, mode, offset, sc->cmnd[4]*512);
-}
-
-
-static void
-simscsi_readwrite10 (Scsi_Cmnd *sc, int mode)
-{
-	unsigned long offset;
-
-	offset =3D (  (sc->cmnd[2] << 24) | (sc->cmnd[3] << 16)
-		  | (sc->cmnd[4] <<  8) | (sc->cmnd[5] <<  0))*512;
-	if (sc->use_sg > 0)
-		simscsi_sg_readwrite(sc, mode, offset);
-	else
-		simscsi_readwrite(sc, mode, offset, ((sc->cmnd[7] << 8) | sc->cmnd[8])*5=
12);
-}
-
-int
-simscsi_queuecommand (Scsi_Cmnd *sc, void (*done)(Scsi_Cmnd *))
-{
-	char fname[MAX_ROOT_LEN+16];
-	char *buf;
-#if DEBUG_SIMSCSI
-	register long sp asm ("sp");
-
-	if (DBG)
-		printk("simscsi_queuecommand: target=3D%d,cmnd=3D%u,sc=3D%lu,sp=3D%lx,do=
ne=3D%p\n",
-		       sc->target, sc->cmnd[0], sc->serial_number, sp, done);
-#endif
-
-	sc->result =3D DID_BAD_TARGET << 16;
-	sc->scsi_done =3D done;
-	if (sc->target <=3D 7 && sc->lun =3D 0) {
-		switch (sc->cmnd[0]) {
-		      case INQUIRY:
-			if (sc->request_bufflen < 35) {
-				break;
-			}
-			sprintf (fname, "%s%c", simscsi_root, 'a' + sc->target);
-			desc[sc->target] =3D ia64_ssc (__pa(fname), SSC_READ_ACCESS|SSC_WRITE_A=
CCESS,
-						     0, 0, SSC_OPEN);
-			if (desc[sc->target] < 0) {
-				/* disk doesn't exist... */
-				break;
-			}
-			buf =3D sc->request_buffer;
-			buf[0] =3D 0;	/* magnetic disk */
-			buf[1] =3D 0;	/* not a removable medium */
-			buf[2] =3D 2;	/* SCSI-2 compliant device */
-			buf[3] =3D 2;	/* SCSI-2 response data format */
-			buf[4] =3D 31;	/* additional length (bytes) */
-			buf[5] =3D 0;	/* reserved */
-			buf[6] =3D 0;	/* reserved */
-			buf[7] =3D 0;	/* various flags */
-			memcpy(buf + 8, "HP      SIMULATED DISK  0.00",  28);
-			sc->result =3D GOOD;
-			break;
-
-		      case TEST_UNIT_READY:
-			sc->result =3D GOOD;
-			break;
-
-		      case READ_6:
-			if (desc[sc->target] < 0 )
-				break;
-			simscsi_readwrite6(sc, SSC_READ);
-			break;
-
-		      case READ_10:
-			if (desc[sc->target] < 0 )
-				break;
-			simscsi_readwrite10(sc, SSC_READ);
-			break;
-
-		      case WRITE_6:
-			if (desc[sc->target] < 0)
-				break;
-			simscsi_readwrite6(sc, SSC_WRITE);
-			break;
-
-		      case WRITE_10:
-			if (desc[sc->target] < 0)
-				break;
-			simscsi_readwrite10(sc, SSC_WRITE);
-			break;
-
-
-		      case READ_CAPACITY:
-			if (desc[sc->target] < 0 || sc->request_bufflen < 8) {
-				break;
-			}
-			buf =3D sc->request_buffer;
-
-			/* pretend to be a 1GB disk (partition table contains real stuff): */
-			buf[0] =3D 0x00;
-			buf[1] =3D 0x1f;
-			buf[2] =3D 0xff;
-			buf[3] =3D 0xff;
-			/* set block size of 512 bytes: */
-			buf[4] =3D 0;
-			buf[5] =3D 0;
-			buf[6] =3D 2;
-			buf[7] =3D 0;
-			sc->result =3D GOOD;
-			break;
-
-		      case MODE_SENSE:
-			printk("MODE_SENSE\n");
-			break;
-
-		      case START_STOP:
-			printk("START_STOP\n");
-			break;
-
-		      default:
-			panic("simscsi: unknown SCSI command %u\n", sc->cmnd[0]);
-		}
-	}
-	if (sc->result =3D DID_BAD_TARGET) {
-		sc->result |=3D DRIVER_SENSE << 24;
-		sc->sense_buffer[0] =3D 0x70;
-		sc->sense_buffer[2] =3D 0x00;
-	}
-	if (atomic_read(&num_reqs) >=3D SIMSCSI_REQ_QUEUE_LEN) {
-		panic("Attempt to queue command while command is pending!!");
-	}
-	atomic_inc(&num_reqs);
-	queue[wr].sc =3D sc;
-	wr =3D (wr + 1) % SIMSCSI_REQ_QUEUE_LEN;
-
-#if 0
-	if (!timer_pending(&disk_timer)) {
-		disk_timer.expires =3D jiffies;
-		add_timer(&disk_timer);
-	}
-#else
-	tasklet_schedule(&simscsi_tasklet);
-#endif
-	return 0;
-}
-
-
-static Scsi_Host_Template driver_template =3D SIMSCSI;
-
-#include "scsi_module.c"
diff -u -urN linux-2.4.20-ia64-021210/arch/ia64/hp/sim/simscsi.h linux-ski/=
arch/ia64/hp/sim/simscsi.h
--- linux-2.4.20-ia64-021210/arch/ia64/hp/sim/simscsi.h	2002-12-10 14:23:20=
.000000000 -0700
+++ linux-ski/arch/ia64/hp/sim/simscsi.h	1969-12-31 17:00:00.000000000 -0700
@@ -1,39 +0,0 @@
-/*
- * Simulated SCSI driver.
- *
- * Copyright (C) 1999 Hewlett-Packard Co
- * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
- */
-#ifndef SIMSCSI_H
-#define SIMSCSI_H
-
-#define SIMSCSI_REQ_QUEUE_LEN	64
-
-#define DEFAULT_SIMSCSI_ROOT	"/var/ski-disks/sd"
-
-extern int simscsi_detect (Scsi_Host_Template *);
-extern int simscsi_release (struct Scsi_Host *);
-extern const char *simscsi_info (struct Scsi_Host *);
-extern int simscsi_queuecommand (Scsi_Cmnd *, void (*done)(Scsi_Cmnd *));
-extern int simscsi_abort (Scsi_Cmnd *);
-extern int simscsi_reset (Scsi_Cmnd *, unsigned int);
-extern int simscsi_biosparam (Disk *, kdev_t, int[]);
-
-#define SIMSCSI {					\
-	detect:			simscsi_detect,		\
-	release:		simscsi_release,	\
-	info:			simscsi_info,		\
-	queuecommand:		simscsi_queuecommand,	\
-	abort:			simscsi_abort,		\
-	reset:			simscsi_reset,		\
-	bios_param:		simscsi_biosparam,	\
-	can_queue:		SIMSCSI_REQ_QUEUE_LEN,	\
-	this_id:		-1,			\
-	sg_tablesize:		SG_ALL,			\
-	cmd_per_lun:		SIMSCSI_REQ_QUEUE_LEN,	\
-	present:		0,			\
-	unchecked_isa_dma:	0,			\
-	use_clustering:		DISABLE_CLUSTERING	\
-}
-
-#endif /* SIMSCSI_H */
diff -u -urN linux-2.4.20-ia64-021210/arch/ia64/hp/sim/simserial.c linux-sk=
i/arch/ia64/hp/sim/simserial.c
--- linux-2.4.20-ia64-021210/arch/ia64/hp/sim/simserial.c	2002-12-10 14:23:=
20.000000000 -0700
+++ linux-ski/arch/ia64/hp/sim/simserial.c	1969-12-31 17:00:00.000000000 -0=
700
@@ -1,1095 +0,0 @@
-/*
- * Simulated Serial Driver (fake serial)
- *
- * This driver is mostly used for bringup purposes and will go away.
- * It has a strong dependency on the system console. All outputs
- * are rerouted to the same facility as the one used by printk which, in o=
ur
- * case means sys_sim.c console (goes via the simulator). The code hereaft=
er
- * is completely leveraged from the serial.c driver.
- *
- * Copyright (C) 1999-2000, 2002 Hewlett-Packard Co
- *	Stephane Eranian <eranian@hpl.hp.com>
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- *
- * 02/04/00 D. Mosberger	Merged in serial.c bug fixes in rs_close().
- * 02/25/00 D. Mosberger	Synced up with 2.3.99pre-5 version of serial.c.
- */
-
-#include <linux/config.h>
-#include <linux/init.h>
-#include <linux/errno.h>
-#include <linux/sched.h>
-#include <linux/tty.h>
-#include <linux/tty_flip.h>
-#include <linux/major.h>
-#include <linux/fcntl.h>
-#include <linux/mm.h>
-#include <linux/console.h>
-#include <linux/module.h>
-#include <linux/serial.h>
-#include <linux/serialP.h>
-#include <linux/slab.h>
-
-#include <asm/irq.h>
-#include <asm/uaccess.h>
-
-#undef SIMSERIAL_DEBUG	/* define this to get some debug information */
-
-#define KEYBOARD_INTR	3	/* must match with simulator! */
-
-#define NR_PORTS	1	/* only one port for now */
-#define SERIAL_INLINE	1
-
-#ifdef SERIAL_INLINE
-#define _INLINE_ inline
-#endif
-
-#ifndef MIN
-#define MIN(a,b)	((a) < (b) ? (a) : (b))
-#endif
-
-#define IRQ_T(info) ((info->flags & ASYNC_SHARE_IRQ) ? SA_SHIRQ : SA_INTER=
RUPT)
-
-#define SSC_GETCHAR	21
-
-extern long ia64_ssc (long, long, long, long, int);
-extern void ia64_ssc_connect_irq (long intr, long irq);
-
-static char *serial_name =3D "SimSerial driver";
-static char *serial_version =3D "0.6";
-
-/*
- * This has been extracted from asm/serial.h. We need one eventually but
- * I don't know exactly what we're going to put in it so just fake one
- * for now.
- */
-#define BASE_BAUD ( 1843200 / 16 )
-
-#define STD_COM_FLAGS (ASYNC_BOOT_AUTOCONF | ASYNC_SKIP_TEST)
-
-/*
- * Most of the values here are meaningless to this particular driver.
- * However some values must be preserved for the code (leveraged from seri=
al.c
- * to work correctly).
- * port must not be 0
- * type must not be UNKNOWN
- * So I picked arbitrary (guess from where?) values instead
- */
-static struct serial_state rs_table[NR_PORTS]=3D{
-  /* UART CLK   PORT IRQ     FLAGS        */
-  { 0, BASE_BAUD, 0x3F8, 0, STD_COM_FLAGS,0,PORT_16550 }  /* ttyS0 */
-};
-
-/*
- * Just for the fun of it !
- */
-static struct serial_uart_config uart_config[] =3D {
-	{ "unknown", 1, 0 },
-	{ "8250", 1, 0 },
-	{ "16450", 1, 0 },
-	{ "16550", 1, 0 },
-	{ "16550A", 16, UART_CLEAR_FIFO | UART_USE_FIFO },
-	{ "cirrus", 1, 0 },
-	{ "ST16650", 1, UART_CLEAR_FIFO | UART_STARTECH },
-	{ "ST16650V2", 32, UART_CLEAR_FIFO | UART_USE_FIFO |
-		  UART_STARTECH },
-	{ "TI16750", 64, UART_CLEAR_FIFO | UART_USE_FIFO},
-	{ 0, 0}
-};
-
-static struct tty_driver serial_driver, callout_driver;
-static int serial_refcount;
-
-static struct async_struct *IRQ_ports[NR_IRQS];
-static struct tty_struct *serial_table[NR_PORTS];
-static struct termios *serial_termios[NR_PORTS];
-static struct termios *serial_termios_locked[NR_PORTS];
-
-static struct console *console;
-
-static unsigned char *tmp_buf;
-static DECLARE_MUTEX(tmp_buf_sem);
-
-extern struct console *console_drivers; /* from kernel/printk.c */
-
-/*
- * ------------------------------------------------------------
- * rs_stop() and rs_start()
- *
- * This routines are called before setting or resetting tty->stopped.
- * They enable or disable transmitter interrupts, as necessary.
- * ------------------------------------------------------------
- */
-static void rs_stop(struct tty_struct *tty)
-{
-#ifdef SIMSERIAL_DEBUG
-	printk("rs_stop: tty->stopped=3D%d tty->hw_stopped=3D%d tty->flow_stopped=
=3D%d\n",
-		tty->stopped, tty->hw_stopped, tty->flow_stopped);
-#endif
-
-}
-
-static void rs_start(struct tty_struct *tty)
-{
-#if SIMSERIAL_DEBUG
-	printk("rs_start: tty->stopped=3D%d tty->hw_stopped=3D%d tty->flow_stoppe=
d=3D%d\n",
-		tty->stopped, tty->hw_stopped, tty->flow_stopped);
-#endif
-}
-
-static  void receive_chars(struct tty_struct *tty, struct pt_regs *regs)
-{
-	unsigned char ch;
-	static unsigned char seen_esc =3D 0;
-
-	while ( (ch =3D ia64_ssc(0, 0, 0, 0, SSC_GETCHAR)) ) {
-		if ( ch =3D 27 && seen_esc =3D 0 ) {
-			seen_esc =3D 1;
-			continue;
-		} else {
-			if ( seen_esc=3D1 && ch =3D 'O' ) {
-				seen_esc =3D 2;
-				continue;
-			} else if ( seen_esc =3D 2 ) {
-				if ( ch =3D 'P' ) show_state();		/* F1 key */
-				if ( ch =3D 'Q' ) show_buffers();	/* F2 key */
-				seen_esc =3D 0;
-				continue;
-			}
-		}
-		seen_esc =3D 0;
-		if (tty->flip.count >=3D TTY_FLIPBUF_SIZE) break;
-
-		*tty->flip.char_buf_ptr =3D ch;
-
-		*tty->flip.flag_buf_ptr =3D 0;
-
-		tty->flip.flag_buf_ptr++;
-		tty->flip.char_buf_ptr++;
-		tty->flip.count++;
-	}
-	tty_flip_buffer_push(tty);
-}
-
-/*
- * This is the serial driver's interrupt routine for a single port
- */
-static void rs_interrupt_single(int irq, void *dev_id, struct pt_regs * re=
gs)
-{
-	struct async_struct * info;
-
-	/*
-	 * I don't know exactly why they don't use the dev_id opaque data
-	 * pointer instead of this extra lookup table
-	 */
-	info =3D IRQ_ports[irq];
-	if (!info || !info->tty) {
-		printk("simrs_interrupt_single: info|tty=3D0 info=3D%p problem\n", info);
-		return;
-	}
-	/*
-	 * pretty simple in our case, because we only get interrupts
-	 * on inbound traffic
-	 */
-	receive_chars(info->tty, regs);
-}
-
-/*
- * -------------------------------------------------------------------
- * Here ends the serial interrupt routines.
- * -------------------------------------------------------------------
- */
-
-#if 0
-/*
- * not really used in our situation so keep them commented out for now
- */
-static DECLARE_TASK_QUEUE(tq_serial); /* used to be at the top of the file=
 */
-static void do_serial_bh(void)
-{
-	run_task_queue(&tq_serial);
-	printk("do_serial_bh: called\n");
-}
-#endif
-
-static void do_softint(void *private_)
-{
-	printk("simserial: do_softint called\n");
-}
-
-static void rs_put_char(struct tty_struct *tty, unsigned char ch)
-{
-	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
-	unsigned long flags;
-
-	if (!tty || !info->xmit.buf) return;
-
-	save_flags(flags); cli();
-	if (CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE) =3D 0)=
 {
-		restore_flags(flags);
-		return;
-	}
-	info->xmit.buf[info->xmit.head] =3D ch;
-	info->xmit.head =3D (info->xmit.head + 1) & (SERIAL_XMIT_SIZE-1);
-	restore_flags(flags);
-}
-
-static _INLINE_ void transmit_chars(struct async_struct *info, int *intr_d=
one)
-{
-	int count;
-	unsigned long flags;
-
-	save_flags(flags); cli();
-
-	if (info->x_char) {
-		char c =3D info->x_char;
-
-		console->write(console, &c, 1);
-
-		info->state->icount.tx++;
-		info->x_char =3D 0;
-
-		goto out;
-	}
-
-	if (info->xmit.head =3D info->xmit.tail || info->tty->stopped || info->tt=
y->hw_stopped) {
-#ifdef SIMSERIAL_DEBUG
-		printk("transmit_chars: head=3D%d, tail=3D%d, stopped=3D%d\n",
-		       info->xmit.head, info->xmit.tail, info->tty->stopped);
-#endif
-		goto out;
-	}
-	/*
-	 * We removed the loop and try to do it in to chunks. We need
-	 * 2 operations maximum because it's a ring buffer.
-	 *
-	 * First from current to tail if possible.
-	 * Then from the beginning of the buffer until necessary
-	 */
-
-	count =3D MIN(CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE=
),
-		    SERIAL_XMIT_SIZE - info->xmit.tail);
-	console->write(console, info->xmit.buf+info->xmit.tail, count);
-
-	info->xmit.tail =3D (info->xmit.tail+count) & (SERIAL_XMIT_SIZE-1);
-
-	/*
-	 * We have more at the beginning of the buffer
-	 */
-	count =3D CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
-	if (count) {
-		console->write(console, info->xmit.buf, count);
-		info->xmit.tail +=3D count;
-	}
-out:
-	restore_flags(flags);
-}
-
-static void rs_flush_chars(struct tty_struct *tty)
-{
-	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
-
-	if (info->xmit.head =3D info->xmit.tail || tty->stopped || tty->hw_stoppe=
d ||
-	    !info->xmit.buf)
-		return;
-
-	transmit_chars(info, NULL);
-}
-
-
-static int rs_write(struct tty_struct * tty, int from_user,
-		    const unsigned char *buf, int count)
-{
-	int	c, ret =3D 0;
-	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
-	unsigned long flags;
-
-	if (!tty || !info->xmit.buf || !tmp_buf) return 0;
-
-	save_flags(flags);
-	if (from_user) {
-		down(&tmp_buf_sem);
-		while (1) {
-			int c1;
-			c =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_S=
IZE);
-			if (count < c)
-				c =3D count;
-			if (c <=3D 0)
-				break;
-
-			c -=3D copy_from_user(tmp_buf, buf, c);
-			if (!c) {
-				if (!ret)
-					ret =3D -EFAULT;
-				break;
-			}
-			cli();
-			c1 =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_=
SIZE);
-			if (c1 < c)
-				c =3D c1;
-			memcpy(info->xmit.buf + info->xmit.head, tmp_buf, c);
-			info->xmit.head =3D ((info->xmit.head + c) &
-					   (SERIAL_XMIT_SIZE-1));
-			restore_flags(flags);
-			buf +=3D c;
-			count -=3D c;
-			ret +=3D c;
-		}
-		up(&tmp_buf_sem);
-	} else {
-		cli();
-		while (1) {
-			c =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_S=
IZE);
-			if (count < c)
-				c =3D count;
-			if (c <=3D 0) {
-				break;
-			}
-			memcpy(info->xmit.buf + info->xmit.head, buf, c);
-			info->xmit.head =3D ((info->xmit.head + c) &
-					   (SERIAL_XMIT_SIZE-1));
-			buf +=3D c;
-			count -=3D c;
-			ret +=3D c;
-		}
-		restore_flags(flags);
-	}
-	/*
-	 * Hey, we transmit directly from here in our case
-	 */
-	if (CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE)
-	    && !tty->stopped && !tty->hw_stopped) {
-		transmit_chars(info, NULL);
-	}
-	return ret;
-}
-
-static int rs_write_room(struct tty_struct *tty)
-{
-	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
-
-	return CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
-}
-
-static int rs_chars_in_buffer(struct tty_struct *tty)
-{
-	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
-
-	return CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
-}
-
-static void rs_flush_buffer(struct tty_struct *tty)
-{
-	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
-	unsigned long flags;
-
-	save_flags(flags); cli();
-	info->xmit.head =3D info->xmit.tail =3D 0;
-	restore_flags(flags);
-
-	wake_up_interruptible(&tty->write_wait);
-
-	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
-	    tty->ldisc.write_wakeup)
-		(tty->ldisc.write_wakeup)(tty);
-}
-
-/*
- * This function is used to send a high-priority XON/XOFF character to
- * the device
- */
-static void rs_send_xchar(struct tty_struct *tty, char ch)
-{
-	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
-
-	info->x_char =3D ch;
-	if (ch) {
-		/*
-		 * I guess we could call console->write() directly but
-		 * let's do that for now.
-		 */
-		transmit_chars(info, NULL);
-	}
-}
-
-/*
- * ------------------------------------------------------------
- * rs_throttle()
- *
- * This routine is called by the upper-layer tty layer to signal that
- * incoming characters should be throttled.
- * ------------------------------------------------------------
- */
-static void rs_throttle(struct tty_struct * tty)
-{
-	if (I_IXOFF(tty)) rs_send_xchar(tty, STOP_CHAR(tty));
-
-	printk("simrs_throttle called\n");
-}
-
-static void rs_unthrottle(struct tty_struct * tty)
-{
-	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
-
-	if (I_IXOFF(tty)) {
-		if (info->x_char)
-			info->x_char =3D 0;
-		else
-			rs_send_xchar(tty, START_CHAR(tty));
-	}
-	printk("simrs_unthrottle called\n");
-}
-
-/*
- * rs_break() --- routine which turns the break handling on or off
- */
-static void rs_break(struct tty_struct *tty, int break_state)
-{
-}
-
-static int rs_ioctl(struct tty_struct *tty, struct file * file,
-		    unsigned int cmd, unsigned long arg)
-{
-	if ((cmd !=3D TIOCGSERIAL) && (cmd !=3D TIOCSSERIAL) &&
-	    (cmd !=3D TIOCSERCONFIG) && (cmd !=3D TIOCSERGSTRUCT) &&
-	    (cmd !=3D TIOCMIWAIT) && (cmd !=3D TIOCGICOUNT)) {
-		if (tty->flags & (1 << TTY_IO_ERROR))
-		    return -EIO;
-	}
-
-	switch (cmd) {
-		case TIOCMGET:
-			printk("rs_ioctl: TIOCMGET called\n");
-			return -EINVAL;
-		case TIOCMBIS:
-		case TIOCMBIC:
-		case TIOCMSET:
-			printk("rs_ioctl: TIOCMBIS/BIC/SET called\n");
-			return -EINVAL;
-		case TIOCGSERIAL:
-			printk("simrs_ioctl TIOCGSERIAL called\n");
-			return 0;
-		case TIOCSSERIAL:
-			printk("simrs_ioctl TIOCSSERIAL called\n");
-			return 0;
-		case TIOCSERCONFIG:
-			printk("rs_ioctl: TIOCSERCONFIG called\n");
-			return -EINVAL;
-
-		case TIOCSERGETLSR: /* Get line status register */
-			printk("rs_ioctl: TIOCSERGETLSR called\n");
-			return  -EINVAL;
-
-		case TIOCSERGSTRUCT:
-			printk("rs_ioctl: TIOCSERGSTRUCT called\n");
-#if 0
-			if (copy_to_user((struct async_struct *) arg,
-					 info, sizeof(struct async_struct)))
-				return -EFAULT;
-#endif
-			return 0;
-
-		/*
-		 * Wait for any of the 4 modem inputs (DCD,RI,DSR,CTS) to change
-		 * - mask passed in arg for lines of interest
-		 *   (use |'ed TIOCM_RNG/DSR/CD/CTS for masking)
-		 * Caller should use TIOCGICOUNT to see which one it was
-		 */
-		case TIOCMIWAIT:
-			printk("rs_ioctl: TIOCMIWAIT: called\n");
-			return 0;
-		/*
-		 * Get counter of input serial line interrupts (DCD,RI,DSR,CTS)
-		 * Return: write counters to the user passed counter struct
-		 * NB: both 1->0 and 0->1 transitions are counted except for
-		 *     RI where only 0->1 is counted.
-		 */
-		case TIOCGICOUNT:
-			printk("rs_ioctl: TIOCGICOUNT called\n");
-			return 0;
-
-		case TIOCSERGWILD:
-		case TIOCSERSWILD:
-			/* "setserial -W" is called in Debian boot */
-			printk ("TIOCSER?WILD ioctl obsolete, ignored.\n");
-			return 0;
-
-		default:
-			return -ENOIOCTLCMD;
-		}
-	return 0;
-}
-
-#define RELEVANT_IFLAG(iflag) (iflag & (IGNBRK|BRKINT|IGNPAR|PARMRK|INPCK))
-
-static void rs_set_termios(struct tty_struct *tty, struct termios *old_ter=
mios)
-{
-	unsigned int cflag =3D tty->termios->c_cflag;
-
-	if (   (cflag =3D old_termios->c_cflag)
-	    && (   RELEVANT_IFLAG(tty->termios->c_iflag)
-		=3D RELEVANT_IFLAG(old_termios->c_iflag)))
-	  return;
-
-
-	/* Handle turning off CRTSCTS */
-	if ((old_termios->c_cflag & CRTSCTS) &&
-	    !(tty->termios->c_cflag & CRTSCTS)) {
-		tty->hw_stopped =3D 0;
-		rs_start(tty);
-	}
-}
-/*
- * This routine will shutdown a serial port; interrupts are disabled, and
- * DTR is dropped if the hangup on close termio flag is on.
- */
-static void shutdown(struct async_struct * info)
-{
-	unsigned long	flags;
-	struct serial_state *state;
-	int		retval;
-
-	if (!(info->flags & ASYNC_INITIALIZED)) return;
-
-	state =3D info->state;
-
-#ifdef SIMSERIAL_DEBUG
-	printk("Shutting down serial port %d (irq %d)....", info->line,
-	       state->irq);
-#endif
-
-	save_flags(flags); cli(); /* Disable interrupts */
-
-	/*
-	 * First unlink the serial port from the IRQ chain...
-	 */
-	if (info->next_port)
-		info->next_port->prev_port =3D info->prev_port;
-	if (info->prev_port)
-		info->prev_port->next_port =3D info->next_port;
-	else
-		IRQ_ports[state->irq] =3D info->next_port;
-
-	/*
-	 * Free the IRQ, if necessary
-	 */
-	if (state->irq && (!IRQ_ports[state->irq] ||
-			  !IRQ_ports[state->irq]->next_port)) {
-		if (IRQ_ports[state->irq]) {
-			free_irq(state->irq, NULL);
-			retval =3D request_irq(state->irq, rs_interrupt_single,
-					     IRQ_T(info), "serial", NULL);
-
-			if (retval)
-				printk("serial shutdown: request_irq: error %d"
-				       "  Couldn't reacquire IRQ.\n", retval);
-		} else
-			free_irq(state->irq, NULL);
-	}
-
-	if (info->xmit.buf) {
-		free_page((unsigned long) info->xmit.buf);
-		info->xmit.buf =3D 0;
-	}
-
-	if (info->tty) set_bit(TTY_IO_ERROR, &info->tty->flags);
-
-	info->flags &=3D ~ASYNC_INITIALIZED;
-	restore_flags(flags);
-}
-
-/*
- * ------------------------------------------------------------
- * rs_close()
- *
- * This routine is called when the serial port gets closed.  First, we
- * wait for the last remaining data to be sent.  Then, we unlink its
- * async structure from the interrupt chain if necessary, and we free
- * that IRQ if nothing is left in the chain.
- * ------------------------------------------------------------
- */
-static void rs_close(struct tty_struct *tty, struct file * filp)
-{
-	struct async_struct * info =3D (struct async_struct *)tty->driver_data;
-	struct serial_state *state;
-	unsigned long flags;
-
-	if (!info ) return;
-
-	state =3D info->state;
-
-	save_flags(flags); cli();
-
-	if (tty_hung_up_p(filp)) {
-#ifdef SIMSERIAL_DEBUG
-		printk("rs_close: hung_up\n");
-#endif
-		MOD_DEC_USE_COUNT;
-		restore_flags(flags);
-		return;
-	}
-#ifdef SIMSERIAL_DEBUG
-	printk("rs_close ttys%d, count =3D %d\n", info->line, state->count);
-#endif
-	if ((tty->count =3D 1) && (state->count !=3D 1)) {
-		/*
-		 * Uh, oh.  tty->count is 1, which means that the tty
-		 * structure will be freed.  state->count should always
-		 * be one in these conditions.  If it's greater than
-		 * one, we've got real problems, since it means the
-		 * serial port won't be shutdown.
-		 */
-		printk("rs_close: bad serial port count; tty->count is 1, "
-		       "state->count is %d\n", state->count);
-		state->count =3D 1;
-	}
-	if (--state->count < 0) {
-		printk("rs_close: bad serial port count for ttys%d: %d\n",
-		       info->line, state->count);
-		state->count =3D 0;
-	}
-	if (state->count) {
-		MOD_DEC_USE_COUNT;
-		restore_flags(flags);
-		return;
-	}
-	info->flags |=3D ASYNC_CLOSING;
-	restore_flags(flags);
-
-	/*
-	 * Now we wait for the transmit buffer to clear; and we notify
-	 * the line discipline to only process XON/XOFF characters.
-	 */
-	shutdown(info);
-	if (tty->driver.flush_buffer) tty->driver.flush_buffer(tty);
-	if (tty->ldisc.flush_buffer) tty->ldisc.flush_buffer(tty);
-	info->event =3D 0;
-	info->tty =3D 0;
-	if (info->blocked_open) {
-		if (info->close_delay) {
-			current->state =3D TASK_INTERRUPTIBLE;
-			schedule_timeout(info->close_delay);
-		}
-		wake_up_interruptible(&info->open_wait);
-	}
-	info->flags &=3D ~(ASYNC_NORMAL_ACTIVE|ASYNC_CALLOUT_ACTIVE|ASYNC_CLOSING=
);
-	wake_up_interruptible(&info->close_wait);
-	MOD_DEC_USE_COUNT;
-}
-
-/*
- * rs_wait_until_sent() --- wait until the transmitter is empty
- */
-static void rs_wait_until_sent(struct tty_struct *tty, int timeout)
-{
-}
-
-
-/*
- * rs_hangup() --- called by tty_hangup() when a hangup is signaled.
- */
-static void rs_hangup(struct tty_struct *tty)
-{
-	struct async_struct * info =3D (struct async_struct *)tty->driver_data;
-	struct serial_state *state =3D info->state;
-
-#ifdef SIMSERIAL_DEBUG
-	printk("rs_hangup: called\n");
-#endif
-
-	state =3D info->state;
-
-	rs_flush_buffer(tty);
-	if (info->flags & ASYNC_CLOSING)
-		return;
-	shutdown(info);
-
-	info->event =3D 0;
-	state->count =3D 0;
-	info->flags &=3D ~(ASYNC_NORMAL_ACTIVE|ASYNC_CALLOUT_ACTIVE);
-	info->tty =3D 0;
-	wake_up_interruptible(&info->open_wait);
-}
-
-
-static int get_async_struct(int line, struct async_struct **ret_info)
-{
-	struct async_struct *info;
-	struct serial_state *sstate;
-
-	sstate =3D rs_table + line;
-	sstate->count++;
-	if (sstate->info) {
-		*ret_info =3D sstate->info;
-		return 0;
-	}
-	info =3D kmalloc(sizeof(struct async_struct), GFP_KERNEL);
-	if (!info) {
-		sstate->count--;
-		return -ENOMEM;
-	}
-	memset(info, 0, sizeof(struct async_struct));
-	init_waitqueue_head(&info->open_wait);
-	init_waitqueue_head(&info->close_wait);
-	init_waitqueue_head(&info->delta_msr_wait);
-	info->magic =3D SERIAL_MAGIC;
-	info->port =3D sstate->port;
-	info->flags =3D sstate->flags;
-	info->xmit_fifo_size =3D sstate->xmit_fifo_size;
-	info->line =3D line;
-	info->tqueue.routine =3D do_softint;
-	info->tqueue.data =3D info;
-	info->state =3D sstate;
-	if (sstate->info) {
-		kfree(info);
-		*ret_info =3D sstate->info;
-		return 0;
-	}
-	*ret_info =3D sstate->info =3D info;
-	return 0;
-}
-
-static int
-startup(struct async_struct *info)
-{
-	unsigned long flags;
-	int	retval=3D0;
-	void (*handler)(int, void *, struct pt_regs *);
-	struct serial_state *state=3D info->state;
-	unsigned long page;
-
-	page =3D get_free_page(GFP_KERNEL);
-	if (!page)
-		return -ENOMEM;
-
-	save_flags(flags); cli();
-
-	if (info->flags & ASYNC_INITIALIZED) {
-		free_page(page);
-		goto errout;
-	}
-
-	if (!state->port || !state->type) {
-		if (info->tty) set_bit(TTY_IO_ERROR, &info->tty->flags);
-		free_page(page);
-		goto errout;
-	}
-	if (info->xmit.buf)
-		free_page(page);
-	else
-		info->xmit.buf =3D (unsigned char *) page;
-
-#ifdef SIMSERIAL_DEBUG
-	printk("startup: ttys%d (irq %d)...", info->line, state->irq);
-#endif
-
-	/*
-	 * Allocate the IRQ if necessary
-	 */
-	if (state->irq && (!IRQ_ports[state->irq] ||
-			  !IRQ_ports[state->irq]->next_port)) {
-		if (IRQ_ports[state->irq]) {
-			retval =3D -EBUSY;
-			goto errout;
-		} else
-			handler =3D rs_interrupt_single;
-
-		retval =3D request_irq(state->irq, handler, IRQ_T(info),
-				     "simserial", NULL);
-		if (retval) {
-			if (capable(CAP_SYS_ADMIN)) {
-				if (info->tty)
-					set_bit(TTY_IO_ERROR,
-						&info->tty->flags);
-				retval =3D 0;
-			}
-			goto errout;
-		}
-	}
-
-	/*
-	 * Insert serial port into IRQ chain.
-	 */
-	info->prev_port =3D 0;
-	info->next_port =3D IRQ_ports[state->irq];
-	if (info->next_port)
-		info->next_port->prev_port =3D info;
-	IRQ_ports[state->irq] =3D info;
-
-	if (info->tty) clear_bit(TTY_IO_ERROR, &info->tty->flags);
-
-	info->xmit.head =3D info->xmit.tail =3D 0;
-
-#if 0
-	/*
-	 * Set up serial timers...
-	 */
-	timer_table[RS_TIMER].expires =3D jiffies + 2*HZ/100;
-	timer_active |=3D 1 << RS_TIMER;
-#endif
-
-	/*
-	 * Set up the tty->alt_speed kludge
-	 */
-	if (info->tty) {
-		if ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_HI)
-			info->tty->alt_speed =3D 57600;
-		if ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_VHI)
-			info->tty->alt_speed =3D 115200;
-		if ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_SHI)
-			info->tty->alt_speed =3D 230400;
-		if ((info->flags & ASYNC_SPD_MASK) =3D ASYNC_SPD_WARP)
-			info->tty->alt_speed =3D 460800;
-	}
-
-	info->flags |=3D ASYNC_INITIALIZED;
-	restore_flags(flags);
-	return 0;
-
-errout:
-	restore_flags(flags);
-	return retval;
-}
-
-
-/*
- * This routine is called whenever a serial port is opened.  It
- * enables interrupts for a serial port, linking in its async structure in=
to
- * the IRQ chain.   It also performs the serial-specific
- * initialization for the tty structure.
- */
-static int rs_open(struct tty_struct *tty, struct file * filp)
-{
-	struct async_struct	*info;
-	int			retval, line;
-	unsigned long		page;
-
-	MOD_INC_USE_COUNT;
-	line =3D MINOR(tty->device) - tty->driver.minor_start;
-	if ((line < 0) || (line >=3D NR_PORTS)) {
-		MOD_DEC_USE_COUNT;
-		return -ENODEV;
-	}
-	retval =3D get_async_struct(line, &info);
-	if (retval) {
-		MOD_DEC_USE_COUNT;
-		return retval;
-	}
-	tty->driver_data =3D info;
-	info->tty =3D tty;
-
-#ifdef SIMSERIAL_DEBUG
-	printk("rs_open %s%d, count =3D %d\n", tty->driver.name, info->line,
-	       info->state->count);
-#endif
-	info->tty->low_latency =3D (info->flags & ASYNC_LOW_LATENCY) ? 1 : 0;
-
-	if (!tmp_buf) {
-		page =3D get_free_page(GFP_KERNEL);
-		if (!page) {
-			/* MOD_DEC_USE_COUNT; "info->tty" will cause this? */
-			return -ENOMEM;
-		}
-		if (tmp_buf)
-			free_page(page);
-		else
-			tmp_buf =3D (unsigned char *) page;
-	}
-
-	/*
-	 * If the port is the middle of closing, bail out now
-	 */
-	if (tty_hung_up_p(filp) ||
-	    (info->flags & ASYNC_CLOSING)) {
-		if (info->flags & ASYNC_CLOSING)
-			interruptible_sleep_on(&info->close_wait);
-		/* MOD_DEC_USE_COUNT; "info->tty" will cause this? */
-#ifdef SERIAL_DO_RESTART
-		return ((info->flags & ASYNC_HUP_NOTIFY) ?
-			-EAGAIN : -ERESTARTSYS);
-#else
-		return -EAGAIN;
-#endif
-	}
-
-	/*
-	 * Start up serial port
-	 */
-	retval =3D startup(info);
-	if (retval) {
-		/* MOD_DEC_USE_COUNT; "info->tty" will cause this? */
-		return retval;
-	}
-
-	if ((info->state->count =3D 1) &&
-	    (info->flags & ASYNC_SPLIT_TERMIOS)) {
-		if (tty->driver.subtype =3D SERIAL_TYPE_NORMAL)
-			*tty->termios =3D info->state->normal_termios;
-		else
-			*tty->termios =3D info->state->callout_termios;
-	}
-
-	/*
-	 * figure out which console to use (should be one already)
-	 */
-	console =3D console_drivers;
-	while (console) {
-		if ((console->flags & CON_ENABLED) && console->write) break;
-		console =3D console->next;
-	}
-
-	info->session =3D current->session;
-	info->pgrp =3D current->pgrp;
-
-#ifdef SIMSERIAL_DEBUG
-	printk("rs_open ttys%d successful\n", info->line);
-#endif
-	return 0;
-}
-
-/*
- * /proc fs routines....
- */
-
-static inline int line_info(char *buf, struct serial_state *state)
-{
-	return sprintf(buf, "%d: uart:%s port:%lX irq:%d\n",
-		       state->line, uart_config[state->type].name,
-		       state->port, state->irq);
-}
-
-static int rs_read_proc(char *page, char **start, off_t off, int count,
-		 int *eof, void *data)
-{
-	int i, len =3D 0, l;
-	off_t	begin =3D 0;
-
-	len +=3D sprintf(page, "simserinfo:1.0 driver:%s\n", serial_version);
-	for (i =3D 0; i < NR_PORTS && len < 4000; i++) {
-		l =3D line_info(page + len, &rs_table[i]);
-		len +=3D l;
-		if (len+begin > off+count)
-			goto done;
-		if (len+begin < off) {
-			begin +=3D len;
-			len =3D 0;
-		}
-	}
-	*eof =3D 1;
-done:
-	if (off >=3D len+begin)
-		return 0;
-	*start =3D page + (begin-off);
-	return ((count < begin+len-off) ? count : begin+len-off);
-}
-
-/*
- * ---------------------------------------------------------------------
- * rs_init() and friends
- *
- * rs_init() is called at boot-time to initialize the serial driver.
- * ---------------------------------------------------------------------
- */
-
-/*
- * This routine prints out the appropriate serial driver version
- * number, and identifies which options were configured into this
- * driver.
- */
-static inline void show_serial_version(void)
-{
-	printk(KERN_INFO "%s version %s with", serial_name, serial_version);
-	printk(" no serial options enabled\n");
-}
-
-/*
- * The serial driver boot-time initialization code!
- */
-static int __init
-simrs_init (void)
-{
-	int			i;
-	struct serial_state	*state;
-
-	show_serial_version();
-
-	/* Initialize the tty_driver structure */
-
-	memset(&serial_driver, 0, sizeof(struct tty_driver));
-	serial_driver.magic =3D TTY_DRIVER_MAGIC;
-	serial_driver.driver_name =3D "simserial";
-	serial_driver.name =3D "ttyS";
-	serial_driver.major =3D TTY_MAJOR;
-	serial_driver.minor_start =3D 64;
-	serial_driver.num =3D 1;
-	serial_driver.type =3D TTY_DRIVER_TYPE_SERIAL;
-	serial_driver.subtype =3D SERIAL_TYPE_NORMAL;
-	serial_driver.init_termios =3D tty_std_termios;
-	serial_driver.init_termios.c_cflag -		B9600 | CS8 | CREAD | HUPCL | CLOCA=
L;
-	serial_driver.flags =3D TTY_DRIVER_REAL_RAW;
-	serial_driver.refcount =3D &serial_refcount;
-	serial_driver.table =3D serial_table;
-	serial_driver.termios =3D serial_termios;
-	serial_driver.termios_locked =3D serial_termios_locked;
-
-	serial_driver.open =3D rs_open;
-	serial_driver.close =3D rs_close;
-	serial_driver.write =3D rs_write;
-	serial_driver.put_char =3D rs_put_char;
-	serial_driver.flush_chars =3D rs_flush_chars;
-	serial_driver.write_room =3D rs_write_room;
-	serial_driver.chars_in_buffer =3D rs_chars_in_buffer;
-	serial_driver.flush_buffer =3D rs_flush_buffer;
-	serial_driver.ioctl =3D rs_ioctl;
-	serial_driver.throttle =3D rs_throttle;
-	serial_driver.unthrottle =3D rs_unthrottle;
-	serial_driver.send_xchar =3D rs_send_xchar;
-	serial_driver.set_termios =3D rs_set_termios;
-	serial_driver.stop =3D rs_stop;
-	serial_driver.start =3D rs_start;
-	serial_driver.hangup =3D rs_hangup;
-	serial_driver.break_ctl =3D rs_break;
-	serial_driver.wait_until_sent =3D rs_wait_until_sent;
-	serial_driver.read_proc =3D rs_read_proc;
-
-	/*
-	 * Let's have a little bit of fun !
-	 */
-	for (i =3D 0, state =3D rs_table; i < NR_PORTS; i++,state++) {
-
-		if (state->type =3D PORT_UNKNOWN) continue;
-
-		if (!state->irq) {
-			state->irq =3D ia64_alloc_vector();
-			ia64_ssc_connect_irq(KEYBOARD_INTR, state->irq);
-		}
-
-		printk(KERN_INFO "ttyS%02d at 0x%04lx (irq =3D %d) is a %s\n",
-		       state->line,
-		       state->port, state->irq,
-		       uart_config[state->type].name);
-	}
-	/*
-	 * The callout device is just like normal device except for
-	 * major number and the subtype code.
-	 */
-	callout_driver =3D serial_driver;
-	callout_driver.name =3D "cua";
-	callout_driver.major =3D TTYAUX_MAJOR;
-	callout_driver.subtype =3D SERIAL_TYPE_CALLOUT;
-	callout_driver.read_proc =3D 0;
-	callout_driver.proc_entry =3D 0;
-
-	if (tty_register_driver(&serial_driver))
-		panic("Couldn't register simserial driver\n");
-
-	if (tty_register_driver(&callout_driver))
-		panic("Couldn't register callout driver\n");
-
-	return 0;
-}
-
-#ifndef MODULE
-__initcall(simrs_init);
-#endif
diff -u -urN linux-2.4.20-ia64-021210/drivers/char/Makefile linux-ski/drive=
rs/char/Makefile
--- linux-2.4.20-ia64-021210/drivers/char/Makefile	2002-11-28 16:53:12.0000=
00000 -0700
+++ linux-ski/drivers/char/Makefile	2002-12-13 10:04:07.000000000 -0700
@@ -168,6 +168,7 @@
 obj-$(CONFIG_HIL) +=3D hp_keyb.o
 obj-$(CONFIG_MAGIC_SYSRQ) +=3D sysrq.o
 obj-$(CONFIG_ATARI_DSP56K) +=3D dsp56k.o
+obj-$(CONFIG_HP_SIMSERIAL) +=3D simserial.o
 obj-$(CONFIG_ROCKETPORT) +=3D rocket.o
 obj-$(CONFIG_MOXA_SMARTIO) +=3D mxser.o
 obj-$(CONFIG_MOXA_INTELLIO) +=3D moxa.o
diff -u -urN linux-2.4.20-ia64-021210/drivers/char/simserial.c linux-ski/dr=
ivers/char/simserial.c
--- linux-2.4.20-ia64-021210/drivers/char/simserial.c	1969-12-31 17:00:00.0=
00000000 -0700
+++ linux-ski/drivers/char/simserial.c	2002-12-13 10:04:07.000000000 -0700
@@ -0,0 +1,1095 @@
+/*
+ * Simulated Serial Driver (fake serial)
+ *
+ * This driver is mostly used for bringup purposes and will go away.
+ * It has a strong dependency on the system console. All outputs
+ * are rerouted to the same facility as the one used by printk which, in o=
ur
+ * case means sys_sim.c console (goes via the simulator). The code hereaft=
er
+ * is completely leveraged from the serial.c driver.
+ *
+ * Copyright (C) 1999-2000, 2002 Hewlett-Packard Co
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * 02/04/00 D. Mosberger	Merged in serial.c bug fixes in rs_close().
+ * 02/25/00 D. Mosberger	Synced up with 2.3.99pre-5 version of serial.c.
+ */
+
+#include <linux/config.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/sched.h>
+#include <linux/tty.h>
+#include <linux/tty_flip.h>
+#include <linux/major.h>
+#include <linux/fcntl.h>
+#include <linux/mm.h>
+#include <linux/console.h>
+#include <linux/module.h>
+#include <linux/serial.h>
+#include <linux/serialP.h>
+#include <linux/slab.h>
+
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+#undef SIMSERIAL_DEBUG	/* define this to get some debug information */
+
+#define KEYBOARD_INTR	3	/* must match with simulator! */
+
+#define NR_PORTS	1	/* only one port for now */
+#define SERIAL_INLINE	1
+
+#ifdef SERIAL_INLINE
+#define _INLINE_ inline
+#endif
+
+#ifndef MIN
+#define MIN(a,b)	((a) < (b) ? (a) : (b))
+#endif
+
+#define IRQ_T(info) ((info->flags & ASYNC_SHARE_IRQ) ? SA_SHIRQ : SA_INTER=
RUPT)
+
+#define SSC_GETCHAR	21
+
+extern long ia64_ssc (long, long, long, long, int);
+extern void ia64_ssc_connect_irq (long intr, long irq);
+
+static char *serial_name =3D "SimSerial driver";
+static char *serial_version =3D "0.6";
+
+/*
+ * This has been extracted from asm/serial.h. We need one eventually but
+ * I don't know exactly what we're going to put in it so just fake one
+ * for now.
+ */
+#define BASE_BAUD ( 1843200 / 16 )
+
+#define STD_COM_FLAGS (ASYNC_BOOT_AUTOCONF | ASYNC_SKIP_TEST)
+
+/*
+ * Most of the values here are meaningless to this particular driver.
+ * However some values must be preserved for the code (leveraged from seri=
al.c
+ * to work correctly).
+ * port must not be 0
+ * type must not be UNKNOWN
+ * So I picked arbitrary (guess from where?) values instead
+ */
+static struct serial_state rs_table[NR_PORTS]=3D{
+  /* UART CLK   PORT IRQ     FLAGS        */
+  { 0, BASE_BAUD, 0x3F8, 0, STD_COM_FLAGS,0,PORT_16550 }  /* ttyS0 */
+};
+
+/*
+ * Just for the fun of it !
+ */
+static struct serial_uart_config uart_config[] =3D {
+	{ "unknown", 1, 0 },
+	{ "8250", 1, 0 },
+	{ "16450", 1, 0 },
+	{ "16550", 1, 0 },
+	{ "16550A", 16, UART_CLEAR_FIFO | UART_USE_FIFO },
+	{ "cirrus", 1, 0 },
+	{ "ST16650", 1, UART_CLEAR_FIFO | UART_STARTECH },
+	{ "ST16650V2", 32, UART_CLEAR_FIFO | UART_USE_FIFO |
+		  UART_STARTECH },
+	{ "TI16750", 64, UART_CLEAR_FIFO | UART_USE_FIFO},
+	{ 0, 0}
+};
+
+static struct tty_driver serial_driver, callout_driver;
+static int serial_refcount;
+
+static struct async_struct *IRQ_ports[NR_IRQS];
+static struct tty_struct *serial_table[NR_PORTS];
+static struct termios *serial_termios[NR_PORTS];
+static struct termios *serial_termios_locked[NR_PORTS];
+
+static struct console *console;
+
+static unsigned char *tmp_buf;
+static DECLARE_MUTEX(tmp_buf_sem);
+
+extern struct console *console_drivers; /* from kernel/printk.c */
+
+/*
+ * ------------------------------------------------------------
+ * rs_stop() and rs_start()
+ *
+ * This routines are called before setting or resetting tty->stopped.
+ * They enable or disable transmitter interrupts, as necessary.
+ * ------------------------------------------------------------
+ */
+static void rs_stop(struct tty_struct *tty)
+{
+#ifdef SIMSERIAL_DEBUG
+	printk("rs_stop: tty->stopped=3D%d tty->hw_stopped=3D%d tty->flow_stopped=
=3D%d\n",
+		tty->stopped, tty->hw_stopped, tty->flow_stopped);
+#endif
+
+}
+
+static void rs_start(struct tty_struct *tty)
+{
+#if SIMSERIAL_DEBUG
+	printk("rs_start: tty->stopped=3D%d tty->hw_stopped=3D%d tty->flow_stoppe=
d=3D%d\n",
+		tty->stopped, tty->hw_stopped, tty->flow_stopped);
+#endif
+}
+
+static  void receive_chars(struct tty_struct *tty, struct pt_regs *regs)
+{
+	unsigned char ch;
+	static unsigned char seen_esc =3D 0;
+
+	while ( (ch =3D ia64_ssc(0, 0, 0, 0, SSC_GETCHAR)) ) {
+		if ( ch =3D 27 && seen_esc =3D 0 ) {
+			seen_esc =3D 1;
+			continue;
+		} else {
+			if ( seen_esc=3D1 && ch =3D 'O' ) {
+				seen_esc =3D 2;
+				continue;
+			} else if ( seen_esc =3D 2 ) {
+				if ( ch =3D 'P' ) show_state();		/* F1 key */
+				if ( ch =3D 'Q' ) show_buffers();	/* F2 key */
+				seen_esc =3D 0;
+				continue;
+			}
+		}
+		seen_esc =3D 0;
+		if (tty->flip.count >=3D TTY_FLIPBUF_SIZE) break;
+
+		*tty->flip.char_buf_ptr =3D ch;
+
+		*tty->flip.flag_buf_ptr =3D 0;
+
+		tty->flip.flag_buf_ptr++;
+		tty->flip.char_buf_ptr++;
+		tty->flip.count++;
+	}
+	tty_flip_buffer_push(tty);
+}
+
+/*
+ * This is the serial driver's interrupt routine for a single port
+ */
+static void rs_interrupt_single(int irq, void *dev_id, struct pt_regs * re=
gs)
+{
+	struct async_struct * info;
+
+	/*
+	 * I don't know exactly why they don't use the dev_id opaque data
+	 * pointer instead of this extra lookup table
+	 */
+	info =3D IRQ_ports[irq];
+	if (!info || !info->tty) {
+		printk("simrs_interrupt_single: info|tty=3D0 info=3D%p problem\n", info);
+		return;
+	}
+	/*
+	 * pretty simple in our case, because we only get interrupts
+	 * on inbound traffic
+	 */
+	receive_chars(info->tty, regs);
+}
+
+/*
+ * -------------------------------------------------------------------
+ * Here ends the serial interrupt routines.
+ * -------------------------------------------------------------------
+ */
+
+#if 0
+/*
+ * not really used in our situation so keep them commented out for now
+ */
+static DECLARE_TASK_QUEUE(tq_serial); /* used to be at the top of the file=
 */
+static void do_serial_bh(void)
+{
+	run_task_queue(&tq_serial);
+	printk("do_serial_bh: called\n");
+}
+#endif
+
+static void do_softint(void *private_)
+{
+	printk("simserial: do_softint called\n");
+}
+
+static void rs_put_char(struct tty_struct *tty, unsigned char ch)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+	unsigned long flags;
+
+	if (!tty || !info->xmit.buf) return;
+
+	save_flags(flags); cli();
+	if (CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE) =3D 0)=
 {
+		restore_flags(flags);
+		return;
+	}
+	info->xmit.buf[info->xmit.head] =3D ch;
+	info->xmit.head =3D (info->xmit.head + 1) & (SERIAL_XMIT_SIZE-1);
+	restore_flags(flags);
+}
+
+static _INLINE_ void transmit_chars(struct async_struct *info, int *intr_d=
one)
+{
+	int count;
+	unsigned long flags;
+
+	save_flags(flags); cli();
+
+	if (info->x_char) {
+		char c =3D info->x_char;
+
+		console->write(console, &c, 1);
+
+		info->state->icount.tx++;
+		info->x_char =3D 0;
+
+		goto out;
+	}
+
+	if (info->xmit.head =3D info->xmit.tail || info->tty->stopped || info->tt=
y->hw_stopped) {
+#ifdef SIMSERIAL_DEBUG
+		printk("transmit_chars: head=3D%d, tail=3D%d, stopped=3D%d\n",
+		       info->xmit.head, info->xmit.tail, info->tty->stopped);
+#endif
+		goto out;
+	}
+	/*
+	 * We removed the loop and try to do it in to chunks. We need
+	 * 2 operations maximum because it's a ring buffer.
+	 *
+	 * First from current to tail if possible.
+	 * Then from the beginning of the buffer until necessary
+	 */
+
+	count =3D MIN(CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE=
),
+		    SERIAL_XMIT_SIZE - info->xmit.tail);
+	console->write(console, info->xmit.buf+info->xmit.tail, count);
+
+	info->xmit.tail =3D (info->xmit.tail+count) & (SERIAL_XMIT_SIZE-1);
+
+	/*
+	 * We have more at the beginning of the buffer
+	 */
+	count =3D CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
+	if (count) {
+		console->write(console, info->xmit.buf, count);
+		info->xmit.tail +=3D count;
+	}
+out:
+	restore_flags(flags);
+}
+
+static void rs_flush_chars(struct tty_struct *tty)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+
+	if (info->xmit.head =3D info->xmit.tail || tty->stopped || tty->hw_stoppe=
d ||
+	    !info->xmit.buf)
+		return;
+
+	transmit_chars(info, NULL);
+}
+
+
+static int rs_write(struct tty_struct * tty, int from_user,
+		    const unsigned char *buf, int count)
+{
+	int	c, ret =3D 0;
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+	unsigned long flags;
+
+	if (!tty || !info->xmit.buf || !tmp_buf) return 0;
+
+	save_flags(flags);
+	if (from_user) {
+		down(&tmp_buf_sem);
+		while (1) {
+			int c1;
+			c =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_S=
IZE);
+			if (count < c)
+				c =3D count;
+			if (c <=3D 0)
+				break;
+
+			c -=3D copy_from_user(tmp_buf, buf, c);
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
+			memcpy(info->xmit.buf + info->xmit.head, tmp_buf, c);
+			info->xmit.head =3D ((info->xmit.head + c) &
+					   (SERIAL_XMIT_SIZE-1));
+			restore_flags(flags);
+			buf +=3D c;
+			count -=3D c;
+			ret +=3D c;
+		}
+		up(&tmp_buf_sem);
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
+			info->xmit.head =3D ((info->xmit.head + c) &
+					   (SERIAL_XMIT_SIZE-1));
+			buf +=3D c;
+			count -=3D c;
+			ret +=3D c;
+		}
+		restore_flags(flags);
+	}
+	/*
+	 * Hey, we transmit directly from here in our case
+	 */
+	if (CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE)
+	    && !tty->stopped && !tty->hw_stopped) {
+		transmit_chars(info, NULL);
+	}
+	return ret;
+}
+
+static int rs_write_room(struct tty_struct *tty)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+
+	return CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
+}
+
+static int rs_chars_in_buffer(struct tty_struct *tty)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+
+	return CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
+}
+
+static void rs_flush_buffer(struct tty_struct *tty)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+	unsigned long flags;
+
+	save_flags(flags); cli();
+	info->xmit.head =3D info->xmit.tail =3D 0;
+	restore_flags(flags);
+
+	wake_up_interruptible(&tty->write_wait);
+
+	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
+	    tty->ldisc.write_wakeup)
+		(tty->ldisc.write_wakeup)(tty);
+}
+
+/*
+ * This function is used to send a high-priority XON/XOFF character to
+ * the device
+ */
+static void rs_send_xchar(struct tty_struct *tty, char ch)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+
+	info->x_char =3D ch;
+	if (ch) {
+		/*
+		 * I guess we could call console->write() directly but
+		 * let's do that for now.
+		 */
+		transmit_chars(info, NULL);
+	}
+}
+
+/*
+ * ------------------------------------------------------------
+ * rs_throttle()
+ *
+ * This routine is called by the upper-layer tty layer to signal that
+ * incoming characters should be throttled.
+ * ------------------------------------------------------------
+ */
+static void rs_throttle(struct tty_struct * tty)
+{
+	if (I_IXOFF(tty)) rs_send_xchar(tty, STOP_CHAR(tty));
+
+	printk("simrs_throttle called\n");
+}
+
+static void rs_unthrottle(struct tty_struct * tty)
+{
+	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
+
+	if (I_IXOFF(tty)) {
+		if (info->x_char)
+			info->x_char =3D 0;
+		else
+			rs_send_xchar(tty, START_CHAR(tty));
+	}
+	printk("simrs_unthrottle called\n");
+}
+
+/*
+ * rs_break() --- routine which turns the break handling on or off
+ */
+static void rs_break(struct tty_struct *tty, int break_state)
+{
+}
+
+static int rs_ioctl(struct tty_struct *tty, struct file * file,
+		    unsigned int cmd, unsigned long arg)
+{
+	if ((cmd !=3D TIOCGSERIAL) && (cmd !=3D TIOCSSERIAL) &&
+	    (cmd !=3D TIOCSERCONFIG) && (cmd !=3D TIOCSERGSTRUCT) &&
+	    (cmd !=3D TIOCMIWAIT) && (cmd !=3D TIOCGICOUNT)) {
+		if (tty->flags & (1 << TTY_IO_ERROR))
+		    return -EIO;
+	}
+
+	switch (cmd) {
+		case TIOCMGET:
+			printk("rs_ioctl: TIOCMGET called\n");
+			return -EINVAL;
+		case TIOCMBIS:
+		case TIOCMBIC:
+		case TIOCMSET:
+			printk("rs_ioctl: TIOCMBIS/BIC/SET called\n");
+			return -EINVAL;
+		case TIOCGSERIAL:
+			printk("simrs_ioctl TIOCGSERIAL called\n");
+			return 0;
+		case TIOCSSERIAL:
+			printk("simrs_ioctl TIOCSSERIAL called\n");
+			return 0;
+		case TIOCSERCONFIG:
+			printk("rs_ioctl: TIOCSERCONFIG called\n");
+			return -EINVAL;
+
+		case TIOCSERGETLSR: /* Get line status register */
+			printk("rs_ioctl: TIOCSERGETLSR called\n");
+			return  -EINVAL;
+
+		case TIOCSERGSTRUCT:
+			printk("rs_ioctl: TIOCSERGSTRUCT called\n");
+#if 0
+			if (copy_to_user((struct async_struct *) arg,
+					 info, sizeof(struct async_struct)))
+				return -EFAULT;
+#endif
+			return 0;
+
+		/*
+		 * Wait for any of the 4 modem inputs (DCD,RI,DSR,CTS) to change
+		 * - mask passed in arg for lines of interest
+		 *   (use |'ed TIOCM_RNG/DSR/CD/CTS for masking)
+		 * Caller should use TIOCGICOUNT to see which one it was
+		 */
+		case TIOCMIWAIT:
+			printk("rs_ioctl: TIOCMIWAIT: called\n");
+			return 0;
+		/*
+		 * Get counter of input serial line interrupts (DCD,RI,DSR,CTS)
+		 * Return: write counters to the user passed counter struct
+		 * NB: both 1->0 and 0->1 transitions are counted except for
+		 *     RI where only 0->1 is counted.
+		 */
+		case TIOCGICOUNT:
+			printk("rs_ioctl: TIOCGICOUNT called\n");
+			return 0;
+
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
+#define RELEVANT_IFLAG(iflag) (iflag & (IGNBRK|BRKINT|IGNPAR|PARMRK|INPCK))
+
+static void rs_set_termios(struct tty_struct *tty, struct termios *old_ter=
mios)
+{
+	unsigned int cflag =3D tty->termios->c_cflag;
+
+	if (   (cflag =3D old_termios->c_cflag)
+	    && (   RELEVANT_IFLAG(tty->termios->c_iflag)
+		=3D RELEVANT_IFLAG(old_termios->c_iflag)))
+	  return;
+
+
+	/* Handle turning off CRTSCTS */
+	if ((old_termios->c_cflag & CRTSCTS) &&
+	    !(tty->termios->c_cflag & CRTSCTS)) {
+		tty->hw_stopped =3D 0;
+		rs_start(tty);
+	}
+}
+/*
+ * This routine will shutdown a serial port; interrupts are disabled, and
+ * DTR is dropped if the hangup on close termio flag is on.
+ */
+static void shutdown(struct async_struct * info)
+{
+	unsigned long	flags;
+	struct serial_state *state;
+	int		retval;
+
+	if (!(info->flags & ASYNC_INITIALIZED)) return;
+
+	state =3D info->state;
+
+#ifdef SIMSERIAL_DEBUG
+	printk("Shutting down serial port %d (irq %d)....", info->line,
+	       state->irq);
+#endif
+
+	save_flags(flags); cli(); /* Disable interrupts */
+
+	/*
+	 * First unlink the serial port from the IRQ chain...
+	 */
+	if (info->next_port)
+		info->next_port->prev_port =3D info->prev_port;
+	if (info->prev_port)
+		info->prev_port->next_port =3D info->next_port;
+	else
+		IRQ_ports[state->irq] =3D info->next_port;
+
+	/*
+	 * Free the IRQ, if necessary
+	 */
+	if (state->irq && (!IRQ_ports[state->irq] ||
+			  !IRQ_ports[state->irq]->next_port)) {
+		if (IRQ_ports[state->irq]) {
+			free_irq(state->irq, NULL);
+			retval =3D request_irq(state->irq, rs_interrupt_single,
+					     IRQ_T(info), "serial", NULL);
+
+			if (retval)
+				printk("serial shutdown: request_irq: error %d"
+				       "  Couldn't reacquire IRQ.\n", retval);
+		} else
+			free_irq(state->irq, NULL);
+	}
+
+	if (info->xmit.buf) {
+		free_page((unsigned long) info->xmit.buf);
+		info->xmit.buf =3D 0;
+	}
+
+	if (info->tty) set_bit(TTY_IO_ERROR, &info->tty->flags);
+
+	info->flags &=3D ~ASYNC_INITIALIZED;
+	restore_flags(flags);
+}
+
+/*
+ * ------------------------------------------------------------
+ * rs_close()
+ *
+ * This routine is called when the serial port gets closed.  First, we
+ * wait for the last remaining data to be sent.  Then, we unlink its
+ * async structure from the interrupt chain if necessary, and we free
+ * that IRQ if nothing is left in the chain.
+ * ------------------------------------------------------------
+ */
+static void rs_close(struct tty_struct *tty, struct file * filp)
+{
+	struct async_struct * info =3D (struct async_struct *)tty->driver_data;
+	struct serial_state *state;
+	unsigned long flags;
+
+	if (!info ) return;
+
+	state =3D info->state;
+
+	save_flags(flags); cli();
+
+	if (tty_hung_up_p(filp)) {
+#ifdef SIMSERIAL_DEBUG
+		printk("rs_close: hung_up\n");
+#endif
+		MOD_DEC_USE_COUNT;
+		restore_flags(flags);
+		return;
+	}
+#ifdef SIMSERIAL_DEBUG
+	printk("rs_close ttys%d, count =3D %d\n", info->line, state->count);
+#endif
+	if ((tty->count =3D 1) && (state->count !=3D 1)) {
+		/*
+		 * Uh, oh.  tty->count is 1, which means that the tty
+		 * structure will be freed.  state->count should always
+		 * be one in these conditions.  If it's greater than
+		 * one, we've got real problems, since it means the
+		 * serial port won't be shutdown.
+		 */
+		printk("rs_close: bad serial port count; tty->count is 1, "
+		       "state->count is %d\n", state->count);
+		state->count =3D 1;
+	}
+	if (--state->count < 0) {
+		printk("rs_close: bad serial port count for ttys%d: %d\n",
+		       info->line, state->count);
+		state->count =3D 0;
+	}
+	if (state->count) {
+		MOD_DEC_USE_COUNT;
+		restore_flags(flags);
+		return;
+	}
+	info->flags |=3D ASYNC_CLOSING;
+	restore_flags(flags);
+
+	/*
+	 * Now we wait for the transmit buffer to clear; and we notify
+	 * the line discipline to only process XON/XOFF characters.
+	 */
+	shutdown(info);
+	if (tty->driver.flush_buffer) tty->driver.flush_buffer(tty);
+	if (tty->ldisc.flush_buffer) tty->ldisc.flush_buffer(tty);
+	info->event =3D 0;
+	info->tty =3D 0;
+	if (info->blocked_open) {
+		if (info->close_delay) {
+			current->state =3D TASK_INTERRUPTIBLE;
+			schedule_timeout(info->close_delay);
+		}
+		wake_up_interruptible(&info->open_wait);
+	}
+	info->flags &=3D ~(ASYNC_NORMAL_ACTIVE|ASYNC_CALLOUT_ACTIVE|ASYNC_CLOSING=
);
+	wake_up_interruptible(&info->close_wait);
+	MOD_DEC_USE_COUNT;
+}
+
+/*
+ * rs_wait_until_sent() --- wait until the transmitter is empty
+ */
+static void rs_wait_until_sent(struct tty_struct *tty, int timeout)
+{
+}
+
+
+/*
+ * rs_hangup() --- called by tty_hangup() when a hangup is signaled.
+ */
+static void rs_hangup(struct tty_struct *tty)
+{
+	struct async_struct * info =3D (struct async_struct *)tty->driver_data;
+	struct serial_state *state =3D info->state;
+
+#ifdef SIMSERIAL_DEBUG
+	printk("rs_hangup: called\n");
+#endif
+
+	state =3D info->state;
+
+	rs_flush_buffer(tty);
+	if (info->flags & ASYNC_CLOSING)
+		return;
+	shutdown(info);
+
+	info->event =3D 0;
+	state->count =3D 0;
+	info->flags &=3D ~(ASYNC_NORMAL_ACTIVE|ASYNC_CALLOUT_ACTIVE);
+	info->tty =3D 0;
+	wake_up_interruptible(&info->open_wait);
+}
+
+
+static int get_async_struct(int line, struct async_struct **ret_info)
+{
+	struct async_struct *info;
+	struct serial_state *sstate;
+
+	sstate =3D rs_table + line;
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
+static int
+startup(struct async_struct *info)
+{
+	unsigned long flags;
+	int	retval=3D0;
+	void (*handler)(int, void *, struct pt_regs *);
+	struct serial_state *state=3D info->state;
+	unsigned long page;
+
+	page =3D get_free_page(GFP_KERNEL);
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
+	if (!state->port || !state->type) {
+		if (info->tty) set_bit(TTY_IO_ERROR, &info->tty->flags);
+		free_page(page);
+		goto errout;
+	}
+	if (info->xmit.buf)
+		free_page(page);
+	else
+		info->xmit.buf =3D (unsigned char *) page;
+
+#ifdef SIMSERIAL_DEBUG
+	printk("startup: ttys%d (irq %d)...", info->line, state->irq);
+#endif
+
+	/*
+	 * Allocate the IRQ if necessary
+	 */
+	if (state->irq && (!IRQ_ports[state->irq] ||
+			  !IRQ_ports[state->irq]->next_port)) {
+		if (IRQ_ports[state->irq]) {
+			retval =3D -EBUSY;
+			goto errout;
+		} else
+			handler =3D rs_interrupt_single;
+
+		retval =3D request_irq(state->irq, handler, IRQ_T(info),
+				     "simserial", NULL);
+		if (retval) {
+			if (capable(CAP_SYS_ADMIN)) {
+				if (info->tty)
+					set_bit(TTY_IO_ERROR,
+						&info->tty->flags);
+				retval =3D 0;
+			}
+			goto errout;
+		}
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
+	if (info->tty) clear_bit(TTY_IO_ERROR, &info->tty->flags);
+
+	info->xmit.head =3D info->xmit.tail =3D 0;
+
+#if 0
+	/*
+	 * Set up serial timers...
+	 */
+	timer_table[RS_TIMER].expires =3D jiffies + 2*HZ/100;
+	timer_active |=3D 1 << RS_TIMER;
+#endif
+
+	/*
+	 * Set up the tty->alt_speed kludge
+	 */
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
+
+	info->flags |=3D ASYNC_INITIALIZED;
+	restore_flags(flags);
+	return 0;
+
+errout:
+	restore_flags(flags);
+	return retval;
+}
+
+
+/*
+ * This routine is called whenever a serial port is opened.  It
+ * enables interrupts for a serial port, linking in its async structure in=
to
+ * the IRQ chain.   It also performs the serial-specific
+ * initialization for the tty structure.
+ */
+static int rs_open(struct tty_struct *tty, struct file * filp)
+{
+	struct async_struct	*info;
+	int			retval, line;
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
+
+#ifdef SIMSERIAL_DEBUG
+	printk("rs_open %s%d, count =3D %d\n", tty->driver.name, info->line,
+	       info->state->count);
+#endif
+	info->tty->low_latency =3D (info->flags & ASYNC_LOW_LATENCY) ? 1 : 0;
+
+	if (!tmp_buf) {
+		page =3D get_free_page(GFP_KERNEL);
+		if (!page) {
+			/* MOD_DEC_USE_COUNT; "info->tty" will cause this? */
+			return -ENOMEM;
+		}
+		if (tmp_buf)
+			free_page(page);
+		else
+			tmp_buf =3D (unsigned char *) page;
+	}
+
+	/*
+	 * If the port is the middle of closing, bail out now
+	 */
+	if (tty_hung_up_p(filp) ||
+	    (info->flags & ASYNC_CLOSING)) {
+		if (info->flags & ASYNC_CLOSING)
+			interruptible_sleep_on(&info->close_wait);
+		/* MOD_DEC_USE_COUNT; "info->tty" will cause this? */
+#ifdef SERIAL_DO_RESTART
+		return ((info->flags & ASYNC_HUP_NOTIFY) ?
+			-EAGAIN : -ERESTARTSYS);
+#else
+		return -EAGAIN;
+#endif
+	}
+
+	/*
+	 * Start up serial port
+	 */
+	retval =3D startup(info);
+	if (retval) {
+		/* MOD_DEC_USE_COUNT; "info->tty" will cause this? */
+		return retval;
+	}
+
+	if ((info->state->count =3D 1) &&
+	    (info->flags & ASYNC_SPLIT_TERMIOS)) {
+		if (tty->driver.subtype =3D SERIAL_TYPE_NORMAL)
+			*tty->termios =3D info->state->normal_termios;
+		else
+			*tty->termios =3D info->state->callout_termios;
+	}
+
+	/*
+	 * figure out which console to use (should be one already)
+	 */
+	console =3D console_drivers;
+	while (console) {
+		if ((console->flags & CON_ENABLED) && console->write) break;
+		console =3D console->next;
+	}
+
+	info->session =3D current->session;
+	info->pgrp =3D current->pgrp;
+
+#ifdef SIMSERIAL_DEBUG
+	printk("rs_open ttys%d successful\n", info->line);
+#endif
+	return 0;
+}
+
+/*
+ * /proc fs routines....
+ */
+
+static inline int line_info(char *buf, struct serial_state *state)
+{
+	return sprintf(buf, "%d: uart:%s port:%lX irq:%d\n",
+		       state->line, uart_config[state->type].name,
+		       state->port, state->irq);
+}
+
+static int rs_read_proc(char *page, char **start, off_t off, int count,
+		 int *eof, void *data)
+{
+	int i, len =3D 0, l;
+	off_t	begin =3D 0;
+
+	len +=3D sprintf(page, "simserinfo:1.0 driver:%s\n", serial_version);
+	for (i =3D 0; i < NR_PORTS && len < 4000; i++) {
+		l =3D line_info(page + len, &rs_table[i]);
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
+	*start =3D page + (begin-off);
+	return ((count < begin+len-off) ? count : begin+len-off);
+}
+
+/*
+ * ---------------------------------------------------------------------
+ * rs_init() and friends
+ *
+ * rs_init() is called at boot-time to initialize the serial driver.
+ * ---------------------------------------------------------------------
+ */
+
+/*
+ * This routine prints out the appropriate serial driver version
+ * number, and identifies which options were configured into this
+ * driver.
+ */
+static inline void show_serial_version(void)
+{
+	printk(KERN_INFO "%s version %s with", serial_name, serial_version);
+	printk(" no serial options enabled\n");
+}
+
+/*
+ * The serial driver boot-time initialization code!
+ */
+static int __init
+simrs_init (void)
+{
+	int			i;
+	struct serial_state	*state;
+
+	show_serial_version();
+
+	/* Initialize the tty_driver structure */
+
+	memset(&serial_driver, 0, sizeof(struct tty_driver));
+	serial_driver.magic =3D TTY_DRIVER_MAGIC;
+	serial_driver.driver_name =3D "simserial";
+	serial_driver.name =3D "ttyS";
+	serial_driver.major =3D TTY_MAJOR;
+	serial_driver.minor_start =3D 64;
+	serial_driver.num =3D 1;
+	serial_driver.type =3D TTY_DRIVER_TYPE_SERIAL;
+	serial_driver.subtype =3D SERIAL_TYPE_NORMAL;
+	serial_driver.init_termios =3D tty_std_termios;
+	serial_driver.init_termios.c_cflag +		B9600 | CS8 | CREAD | HUPCL | CLOCA=
L;
+	serial_driver.flags =3D TTY_DRIVER_REAL_RAW;
+	serial_driver.refcount =3D &serial_refcount;
+	serial_driver.table =3D serial_table;
+	serial_driver.termios =3D serial_termios;
+	serial_driver.termios_locked =3D serial_termios_locked;
+
+	serial_driver.open =3D rs_open;
+	serial_driver.close =3D rs_close;
+	serial_driver.write =3D rs_write;
+	serial_driver.put_char =3D rs_put_char;
+	serial_driver.flush_chars =3D rs_flush_chars;
+	serial_driver.write_room =3D rs_write_room;
+	serial_driver.chars_in_buffer =3D rs_chars_in_buffer;
+	serial_driver.flush_buffer =3D rs_flush_buffer;
+	serial_driver.ioctl =3D rs_ioctl;
+	serial_driver.throttle =3D rs_throttle;
+	serial_driver.unthrottle =3D rs_unthrottle;
+	serial_driver.send_xchar =3D rs_send_xchar;
+	serial_driver.set_termios =3D rs_set_termios;
+	serial_driver.stop =3D rs_stop;
+	serial_driver.start =3D rs_start;
+	serial_driver.hangup =3D rs_hangup;
+	serial_driver.break_ctl =3D rs_break;
+	serial_driver.wait_until_sent =3D rs_wait_until_sent;
+	serial_driver.read_proc =3D rs_read_proc;
+
+	/*
+	 * Let's have a little bit of fun !
+	 */
+	for (i =3D 0, state =3D rs_table; i < NR_PORTS; i++,state++) {
+
+		if (state->type =3D PORT_UNKNOWN) continue;
+
+		if (!state->irq) {
+			state->irq =3D ia64_alloc_vector();
+			ia64_ssc_connect_irq(KEYBOARD_INTR, state->irq);
+		}
+
+		printk(KERN_INFO "ttyS%02d at 0x%04lx (irq =3D %d) is a %s\n",
+		       state->line,
+		       state->port, state->irq,
+		       uart_config[state->type].name);
+	}
+	/*
+	 * The callout device is just like normal device except for
+	 * major number and the subtype code.
+	 */
+	callout_driver =3D serial_driver;
+	callout_driver.name =3D "cua";
+	callout_driver.major =3D TTYAUX_MAJOR;
+	callout_driver.subtype =3D SERIAL_TYPE_CALLOUT;
+	callout_driver.read_proc =3D 0;
+	callout_driver.proc_entry =3D 0;
+
+	if (tty_register_driver(&serial_driver))
+		panic("Couldn't register simserial driver\n");
+
+	if (tty_register_driver(&callout_driver))
+		panic("Couldn't register callout driver\n");
+
+	return 0;
+}
+
+#ifndef MODULE
+__initcall(simrs_init);
+#endif
diff -u -urN linux-2.4.20-ia64-021210/drivers/net/Makefile linux-ski/driver=
s/net/Makefile
--- linux-2.4.20-ia64-021210/drivers/net/Makefile	2002-11-28 16:53:13.00000=
0000 -0700
+++ linux-ski/drivers/net/Makefile	2002-12-13 10:04:07.000000000 -0700
@@ -142,6 +142,7 @@
 obj-$(CONFIG_LNE390) +=3D lne390.o 8390.o
 obj-$(CONFIG_NE3210) +=3D ne3210.o 8390.o
 obj-$(CONFIG_NET_SB1250_MAC) +=3D sb1250-mac.o
+obj-$(CONFIG_HP_SIMETH) +=3D simeth.o
=20
 obj-$(CONFIG_PPP) +=3D ppp_generic.o slhc.o
 obj-$(CONFIG_PPP_ASYNC) +=3D ppp_async.o
diff -u -urN linux-2.4.20-ia64-021210/drivers/net/simeth.c linux-ski/driver=
s/net/simeth.c
--- linux-2.4.20-ia64-021210/drivers/net/simeth.c	1969-12-31 17:00:00.00000=
0000 -0700
+++ linux-ski/drivers/net/simeth.c	2002-12-13 10:04:07.000000000 -0700
@@ -0,0 +1,533 @@
+/*
+ * Simulated Ethernet Driver
+ *
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ * Copyright (C) 1999-2001 Stephane Eranain <eranian@hpl.hp.com>
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+#include <linux/in.h>
+#include <linux/string.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_arp.h>
+#include <linux/skbuff.h>
+#include <linux/notifier.h>
+#include <asm/bitops.h>
+#include <asm/system.h>
+#include <asm/irq.h>
+
+#define SIMETH_RECV_MAX	10
+
+/*
+ * Maximum possible received frame for Ethernet.
+ * We preallocate an sk_buff of that size to avoid costly=20
+ * memcpy for temporary buffer into sk_buff. We do basically
+ * what's done in other drivers, like eepro with a ring.
+ * The difference is, of course, that we don't have real DMA !!!
+ */
+#define SIMETH_FRAME_SIZE	ETH_FRAME_LEN=09
+
+
+#define SSC_NETDEV_PROBE		100
+#define SSC_NETDEV_SEND			101
+#define SSC_NETDEV_RECV			102
+#define SSC_NETDEV_ATTACH		103
+#define SSC_NETDEV_DETACH		104
+
+#define NETWORK_INTR			8
+
+struct simeth_local {
+	struct net_device_stats stats;
+	int 			simfd;	 /* descriptor in the simulator */
+};
+
+static int simeth_probe1(void);
+static int simeth_open(struct net_device *dev);
+static int simeth_close(struct net_device *dev);
+static int simeth_tx(struct sk_buff *skb, struct net_device *dev);
+static int simeth_rx(struct net_device *dev);
+static struct net_device_stats *simeth_get_stats(struct net_device *dev);
+static void simeth_interrupt(int irq, void *dev_id, struct pt_regs * regs);
+static void set_multicast_list(struct net_device *dev);
+static int simeth_device_event(struct notifier_block *this,unsigned long e=
vent, void *ptr);
+
+static char *simeth_version=3D"0.3";
+
+/*
+ * This variable is used to establish a mapping between the Linux/ia64 ker=
nel
+ * and the host linux kernel.
+ *
+ * As of today, we support only one card, even though most of the code
+ * is ready for many more. The mapping is then:
+ *	linux/ia64 -> linux/x86
+ * 	   eth0    -> eth1
+ *
+ * In the future, we some string operations, we could easily support up
+ * to 10 cards (0-9).
+ *
+ * The default mapping can be changed on the kernel command line by
+ * specifying simeth=3DethX (or whatever string you want).
+ */
+static char *simeth_device=3D"eth0";	 /* default host interface to use */
+
+
+
+static volatile unsigned int card_count; /* how many cards "found" so far =
*/
+static int simeth_debug;		/* set to 1 to get debug information */
+
+/*
+ * Used to catch IFF_UP & IFF_DOWN events
+ */
+static struct notifier_block simeth_dev_notifier =3D {
+	simeth_device_event,
+	0
+};
+
+
+/*
+ * Function used when using a kernel command line option.
+ *
+ * Format: simeth=3Dinterface_name (like eth0)
+ */
+static int __init
+simeth_setup(char *str)
+{
+	simeth_device =3D str;
+	return 1;
+}
+
+__setup("simeth=3D", simeth_setup);
+
+/*
+ * Function used to probe for simeth devices when not installed
+ * as a loadable module
+ */
+
+int __init
+simeth_probe (void)
+{
+	int r;
+
+	printk("simeth: v%s\n", simeth_version);
+
+	r =3D simeth_probe1();
+
+	if (r =3D 0) register_netdevice_notifier(&simeth_dev_notifier);
+
+	return r;
+}
+
+extern long ia64_ssc (long, long, long, long, int);
+extern void ia64_ssc_connect_irq (long intr, long irq);
+
+static inline int
+netdev_probe(char *name, unsigned char *ether)
+{
+	return ia64_ssc(__pa(name), __pa(ether), 0,0, SSC_NETDEV_PROBE);
+}
+
+
+static inline int
+netdev_connect(int irq)
+{
+	/* XXX Fix me
+	 * this does not support multiple cards
+	 * also no return value
+	 */
+	ia64_ssc_connect_irq(NETWORK_INTR, irq);
+	return 0;
+}
+
+static inline int
+netdev_attach(int fd, int irq, unsigned int ipaddr)
+{
+	/* this puts the host interface in the right mode (start interupting) */
+	return ia64_ssc(fd, ipaddr, 0,0, SSC_NETDEV_ATTACH);
+}
+
+
+static inline int
+netdev_detach(int fd)
+{
+	/*
+	 * inactivate the host interface (don't interrupt anymore) */
+	return ia64_ssc(fd, 0,0,0, SSC_NETDEV_DETACH);
+}
+
+static inline int
+netdev_send(int fd, unsigned char *buf, unsigned int len)
+{
+	return ia64_ssc(fd, __pa(buf), len, 0, SSC_NETDEV_SEND);
+}
+
+static inline int
+netdev_read(int fd, unsigned char *buf, unsigned int len)
+{
+	return ia64_ssc(fd, __pa(buf), len, 0, SSC_NETDEV_RECV);
+}
+
+/*
+ * Function shared with module code, so cannot be in init section
+ *
+ * So far this function "detects" only one card (test_&_set) but could=20
+ * be extended easily.
+ *
+ * Return:
+ * 	- -ENODEV is no device found
+ *	- -ENOMEM is no more memory
+ *	- 0 otherwise
+ */
+static int
+simeth_probe1(void)
+{
+	unsigned char mac_addr[ETH_ALEN];
+	struct simeth_local *local;
+	struct net_device *dev;
+	int fd, i;
+
+	/*
+	 * XXX Fix me
+	 * let's support just one card for now
+	 */
+	if (test_and_set_bit(0, &card_count))
+		return -ENODEV;
+
+	/*
+	 * check with the simulator for the device
+	 */
+	fd =3D netdev_probe(simeth_device, mac_addr);
+	if (fd =3D -1)
+		return -ENODEV;
+
+	dev =3D init_etherdev(NULL, sizeof(struct simeth_local));
+	if (!dev)
+		return -ENOMEM;
+
+	memcpy(dev->dev_addr, mac_addr, sizeof(mac_addr));
+
+	dev->irq =3D ia64_alloc_vector();
+
+	/*
+	 * attach the interrupt in the simulator, this does enable interrupts
+	 * until a netdev_attach() is called
+	 */
+	netdev_connect(dev->irq);
+
+	memset(dev->priv, 0, sizeof(struct simeth_local));
+
+	local =3D dev->priv;
+	local->simfd =3D fd; /* keep track of underlying file descriptor */
+
+	dev->open		=3D simeth_open;
+	dev->stop		=3D simeth_close;
+	dev->hard_start_xmit	=3D simeth_tx;
+	dev->get_stats		=3D simeth_get_stats;
+	dev->set_multicast_list =3D set_multicast_list; /* no yet used */
+
+	/* Fill in the fields of the device structure with ethernet-generic value=
s. */
+	ether_setup(dev);
+
+	printk("%s: hosteth=3D%s simfd=3D%d, HwAddr", dev->name, simeth_device, l=
ocal->simfd);
+	for(i =3D 0; i < ETH_ALEN; i++) {
+		printk(" %2.2x", dev->dev_addr[i]);
+	}
+	printk(", IRQ %d\n", dev->irq);
+
+		return 0;
+}
+
+/*
+ * actually binds the device to an interrupt vector
+ */
+static int
+simeth_open(struct net_device *dev)
+{
+	if (request_irq(dev->irq, simeth_interrupt, 0, "simeth", dev)) {
+		printk ("simeth: unable to get IRQ %d.\n", dev->irq);
+		return -EAGAIN;
+	}
+
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+/* copied from lapbether.c */
+static __inline__ int dev_is_ethdev(struct net_device *dev)
+{
+       return ( dev->type =3D ARPHRD_ETHER && strncmp(dev->name, "dummy", =
5));
+}
+
+
+/*
+ * Handler for IFF_UP or IFF_DOWN
+ *
+ * The reason for that is that we don't want to be interrupted when the
+ * interface is down. There is no way to unconnect in the simualtor. Inste=
ad
+ * we use this function to shutdown packet processing in the frame filter =

+ * in the simulator. Thus no interrupts are generated
+ *
+ *
+ * That's also the place where we pass the IP address of this device to the
+ * simulator so that that we can start filtering packets for it
+ *
+ * There may be a better way of doing this, but I don't know which yet.
+ */
+static int
+simeth_device_event(struct notifier_block *this,unsigned long event, void =
*ptr)
+{
+	struct net_device *dev =3D (struct net_device *)ptr;
+	struct simeth_local *local;
+	struct in_device *in_dev;
+	struct in_ifaddr **ifap =3D NULL;
+	struct in_ifaddr *ifa =3D NULL;
+	int r;
+
+
+	if ( ! dev ) {
+		printk(KERN_WARNING "simeth_device_event dev=3D0\n");
+		return NOTIFY_DONE;
+	}
+
+	if ( event !=3D NETDEV_UP && event !=3D NETDEV_DOWN ) return NOTIFY_DONE;
+
+	/*
+	 * Check whether or not it's for an ethernet device
+	 *
+	 * XXX Fixme: This works only as long as we support one
+	 * type of ethernet device.
+	 */
+	if ( !dev_is_ethdev(dev) ) return NOTIFY_DONE;
+
+	if ((in_dev=DEv->ip_ptr) !=3D NULL) {
+		for (ifap=3D&in_dev->ifa_list; (ifa=3D*ifap) !=3D NULL; ifap=3D&ifa->ifa=
_next)
+			if (strcmp(dev->name, ifa->ifa_label) =3D 0) break;
+	}
+	if ( ifa =3D NULL ) {
+		printk("simeth_open: can't find device %s's ifa\n", dev->name);
+		return NOTIFY_DONE;
+	}
+
+	printk("simeth_device_event: %s ipaddr=3D0x%x\n", dev->name, htonl(ifa->i=
fa_local));
+
+	/*
+	 * XXX Fix me
+	 * if the device was up, and we're simply reconfiguring it, not sure
+	 * we get DOWN then UP.
+	 */
+
+	local =3D dev->priv;
+	/* now do it for real */
+	r =3D event =3D NETDEV_UP ?=20
+		netdev_attach(local->simfd, dev->irq, htonl(ifa->ifa_local)):
+		netdev_detach(local->simfd);
+
+	printk("simeth: netdev_attach/detach: event=3D%s ->%d\n", event =3D NETDE=
V_UP ? "attach":"detach", r);
+
+	return NOTIFY_DONE;
+}
+
+static int
+simeth_close(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+
+	free_irq(dev->irq, dev);
+
+	return 0;
+}
+
+/*
+ * Only used for debug
+ */
+static void
+frame_print(unsigned char *from, unsigned char *frame, int len)
+{
+	int i;
+
+	printk("%s: (%d) %02x", from, len, frame[0] & 0xff);
+	for(i=3D1; i < 6; i++ ) {
+		printk(":%02x", frame[i] &0xff);
+	}
+	printk(" %2x", frame[6] &0xff);
+	for(i=3D7; i < 12; i++ ) {
+		printk(":%02x", frame[i] &0xff);
+	}
+	printk(" [%02x%02x]\n", frame[12], frame[13]);
+
+	for(i=14; i < len; i++ ) {
+		printk("%02x ", frame[i] &0xff);
+		if ( (i%10)=3D0) printk("\n");
+	}
+	printk("\n");
+}
+
+
+/*
+ * Function used to transmit of frame, very last one on the path before
+ * going to the simulator.
+ */
+static int
+simeth_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct simeth_local *local =3D (struct simeth_local *)dev->priv;
+
+#if 0
+	/* ensure we have at least ETH_ZLEN bytes (min frame size) */
+	unsigned int length =3D ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
+	/* Where do the extra padding bytes comes from inthe skbuff ? */
+#else
+	/* the real driver in the host system is going to take care of that
+	 * or maybe it's the NIC itself.
+	 */
+	unsigned int length =3D skb->len;
+#endif
+
+	local->stats.tx_bytes +=3D skb->len;
+	local->stats.tx_packets++;
+
+
+	if (simeth_debug > 5) frame_print("simeth_tx", skb->data, length);
+
+	netdev_send(local->simfd, skb->data, length);
+
+	/*
+	 * we are synchronous on write, so we don't simulate a
+	 * trasnmit complete interrupt, thus we don't need to arm a tx
+	 */
+
+	dev_kfree_skb(skb);
+	return 0;
+}
+
+static inline struct sk_buff *=20
+make_new_skb(struct net_device *dev)
+{
+	struct sk_buff *nskb;
+
+	/*
+	 * The +2 is used to make sure that the IP header is nicely
+	 * aligned (on 4byte boundary I assume 14+2=16)
+	 */
+	nskb =3D dev_alloc_skb(SIMETH_FRAME_SIZE + 2);
+	if ( nskb =3D NULL ) {
+		printk(KERN_NOTICE "%s: memory squeeze. dropping packet.\n", dev->name);
+		return NULL;
+	}
+	nskb->dev =3D dev;
+
+	skb_reserve(nskb, 2);	/* Align IP on 16 byte boundaries */
+
+	skb_put(nskb,SIMETH_FRAME_SIZE);
+
+	return nskb;
+}
+
+/*
+ * called from interrupt handler to process a received frame
+ */
+static int
+simeth_rx(struct net_device *dev)
+{
+	struct simeth_local	*local;
+	struct sk_buff		*skb;
+	int			len;
+	int			rcv_count =3D SIMETH_RECV_MAX;
+
+	local =3D (struct simeth_local *)dev->priv;
+	/*
+	 * the loop concept has been borrowed from other drivers
+	 * looks to me like it's a throttling thing to avoid pushing to many
+	 * packets at one time into the stack. Making sure we can process them
+	 * upstream and make forward progress overall
+	 */
+	do {=20
+		if ( (skb=3Dmake_new_skb(dev)) =3D NULL ) {
+			printk(KERN_NOTICE "%s: memory squeeze. dropping packet.\n", dev->name);
+			local->stats.rx_dropped++;
+			return 0;
+		}
+		/*
+		 * Read only one frame at a time
+		 */
+		len =3D netdev_read(local->simfd, skb->data, SIMETH_FRAME_SIZE);
+		if ( len =3D 0 ) {
+			if ( simeth_debug > 0 ) printk(KERN_WARNING "%s: count=3D%d netdev_read=
=3D0\n", dev->name, SIMETH_RECV_MAX-rcv_count);
+			break;
+		}
+#if 0
+		/*
+		 * XXX Fix me
+		 * Should really do a csum+copy here
+		 */
+		memcpy(skb->data, frame, len);
+#endif
+		skb->protocol =3D eth_type_trans(skb, dev);
+
+		if ( simeth_debug > 6 ) frame_print("simeth_rx", skb->data, len);
+
+		/*
+		 * push the packet up & trigger software interrupt
+		 */
+		netif_rx(skb);
+
+		local->stats.rx_packets++;
+		local->stats.rx_bytes +=3D len;
+
+	} while ( --rcv_count );
+
+	return len; /* 0 =3D nothing left to read, otherwise, we can try again */
+}
+
+/*
+ * Interrupt handler (Yes, we can do it too !!!)
+ */
+static void
+simeth_interrupt(int irq, void *dev_id, struct pt_regs * regs)
+{
+	struct net_device *dev =3D dev_id;
+
+	if ( dev =3D NULL ) {
+		printk(KERN_WARNING "simeth: irq %d for unknown device\n", irq);
+		return;
+	}
+
+	/*
+	 * very simple loop because we get interrupts only when receving
+	 */
+	while (simeth_rx(dev));
+}
+
+static struct net_device_stats *
+simeth_get_stats(struct net_device *dev)
+{
+	struct simeth_local  *local =3D (struct simeth_local *) dev->priv;
+
+	return &local->stats;
+}
+
+/* fake multicast ability */
+static void
+set_multicast_list(struct net_device *dev)
+{
+	printk(KERN_WARNING "%s: set_multicast_list called\n", dev->name);
+}
+
+#ifdef CONFIG_NET_FASTROUTE
+static int
+simeth_accept_fastpath(struct net_device *dev, struct dst_entry *dst)
+{
+	printk(KERN_WARNING "%s: simeth_accept_fastpath called\n", dev->name);
+	return -1;
+}
+#endif
+
+__initcall(simeth_probe);
diff -u -urN linux-2.4.20-ia64-021210/drivers/scsi/Makefile linux-ski/drive=
rs/scsi/Makefile
--- linux-2.4.20-ia64-021210/drivers/scsi/Makefile	2002-12-10 14:23:20.0000=
00000 -0700
+++ linux-ski/drivers/scsi/Makefile	2002-12-13 10:04:07.000000000 -0700
@@ -53,6 +53,7 @@
 obj-$(CONFIG_SUN3_SCSI)		+=3D sun3_scsi.o
 obj-$(CONFIG_MVME16x_SCSI)	+=3D mvme16x.o	53c7xx.o
 obj-$(CONFIG_BVME6000_SCSI)	+=3D bvme6000.o	53c7xx.o
+obj-$(CONFIG_HP_SIMSCSI)	+=3D simscsi.o
 obj-$(CONFIG_SCSI_SIM710)	+=3D sim710.o
 obj-$(CONFIG_SCSI_ADVANSYS)	+=3D advansys.o
 obj-$(CONFIG_SCSI_PCI2000)	+=3D pci2000.o
diff -u -urN linux-2.4.20-ia64-021210/drivers/scsi/simscsi.c linux-ski/driv=
ers/scsi/simscsi.c
--- linux-2.4.20-ia64-021210/drivers/scsi/simscsi.c	1969-12-31 17:00:00.000=
000000 -0700
+++ linux-ski/drivers/scsi/simscsi.c	2002-12-13 10:04:07.000000000 -0700
@@ -0,0 +1,395 @@
+/*
+ * Simulated SCSI driver.
+ *
+ * Copyright (C) 1999, 2001-2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ *
+ * 02/01/15 David Mosberger	Updated for v2.5.1
+ * 99/12/18 David Mosberger	Added support for READ10/WRITE10 needed by lin=
ux v2.3.33
+ */
+#include <linux/config.h>
+#include <linux/blk.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/kernel.h>
+#include <linux/timer.h>
+
+#include <scsi/scsi.h>
+
+#include <asm/irq.h>
+
+#include "scsi.h"
+#include "sd.h"
+#include "hosts.h"
+#include "simscsi.h"
+
+#define DEBUG_SIMSCSI	1
+
+/* Simulator system calls: */
+
+#define SSC_OPEN			50
+#define SSC_CLOSE			51
+#define SSC_READ			52
+#define SSC_WRITE			53
+#define SSC_GET_COMPLETION		54
+#define SSC_WAIT_COMPLETION		55
+
+#define SSC_WRITE_ACCESS		2
+#define SSC_READ_ACCESS			1
+
+#if DEBUG_SIMSCSI
+  int simscsi_debug;
+# define DBG	simscsi_debug
+#else
+# define DBG	0
+#endif
+
+static void simscsi_interrupt (unsigned long val);
+DECLARE_TASKLET(simscsi_tasklet, simscsi_interrupt, 0);
+
+struct disk_req {
+	unsigned long addr;
+	unsigned len;
+};
+
+struct disk_stat {
+	int fd;
+	unsigned count;
+};
+
+extern long ia64_ssc (long arg0, long arg1, long arg2, long arg3, int nr);
+
+static int desc[16] =3D {
+	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
+};
+
+static struct queue_entry {
+	Scsi_Cmnd *sc;
+} queue[SIMSCSI_REQ_QUEUE_LEN];
+
+static int rd, wr;
+static atomic_t num_reqs =3D ATOMIC_INIT(0);
+
+/* base name for default disks */
+static char *simscsi_root =3D DEFAULT_SIMSCSI_ROOT;
+
+#define MAX_ROOT_LEN	128
+
+/*
+ * used to setup a new base for disk images
+ * to use /foo/bar/disk[a-z] as disk images
+ * you have to specify simscsi=3D/foo/bar/disk on the command line
+ */
+static int __init
+simscsi_setup (char *s)
+{
+	/* XXX Fix me we may need to strcpy() ? */
+	if (strlen(s) > MAX_ROOT_LEN) {
+		printk("simscsi_setup: prefix too long---using default %s\n", simscsi_ro=
ot);
+	}
+	simscsi_root =3D s;
+	return 1;
+}
+
+__setup("simscsi=3D", simscsi_setup);
+
+static void
+simscsi_interrupt (unsigned long val)
+{
+	unsigned long flags;
+	Scsi_Cmnd *sc;
+
+	spin_lock_irqsave(&io_request_lock, flags);
+	{
+		while ((sc =3D queue[rd].sc) !=3D 0) {
+			atomic_dec(&num_reqs);
+			queue[rd].sc =3D 0;
+			if (DBG)
+				printk("simscsi_interrupt: done with %ld\n", sc->serial_number);
+			(*sc->scsi_done)(sc);
+			rd =3D (rd + 1) % SIMSCSI_REQ_QUEUE_LEN;
+		}
+	}
+	spin_unlock_irqrestore(&io_request_lock, flags);
+}
+
+int
+simscsi_detect (Scsi_Host_Template *templ)
+{
+	templ->proc_name =3D "simscsi";
+	return 1;	/* fake one SCSI host adapter */
+}
+
+int
+simscsi_release (struct Scsi_Host *host)
+{
+	return 0;	/* this is easy...  */
+}
+
+const char *
+simscsi_info (struct Scsi_Host *host)
+{
+	return "simulated SCSI host adapter";
+}
+
+int
+simscsi_biosparam (Disk *disk, kdev_t n, int ip[])
+{
+	unsigned capacity =3D disk->capacity;
+
+	ip[0] =3D 64;		/* heads */
+	ip[1] =3D 32;		/* sectors */
+	ip[2] =3D capacity >> 11;	/* cylinders */
+	return 0;
+}
+
+static void
+simscsi_readwrite (Scsi_Cmnd *sc, int mode, unsigned long offset, unsigned=
 long len)
+{
+	struct disk_stat stat;
+	struct disk_req req;
+
+	req.addr =3D __pa(sc->request_buffer);
+	req.len  =3D len;			/* # of bytes to transfer */
+
+	if (sc->request_bufflen < req.len)
+		return;
+
+	stat.fd =3D desc[sc->target];
+	if (DBG)
+		printk("simscsi_%s @ %lx (off %lx)\n",
+		       mode =3D SSC_READ ? "read":"write", req.addr, offset);
+	ia64_ssc(stat.fd, 1, __pa(&req), offset, mode);
+	ia64_ssc(__pa(&stat), 0, 0, 0, SSC_WAIT_COMPLETION);
+
+	if (stat.count =3D req.len) {
+		sc->result =3D GOOD;
+	} else {
+		sc->result =3D DID_ERROR << 16;
+	}
+}
+
+static void
+simscsi_sg_readwrite (Scsi_Cmnd *sc, int mode, unsigned long offset)
+{
+	int list_len =3D sc->use_sg;
+	struct scatterlist *sl =3D (struct scatterlist *)sc->buffer;
+	struct disk_stat stat;
+	struct disk_req req;
+
+	stat.fd =3D desc[sc->target];
+
+	while (list_len) {
+		req.addr =3D __pa(sl->address);
+		req.len  =3D sl->length;
+		if (DBG)
+			printk("simscsi_sg_%s @ %lx (off %lx) use_sg=3D%d len=3D%d\n",
+			       mode =3D SSC_READ ? "read":"write", req.addr, offset,
+			       list_len, sl->length);
+		ia64_ssc(stat.fd, 1, __pa(&req), offset, mode);
+		ia64_ssc(__pa(&stat), 0, 0, 0, SSC_WAIT_COMPLETION);
+
+		/* should not happen in our case */
+		if (stat.count !=3D req.len) {
+			sc->result =3D DID_ERROR << 16;
+			return;
+		}
+		offset +=3D  sl->length;
+		sl++;
+		list_len--;
+	}
+	sc->result =3D GOOD;
+}
+
+/*
+ * function handling both READ_6/WRITE_6 (non-scatter/gather mode)
+ * commands.
+ * Added 02/26/99 S.Eranian
+ */
+static void
+simscsi_readwrite6 (Scsi_Cmnd *sc, int mode)
+{
+	unsigned long offset;
+
+	offset =3D (((sc->cmnd[1] & 0x1f) << 16) | (sc->cmnd[2] << 8) | sc->cmnd[=
3])*512;
+	if (sc->use_sg > 0)
+		simscsi_sg_readwrite(sc, mode, offset);
+	else
+		simscsi_readwrite(sc, mode, offset, sc->cmnd[4]*512);
+}
+
+static size_t
+simscsi_get_disk_size (int fd)
+{
+	struct disk_stat stat;
+	size_t bit, sectors =3D 0;
+	struct disk_req req;
+	char buf[512];
+
+	/*
+	 * This is a bit kludgey: the simulator doesn't provide a direct way of d=
etermining
+	 * the disk size, so we do a binary search, assuming a maximum disk size =
of 4GB.
+	 */
+	for (bit =3D (4UL << 30)/512; bit !=3D 0; bit >>=3D 1) {
+		req.addr =3D __pa(&buf);
+		req.len =3D sizeof(buf);
+		ia64_ssc(fd, 1, __pa(&req), ((sectors | bit) - 1)*512, SSC_READ);
+		stat.fd =3D fd;
+		ia64_ssc(__pa(&stat), 0, 0, 0, SSC_WAIT_COMPLETION);
+		if (stat.count =3D sizeof(buf))
+			sectors |=3D bit;
+	}
+	return sectors - 1;	/* return last valid sector number */
+}
+
+static void
+simscsi_readwrite10 (Scsi_Cmnd *sc, int mode)
+{
+	unsigned long offset;
+
+	offset =3D (  (sc->cmnd[2] << 24) | (sc->cmnd[3] << 16)
+		  | (sc->cmnd[4] <<  8) | (sc->cmnd[5] <<  0))*512;
+	if (sc->use_sg > 0)
+		simscsi_sg_readwrite(sc, mode, offset);
+	else
+		simscsi_readwrite(sc, mode, offset, ((sc->cmnd[7] << 8) | sc->cmnd[8])*5=
12);
+}
+
+int
+simscsi_queuecommand (Scsi_Cmnd *sc, void (*done)(Scsi_Cmnd *))
+{
+	char fname[MAX_ROOT_LEN+16];
+	size_t disk_size;
+	char *buf;
+#if DEBUG_SIMSCSI
+	register long sp asm ("sp");
+
+	if (DBG)
+		printk("simscsi_queuecommand: target=3D%d,cmnd=3D%u,sc=3D%lu,sp=3D%lx,do=
ne=3D%p\n",
+		       sc->target, sc->cmnd[0], sc->serial_number, sp, done);
+#endif
+
+	sc->result =3D DID_BAD_TARGET << 16;
+	sc->scsi_done =3D done;
+	if (sc->target <=3D 15 && sc->lun =3D 0) {
+		switch (sc->cmnd[0]) {
+		      case INQUIRY:
+			if (sc->request_bufflen < 35) {
+				break;
+			}
+			sprintf (fname, "%s%c", simscsi_root, 'a' + sc->target);
+			desc[sc->target] =3D ia64_ssc(__pa(fname), SSC_READ_ACCESS|SSC_WRITE_AC=
CESS,
+						    0, 0, SSC_OPEN);
+			if (desc[sc->target] < 0) {
+				/* disk doesn't exist... */
+				break;
+			}
+			buf =3D sc->request_buffer;
+			buf[0] =3D 0;	/* magnetic disk */
+			buf[1] =3D 0;	/* not a removable medium */
+			buf[2] =3D 2;	/* SCSI-2 compliant device */
+			buf[3] =3D 2;	/* SCSI-2 response data format */
+			buf[4] =3D 31;	/* additional length (bytes) */
+			buf[5] =3D 0;	/* reserved */
+			buf[6] =3D 0;	/* reserved */
+			buf[7] =3D 0;	/* various flags */
+			memcpy(buf + 8, "HP      SIMULATED DISK  0.00",  28);
+			sc->result =3D GOOD;
+			break;
+
+		      case TEST_UNIT_READY:
+			sc->result =3D GOOD;
+			break;
+
+		      case READ_6:
+			if (desc[sc->target] < 0 )
+				break;
+			simscsi_readwrite6(sc, SSC_READ);
+			break;
+
+		      case READ_10:
+			if (desc[sc->target] < 0 )
+				break;
+			simscsi_readwrite10(sc, SSC_READ);
+			break;
+
+		      case WRITE_6:
+			if (desc[sc->target] < 0)
+				break;
+			simscsi_readwrite6(sc, SSC_WRITE);
+			break;
+
+		      case WRITE_10:
+			if (desc[sc->target] < 0)
+				break;
+			simscsi_readwrite10(sc, SSC_WRITE);
+			break;
+
+
+		      case READ_CAPACITY:
+			if (desc[sc->target] < 0 || sc->request_bufflen < 8) {
+				break;
+			}
+			buf =3D sc->request_buffer;
+
+			disk_size =3D simscsi_get_disk_size(desc[sc->target]);
+			buf[0] =3D (disk_size >> 24) & 0xff;
+			buf[1] =3D (disk_size >> 16) & 0xff;
+			buf[2] =3D (disk_size >>  8) & 0xff;
+			buf[3] =3D (disk_size >>  0) & 0xff;
+			/* set block size of 512 bytes: */
+			buf[4] =3D 0;
+			buf[5] =3D 0;
+			buf[6] =3D 2;
+			buf[7] =3D 0;
+			sc->result =3D GOOD;
+			break;
+
+		      case MODE_SENSE:
+			/* sd.c uses this to determine whether disk does write-caching. */
+			memset(sc->request_buffer, 0, 128);
+			sc->result =3D GOOD;
+			break;
+
+		      case START_STOP:
+			printk("START_STOP\n");
+			break;
+
+		      default:
+			panic("simscsi: unknown SCSI command %u\n", sc->cmnd[0]);
+		}
+	}
+	if (sc->result =3D DID_BAD_TARGET) {
+		sc->result |=3D DRIVER_SENSE << 24;
+		sc->sense_buffer[0] =3D 0x70;
+		sc->sense_buffer[2] =3D 0x00;
+	}
+	if (atomic_read(&num_reqs) >=3D SIMSCSI_REQ_QUEUE_LEN) {
+		panic("Attempt to queue command while command is pending!!");
+	}
+	atomic_inc(&num_reqs);
+	queue[wr].sc =3D sc;
+	wr =3D (wr + 1) % SIMSCSI_REQ_QUEUE_LEN;
+
+	tasklet_schedule(&simscsi_tasklet);
+	return 0;
+}
+
+int
+simscsi_reset (Scsi_Cmnd *cmd, unsigned int reset_flags)
+{
+	printk ("simscsi_reset: unimplemented\n");
+	return SCSI_RESET_SUCCESS;
+}
+
+int
+simscsi_abort (Scsi_Cmnd *cmd)
+{
+	printk ("simscsi_abort: unimplemented\n");
+	return SCSI_ABORT_SUCCESS;
+}
+
+static Scsi_Host_Template driver_template =3D SIMSCSI;
+
+#include "scsi_module.c"
diff -u -urN linux-2.4.20-ia64-021210/drivers/scsi/simscsi.h linux-ski/driv=
ers/scsi/simscsi.h
--- linux-2.4.20-ia64-021210/drivers/scsi/simscsi.h	1969-12-31 17:00:00.000=
000000 -0700
+++ linux-ski/drivers/scsi/simscsi.h	2002-12-13 10:04:07.000000000 -0700
@@ -0,0 +1,39 @@
+/*
+ * Simulated SCSI driver.
+ *
+ * Copyright (C) 1999, 2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ */
+#ifndef SIMSCSI_H
+#define SIMSCSI_H
+
+#define SIMSCSI_REQ_QUEUE_LEN	64
+
+#define DEFAULT_SIMSCSI_ROOT	"/var/ski-disks/sd"
+
+extern int simscsi_detect (Scsi_Host_Template *);
+extern int simscsi_release (struct Scsi_Host *);
+extern const char *simscsi_info (struct Scsi_Host *);
+extern int simscsi_queuecommand (Scsi_Cmnd *, void (*done)(Scsi_Cmnd *));
+extern int simscsi_abort (Scsi_Cmnd *);
+extern int simscsi_reset (Scsi_Cmnd *, unsigned int);
+extern int simscsi_biosparam (Disk *, kdev_t, int[]);
+
+#define SIMSCSI {						\
+	.detect			=3D simscsi_detect,		\
+	.release		=3D simscsi_release,		\
+	.info			=3D simscsi_info,			\
+	.queuecommand		=3D simscsi_queuecommand,		\
+	.abort			=3D simscsi_abort,		\
+	.reset			=3D simscsi_reset,		\
+	.bios_param		=3D simscsi_biosparam,		\
+	.can_queue		=3D SIMSCSI_REQ_QUEUE_LEN,	\
+	.this_id		=3D -1,				\
+	.sg_tablesize		=3D SG_ALL,			\
+	.cmd_per_lun		=3D SIMSCSI_REQ_QUEUE_LEN,	\
+	.present		=3D 0,				\
+	.unchecked_isa_dma	=3D 0,				\
+	.use_clustering		=3D DISABLE_CLUSTERING		\
+}
+
+#endif /* SIMSCSI_H */


