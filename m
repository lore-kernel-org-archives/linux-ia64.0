From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Thu, 25 Jan 2001 00:19:48 +0000
Subject: Re: [Linux-ia64] IA-64 Linux TODO list
MIME-Version: 1
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
Message-Id: <marc-linux-ia64-105590693005093@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205896@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205896@msgid-missing>
To: linux-ia64@vger.kernel.org

--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii

On Tue, Jan 09, 2001, David Mosberger <davidm@hpl.hp.com> wrote:
> Kernel
>  - verify that all on-board hardware is supported and working:

A little late, but this patch is modestly tested and it appears to work
on ia32 as well as ia64. This patch is a little different than the one
I send to the linux-usb-devel list. The only major difference is the
patch to set uhci->dev correctly so the PCI DMA API routines work correctly
under ia64.

It's a bit large, but there were some large changes necessary to support the
PCI DMA API in the driver.

Here's the changelog I sent to linux-usb-devel if anyone cares:

bug fixes
---------
- Don't use nested locks anymore. This could cause deadlocks in drivers
  which were hard to track down. We use a complete list which is walked
  through after determining the transfer result of the URB's
- Bulk queueing should work significantly better now. I've fixed some
  obvious problems with it (order issues, retoggle remaining URB's)
- Enforce memory barriers. I hope this will help some of the people who
  were having some problems with the driver
- In some situations, the device usage count would be off and the memory
  would never get freed
- Don't always mark VRH interrupt URB as done
- When forcing unlinking of urb's in uhci_free_dev, make sure they are not
  done asynchronously

new features
------------
- Use PCI DMA architecture. This is necessary for 64 bit architectures
  (alpha, ultrasparc, ia64, etc)
- New /proc interface. Dump the status of the schedule
- debug option is more versatile now

clean ups
---------
- Use list_heads when possible now. Makes code cleaner/easier to read
- Added uhci_call_completion function to call the completion handler
  the same way in multiple places

TODO
----
- The PCI DMA architecture is horribly inefficient on x86 and ia64. The
  result is a page is allocated for each TD. This is evil. Perhaps a slab
  cache internally? Or modify the generic slab cache to handle PCI DMA
  pages instead?
- Cleanup up FIXME's
- Make uhci-debug.h functions respect len
- More testing, I have seen it lock up my machine hard with a CPiA camera
  after a long period of running
- Figure out why the submit loop (second) of uhci_call_completion causes
  crashes
- Should we return -EPIPE on BABBLE? Drivers will confuse this with a STALL

JE


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="uhci-20010124.diff"

diff -urN -X dontdiff linux-2.4.1-pre8.orig/drivers/usb/uhci-debug.h linux-2.4.1-pre8/drivers/usb/uhci-debug.h
--- linux-2.4.1-pre8.orig/drivers/usb/uhci-debug.h	Thu Jan  4 14:52:32 2001
+++ linux-2.4.1-pre8/drivers/usb/uhci-debug.h	Mon Jan 22 17:05:23 2001
@@ -6,20 +6,22 @@
  * visible pointers are surrounded in ()'s
  *
  * (C) Copyright 1999 Linus Torvalds
- * (C) Copyright 1999 Johannes Erdfelt
+ * (C) Copyright 1999-2001 Johannes Erdfelt
  */
 
 #include <linux/kernel.h>
+#include <linux/proc_fs.h>
 #include <asm/io.h>
 
 #include "uhci.h"
 
-void uhci_show_td(struct uhci_td *td)
+static int uhci_show_td(struct uhci_td *td, char *buf, int len)
 {
+	char *out = buf;
 	char *spid;
 
-	printk("%08x ", td->link);
-	printk("e%d %s%s%s%s%s%s%s%s%s%sLength=%x ",
+	out += sprintf(out, "[%p] link (%08x) ", td, td->link);
+	out += sprintf(out, "e%d %s%s%s%s%s%s%s%s%s%sLength=%x ",
 		((td->status >> 27) & 3),
 		(td->status & TD_CTRL_SPD) ?      "SPD " : "",
 		(td->status & TD_CTRL_LS) ?       "LS " : "",
@@ -48,19 +50,23 @@
 			break;
 	}
 
-	printk("MaxLen=%x DT%d EndPt=%x Dev=%x, PID=%x(%s) ",
+	out += sprintf(out, "MaxLen=%x DT%d EndPt=%x Dev=%x, PID=%x(%s) ",
 		td->info >> 21,
 		((td->info >> 19) & 1),
 		(td->info >> 15) & 15,
 		(td->info >> 8) & 127,
 		(td->info & 0xff),
 		spid);
-	printk("(buf=%08x)\n", td->buffer);
+	out += sprintf(out, "(buf=%08x)\n", td->buffer);
+
+	return out - buf;
 }
 
-static void uhci_show_sc(int port, unsigned short status)
+static int uhci_show_sc(int port, unsigned short status, char *buf, int len)
 {
-	printk("  stat%d     =     %04x   %s%s%s%s%s%s%s%s\n",
+	char *out = buf;
+
+	out += sprintf(out, "  stat%d     =     %04x   %s%s%s%s%s%s%s%s\n",
 		port,
 		status,
 		(status & USBPORTSC_SUSP) ? "PortSuspend " : "",
@@ -71,10 +77,13 @@
 		(status & USBPORTSC_PE) ?   "PortEnabled " : "",
 		(status & USBPORTSC_CSC) ?  "ConnectChange " : "",
 		(status & USBPORTSC_CCS) ?  "PortConnected " : "");
+
+	return out - buf;
 }
 
-void uhci_show_status(struct uhci *uhci)
+static int uhci_show_status(struct uhci *uhci, char *buf, int len)
 {
+	char *out = buf;
 	unsigned int io_addr = uhci->io_addr;
 	unsigned short usbcmd, usbstat, usbint, usbfrnum;
 	unsigned int flbaseadd;
@@ -90,7 +99,7 @@
 	portsc1   = inw(io_addr + 16);
 	portsc2   = inw(io_addr + 18);
 
-	printk("  usbcmd    =     %04x   %s%s%s%s%s%s%s%s\n",
+	out += sprintf(out, "  usbcmd    =     %04x   %s%s%s%s%s%s%s%s\n",
 		usbcmd,
 		(usbcmd & USBCMD_MAXP) ?    "Maxp64 " : "Maxp32 ",
 		(usbcmd & USBCMD_CF) ?      "CF " : "",
@@ -101,7 +110,7 @@
 		(usbcmd & USBCMD_HCRESET) ? "HCRESET " : "",
 		(usbcmd & USBCMD_RS) ?      "RS " : "");
 
-	printk("  usbstat   =     %04x   %s%s%s%s%s%s\n",
+	out += sprintf(out, "  usbstat   =     %04x   %s%s%s%s%s%s\n",
 		usbstat,
 		(usbstat & USBSTS_HCH) ?    "HCHalted " : "",
 		(usbstat & USBSTS_HCPE) ?   "HostControllerProcessError " : "",
@@ -110,53 +119,66 @@
 		(usbstat & USBSTS_ERROR) ?  "USBError " : "",
 		(usbstat & USBSTS_USBINT) ? "USBINT " : "");
 
-	printk("  usbint    =     %04x\n", usbint);
-	printk("  usbfrnum  =   (%d)%03x\n", (usbfrnum >> 10) & 1,
+	out += sprintf(out, "  usbint    =     %04x\n", usbint);
+	out += sprintf(out, "  usbfrnum  =   (%d)%03x\n", (usbfrnum >> 10) & 1,
 		0xfff & (4*(unsigned int)usbfrnum));
-	printk("  flbaseadd = %08x\n", flbaseadd);
-	printk("  sof       =       %02x\n", sof);
-	uhci_show_sc(1, portsc1);
-	uhci_show_sc(2, portsc2);
-}
-
-#define uhci_link_to_qh(x) ((struct uhci_qh *) uhci_link_to_td(x))
-
-struct uhci_td *uhci_link_to_td(unsigned int link)
-{
-	if (link & UHCI_PTR_TERM)
-		return NULL;
+	out += sprintf(out, "  flbaseadd = %08x\n", flbaseadd);
+	out += sprintf(out, "  sof       =       %02x\n", sof);
+	out += uhci_show_sc(1, portsc1, out, len - (out - buf));
+	out += uhci_show_sc(2, portsc2, out, len - (out - buf));
 
-	return bus_to_virt(link & ~UHCI_PTR_BITS);
+	return out - buf;
 }
 
-void uhci_show_urb_queue(struct urb *urb)
+static int uhci_show_qh(struct uhci_qh *qh, char *buf, int len)
 {
-	struct urb_priv *urbp = urb->hcpriv;
+	char *out = buf;
+	struct urb_priv *urbp;
 	struct list_head *head, *tmp;
-	int i, checked = 0, prevactive = 0;
+	struct uhci_td *td;
+	int i = 0, checked = 0, prevactive = 0;
+
+	out += sprintf(out, "[%p] link (%08x) element (%08x)\n",
+				qh, qh->link, qh->element);
+	if (qh->element & UHCI_PTR_QH)
+		out += sprintf(out, "      Element points to QH (bug?)\n");
+
+	if (qh->element & UHCI_PTR_DEPTH)
+		out += sprintf(out, "      Depth traverse\n");
 
-	printk("  URB [%p] urbp [%p]\n", urb, urbp);
+	if (qh->element & UHCI_PTR_TERM)
+		out += sprintf(out, "      Terminate\n");
 
-	if (urbp->qh)
-		printk("    QH [%p]\n", urbp->qh);
-	else
-		printk("    QH [%p] element (%08x) link (%08x)\n", urbp->qh,
-			urbp->qh->element, urbp->qh->link);
+	if (!(qh->element & ~UHCI_PTR_BITS)) {
+		out += sprintf(out, "      td 0: [NULL]\n");
+		goto out;
+	}
 
-	i = 0;
+	if (!qh->urbp) {
+		out += sprintf(out, "      urbp == NULL\n");
+		goto out;
+	}
 
-	head = &urbp->list;
+	urbp = qh->urbp;
+
+	head = &urbp->td_list;
 	tmp = head->next;
+
+	td = list_entry(tmp, struct uhci_td, list);
+
+	if (td->dma_handle != (qh->element & ~3))
+		out += sprintf(out, "      Element != First TD\n");
+
 	while (tmp != head) {
 		struct uhci_td *td = list_entry(tmp, struct uhci_td, list);
 
 		tmp = tmp->next;
 
-		printk("      td %d: [%p]\n", i++, td);
-		printk("      ");
-		uhci_show_td(td);
+		out += sprintf(out, "      td %d: ", i++);
+		out += uhci_show_td(td, out, len - (out - buf));
 
-		if (i > 10 && !checked && prevactive && tmp != head) {
+		if (i > 10 && !checked && prevactive && tmp != head &&
+		    debug <= 2) {
 			struct list_head *ntmp = tmp;
 			struct uhci_td *ntd = td;
 			int active = 1, ni = i;
@@ -174,7 +196,7 @@
 			}
 
 			if (active && ni > i) {
-				printk("      [skipped %d active TD's]\n", ni - i);
+				out += sprintf(out, "      [skipped %d active TD's]\n", ni - i);
 				tmp = ntmp;
 				td = ntd;
 				i = ni;
@@ -183,60 +205,30 @@
 
 		prevactive = td->status & TD_CTRL_ACTIVE;
 	}
-}
-
-void uhci_show_queue(struct uhci_qh *qh)
-{
-	struct uhci_td *td, *first;
-	int i = 0, count = 1000;
 
-	if (qh->element & UHCI_PTR_QH)
-		printk("      Element points to QH (bug?)\n");
+	/* FIXME: Show queued URB's as well */
 
-	if (qh->element & UHCI_PTR_DEPTH)
-		printk("      Depth traverse\n");
-
-	if (qh->element & UHCI_PTR_TERM)
-		printk("      Terminate\n");
-
-	if (!(qh->element & ~UHCI_PTR_BITS)) {
-		printk("      td 0: [NULL]\n");
-		return;
-	}
-
-	first = uhci_link_to_td(qh->element);
-
-	/* Make sure it doesn't runaway */
-	for (td = first; td && count > 0; 
-	     td = uhci_link_to_td(td->link), --count) {
-		printk("      td %d: [%p]\n", i++, td);
-		printk("      ");
-		uhci_show_td(td);
-
-		if (td == uhci_link_to_td(td->link)) {
-			printk(KERN_ERR "td links to itself!\n");
-			break;
-		}
-	}
+out:
+	return out - buf;
 }
 
-static int uhci_is_skeleton_td(struct uhci *uhci, struct uhci_td *td)
+static int inline uhci_is_skeleton_td(struct uhci *uhci, struct uhci_td *td)
 {
-	int j;
+	int i;
 
-	for (j = 0; j < UHCI_NUM_SKELTD; j++)
-		if (td == uhci->skeltd + j)
+	for (i = 0; i < UHCI_NUM_SKELTD; i++)
+		if (td == uhci->skeltd[i])
 			return 1;
 
 	return 0;
 }
 
-static int uhci_is_skeleton_qh(struct uhci *uhci, struct uhci_qh *qh)
+static int inline uhci_is_skeleton_qh(struct uhci *uhci, struct uhci_qh *qh)
 {
-	int j;
+	int i;
 
-	for (j = 0; j < UHCI_NUM_SKELQH; j++)
-		if (qh == uhci->skelqh + j)
+	for (i = 0; i < UHCI_NUM_SKELQH; i++)
+		if (qh == uhci->skelqh[i])
 			return 1;
 
 	return 0;
@@ -244,73 +236,262 @@
 
 static const char *td_names[] = {"interrupt1", "interrupt2", "interrupt4",
 				 "interrupt8", "interrupt16", "interrupt32",
-				 "interrupt64", "interrupt128", "interrupt256" };
-static const char *qh_names[] = { "control", "bulk" };
+				 "interrupt64", "interrupt128", "interrupt256",
+				 "term" };
+static const char *qh_names[] = { "low speed control", "high speed control",
+				  "bulk", "term" };
+
+#define show_frame_num()	\
+	if (!shown) {		\
+	  shown = 1;		\
+	  out += sprintf(out, "  Frame %d\n", i); \
+	}
 
-void uhci_show_queues(struct uhci *uhci)
+#define show_td_name()		\
+	if (!shown) {		\
+	  shown = 1;		\
+	  out += sprintf(out, "  %s: [%p] (%08x) link (%08x)\n", td_names[i], \
+			td, td->dma_handle, td->link); \
+	}
+
+#define show_qh_name()		\
+	if (!shown) {		\
+	  shown = 1;		\
+	  out += sprintf(out, "  %s: [%p] (%08x) link (%08x) element (%08x)\n", \
+			qh_names[i], qh, qh->dma_handle, qh->link, \
+			qh->element); \
+	}
+
+static int uhci_sprint_schedule(struct uhci *uhci, char *buf, int len)
 {
-	int i, isqh = 0;
+	char *out = buf;
+	int i;
 	struct uhci_qh *qh;
 	struct uhci_td *td;
+	struct list_head *tmp, *head;
 
+	out += sprintf(out, "HC status\n");
+	out += uhci_show_status(uhci, out, len - (out - buf));
+
+	out += sprintf(out, "Frame List\n");
 	for (i = 0; i < UHCI_NUMFRAMES; ++i) {
 		int shown = 0;
 
-		td = uhci_link_to_td(uhci->fl->frame[i]);
-		if (td)
-			isqh = uhci->fl->frame[i] & UHCI_PTR_QH;
-		while (td && !isqh) {
-			if (uhci_is_skeleton_td(uhci, td))
-				break;
-
-			if (!shown) {
-				printk("   Frame %d\n", i);
-				shown = 1;
+		td = uhci->fl->frame_cpu[i];
+		if (!td) {
+			show_frame_num();
+			out += sprintf(out, "Frame %d empty?\n", i);
+			continue;
+		}
+
+		if (td->dma_handle != (dma_addr_t)uhci->fl->frame[i]) {
+			show_frame_num();
+			out += sprintf(out, "frame_cpu does not match frame\n");
+		}
+
+		if (uhci_is_skeleton_td(uhci, td))
+			continue;
+
+		show_frame_num();
+
+		head = &td->fl_list;
+		tmp = head;
+
+		do {
+			td = list_entry(tmp, struct uhci_td, fl_list);
+
+			tmp = tmp->next;
+
+			out += sprintf(out, "  ");
+			out += uhci_show_td(td, out, len - (out - buf));
+		} while (tmp != head);
+	}
+
+	out += sprintf(out, "Skeleton TD's\n");
+	for (i = UHCI_NUM_SKELTD - 1; i >= 0; i--) {
+		int shown = 0;
+
+		td = uhci->skeltd[i];
+
+		if (debug > 2)
+			show_td_name();
+
+		if (list_empty(&td->fl_list)) {
+			if (i < 8 && i > 0) {
+				if (td->link != uhci->skeltd[i - 1]->dma_handle) {
+					show_td_name();
+					out += sprintf(out, "    Skeleton TD not linked to next skeleton TD!\n");
+				}
+			} else if (!i) {
+				if (td->link !=
+				    (uhci->skel_ls_control_qh->dma_handle | UHCI_PTR_QH)) {
+					show_td_name();
+					out += sprintf(out, "    Skeleton TD not linked to ls_control QH!\n");
+				}
 			}
 
-			printk("[%p] ", td);
+			continue;
+		}
+
+		show_td_name();
+
+		head = &td->fl_list;
+		tmp = head->next;
 
-			uhci_show_td(td);
-			td = uhci_link_to_td(td->link);
-			if (td)
-				isqh = td->link & UHCI_PTR_QH;
+		while (tmp != head) {
+			td = list_entry(tmp, struct uhci_td, fl_list);
+
+			tmp = tmp->next;
+
+			out += sprintf(out, "    ");
+			out += uhci_show_td(td, out, len - (out - buf));
 		}
-	}
-	for (i = 0; i < UHCI_NUM_SKELTD; ++i) {
-		printk("  %s: [%p] (%08x)\n", td_names[i],
-			&uhci->skeltd[i],
-			uhci->skeltd[i].link);
-
-		td = uhci_link_to_td(uhci->skeltd[i].link);
-		if (td)
-			isqh = uhci->skeltd[i].link & UHCI_PTR_QH;
-		while (td && !isqh) {
-			if (uhci_is_skeleton_td(uhci, td))
-				break;
-
-			printk("[%p] ", td);
-
-			uhci_show_td(td);
-			td = uhci_link_to_td(td->link);
-			if (td)
-				isqh = td->link & UHCI_PTR_QH;
+
+		if (i < 8 && i > 0) {
+			if (td->link != uhci->skeltd[i - 1]->dma_handle)
+				out += sprintf(out, "    Last TD not linked to next skeleton!\n");
+		} else if (!i) {
+			if (td->link !=
+			    (uhci->skel_ls_control_qh->dma_handle | UHCI_PTR_QH))
+				out += sprintf(out, "    Last TD not linked to ls_control QH!\n");
 		}
 	}
+
+	out += sprintf(out, "Skeleton QH's\n");
 	for (i = 0; i < UHCI_NUM_SKELQH; ++i) {
-		printk("  %s: [%p] (%08x) (%08x)\n", qh_names[i],
-			&uhci->skelqh[i],
-			uhci->skelqh[i].link, uhci->skelqh[i].element);
-
-		qh = uhci_link_to_qh(uhci->skelqh[i].link);
-		for (; qh; qh = uhci_link_to_qh(qh->link)) {
-			if (uhci_is_skeleton_qh(uhci, qh))
-				break;
+		int shown = 0;
 
-			printk("    [%p] (%08x) (%08x)\n",
-				qh, qh->link, qh->element);
+		qh = uhci->skelqh[i];
+
+		if (debug > 2)
+			show_qh_name();
+
+		if (list_empty(&qh->list))
+			continue;
+
+		show_qh_name();
 
-			uhci_show_queue(qh);
+		head = &qh->list;
+		tmp = head->next;
+
+		while (tmp != head) {
+			qh = list_entry(tmp, struct uhci_qh, list);
+
+			tmp = tmp->next;
+
+			out += sprintf(out, "    ");
+			out += uhci_show_qh(qh, out, len - (out - buf));
 		}
 	}
+
+	return out - buf;
 }
+
+#ifdef CONFIG_PROC_FS
+#define MAX_OUTPUT	(PAGE_SIZE * 2)
+
+static struct proc_dir_entry *uhci_proc_root = NULL;
+
+struct uhci_proc {
+	int size;
+	char *data;
+	struct uhci *uhci;
+};
+
+static int uhci_proc_open(struct inode *inode, struct file *file)
+{
+	const struct proc_dir_entry *dp = inode->u.generic_ip;
+	struct uhci *uhci = dp->data;
+	struct uhci_proc *up;
+	unsigned long flags;
+	int ret = -ENOMEM;
+
+	lock_kernel();
+	up = kmalloc(sizeof(*up), GFP_KERNEL);
+	if (!up)
+		goto out;
+
+	up->data = kmalloc(MAX_OUTPUT, GFP_KERNEL);
+	if (!up->data) {
+		kfree(up);
+		goto out;
+	}
+
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
+	up->size = uhci_sprint_schedule(uhci, up->data, MAX_OUTPUT);
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
+
+	file->private_data = up;
+
+	ret = 0;
+out:
+	unlock_kernel();
+	return ret;
+}
+
+static loff_t uhci_proc_lseek(struct file *file, loff_t off, int whence)
+{
+	struct uhci_proc *up = file->private_data;
+	loff_t new;
+
+	switch (whence) {
+	case 0:
+		new = off;
+		break;
+	case 1:
+		new = file->f_pos + off;
+		break;
+	case 2:
+	default:
+		return -EINVAL;
+	}
+	if (new < 0 || new > up->size)
+		return -EINVAL;
+	return (file->f_pos = new);
+}
+
+static ssize_t uhci_proc_read(struct file *file, char *buf, size_t nbytes,
+			loff_t *ppos)
+{
+	struct uhci_proc *up = file->private_data;
+	unsigned int pos;
+	unsigned int size;
+
+	pos = *ppos;
+	size = up->size;
+	if (pos >= size)
+		return 0;
+	if (nbytes >= size)
+		nbytes = size;
+	if (pos + nbytes > size)
+		nbytes = size - pos;
+
+	if (!access_ok(VERIFY_WRITE, buf, nbytes))
+		return -EINVAL;
+
+	copy_to_user(buf, up->data + pos, nbytes);
+
+	*ppos += nbytes;
+
+	return nbytes;
+}
+
+static int uhci_proc_release(struct inode *inode, struct file *file)
+{
+	struct uhci_proc *up = file->private_data;
+
+	kfree(up->data);
+	kfree(up);
+
+	return 0;
+}
+
+static struct file_operations uhci_proc_operations = {
+	open:		uhci_proc_open,
+	llseek:		uhci_proc_lseek,
+	read:		uhci_proc_read,
+//	write:		uhci_proc_write,
+	release:	uhci_proc_release,
+};
+#endif
 
diff -urN -X dontdiff linux-2.4.1-pre8.orig/drivers/usb/uhci.c linux-2.4.1-pre8/drivers/usb/uhci.c
--- linux-2.4.1-pre8.orig/drivers/usb/uhci.c	Wed Jan 24 17:15:11 2001
+++ linux-2.4.1-pre8/drivers/usb/uhci.c	Wed Jan 24 17:05:59 2001
@@ -1,8 +1,10 @@
 /*
  * Universal Host Controller Interface driver for USB.
  *
+ * Maintainer: Johannes Erdfelt <johannes@erdfelt.com>
+ *
  * (C) Copyright 1999 Linus Torvalds
- * (C) Copyright 1999-2000 Johannes Erdfelt, johannes@erdfelt.com
+ * (C) Copyright 1999-2001 Johannes Erdfelt, johannes@erdfelt.com
  * (C) Copyright 1999 Randy Dunlap
  * (C) Copyright 1999 Georg Acher, acher@in.tum.de
  * (C) Copyright 1999 Deti Fliegl, deti@fliegl.de
@@ -12,7 +14,6 @@
  *               support from usb-ohci.c by Adam Richter, adam@yggdrasil.com).
  * (C) Copyright 1999 Gregory P. Smith (from usb-ohci.c)
  *
- *
  * Intel documents this fairly well, and as far as I know there
  * are no royalties or anything like that, but even so there are
  * people who decided that they want to do the same thing in a
@@ -39,7 +40,12 @@
 #include <linux/unistd.h>
 #include <linux/interrupt.h>
 #include <linux/spinlock.h>
+#include <linux/proc_fs.h>
+#ifdef CONFIG_USB_DEBUG
+#define DEBUG
+#else
 #undef DEBUG
+#endif
 #include <linux/usb.h>
 
 #include <asm/uaccess.h>
@@ -48,29 +54,41 @@
 #include <asm/system.h>
 
 #include "uhci.h"
-#include "uhci-debug.h"
 
 #include <linux/pm.h>
 
+/*
+ * debug = 0, no debugging messages
+ * debug = 1, dump failed URB's except for stalls
+ * debug = 2, dump all failed URB's (including stalls)
+ *            show all queues in /proc/uhci/hc*
+ */
+#ifdef DEBUG
 static int debug = 1;
+#else
+static int debug = 0;
+#endif
 MODULE_PARM(debug, "i");
 MODULE_PARM_DESC(debug, "Debug level");
 
-static kmem_cache_t *uhci_td_cachep;
-static kmem_cache_t *uhci_qh_cachep;
+#include "uhci-debug.h"
+
 static kmem_cache_t *uhci_up_cachep;	/* urb_priv */
 
 static int rh_submit_urb(struct urb *urb);
 static int rh_unlink_urb(struct urb *urb);
 static int uhci_get_current_frame_number(struct usb_device *dev);
-static int uhci_unlink_generic(struct urb *urb);
 static int uhci_unlink_urb(struct urb *urb);
+static void uhci_unlink_generic(struct uhci *uhci, struct urb *urb);
+static void uhci_call_completion(struct urb *urb);
 
 #define min(a,b) (((a)<(b))?(a):(b))
 
 /* If a transfer is still active after this much time, turn off FSBR */
 #define IDLE_TIMEOUT	(HZ / 20)	/* 50 ms */
 
+#define MAX_URB_LOOP	2048		/* Maximum number of linked URB's */
+
 /*
  * Only the USB core should call uhci_alloc_dev and uhci_free_dev
  */
@@ -82,80 +100,97 @@
 static int uhci_free_dev(struct usb_device *dev)
 {
 	struct uhci *uhci = (struct uhci *)dev->bus->hcpriv;
-	struct list_head *tmp, *head = &uhci->urb_list;
+	struct list_head list, *tmp, *head;
 	unsigned long flags;
 
 	/* Walk through the entire URB list and forcefully remove any */
 	/*  URBs that are still active for that device */
-	nested_lock(&uhci->urblist_lock, flags);
+
+	/* Two stage unlink so we don't deadlock on urb_list_lock */
+	INIT_LIST_HEAD(&list);
+
+	spin_lock_irqsave(&uhci->urb_list_lock, flags);
+	head = &uhci->urb_list;
 	tmp = head->next;
 	while (tmp != head) {
-		struct urb *u = list_entry(tmp, struct urb, urb_list);
+		struct urb *urb = list_entry(tmp, struct urb, urb_list);
 
 		tmp = tmp->next;
 
-		if (u->dev == dev)
-			uhci_unlink_urb(u);
+		if (urb->dev == dev) {
+			list_del(&urb->urb_list);
+			list_add(&urb->urb_list, &list);
+		}
 	}
-	nested_unlock(&uhci->urblist_lock, flags);
+	spin_unlock_irqrestore(&uhci->urb_list_lock, flags);
 
-	return 0;
-}
+	head = &list;
+	tmp = head->next;
+	while (tmp != head) {
+		struct urb *urb = list_entry(tmp, struct urb, urb_list);
 
-static void uhci_add_urb_list(struct uhci *uhci, struct urb *urb)
-{
-	unsigned long flags;
+		tmp = tmp->next;
+
+		/* Make sure we block waiting on these to die */
+		urb->transfer_flags &= ~USB_ASYNC_UNLINK;
+
+		/* uhci_unlink_urb will unlink from the temp list */
+		uhci_unlink_urb(urb);
+	}
 
-	nested_lock(&uhci->urblist_lock, flags);
-	list_add(&urb->urb_list, &uhci->urb_list);
-	nested_unlock(&uhci->urblist_lock, flags);
+
+	return 0;
 }
 
-static void uhci_remove_urb_list(struct uhci *uhci, struct urb *urb)
+static inline void uhci_set_next_interrupt(struct uhci *uhci)
 {
 	unsigned long flags;
 
-	nested_lock(&uhci->urblist_lock, flags);
-	if (!list_empty(&urb->urb_list)) {
-		list_del(&urb->urb_list);
-		INIT_LIST_HEAD(&urb->urb_list);
-	}
-	nested_unlock(&uhci->urblist_lock, flags);
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
+	uhci->skel_term_td->status |= TD_CTRL_IOC;
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 }
 
-void uhci_set_next_interrupt(struct uhci *uhci)
+static inline void uhci_clear_next_interrupt(struct uhci *uhci)
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(&uhci->framelist_lock, flags);
-	uhci->skel_term_td.status |= TD_CTRL_IOC;
-	spin_unlock_irqrestore(&uhci->framelist_lock, flags);
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
+	uhci->skel_term_td->status &= ~TD_CTRL_IOC;
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 }
 
-void uhci_clear_next_interrupt(struct uhci *uhci)
+static inline void uhci_add_complete(struct urb *urb)
 {
+	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
+	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
 	unsigned long flags;
 
-	spin_lock_irqsave(&uhci->framelist_lock, flags);
-	uhci->skel_term_td.status &= ~TD_CTRL_IOC;
-	spin_unlock_irqrestore(&uhci->framelist_lock, flags);
+	spin_lock_irqsave(&uhci->complete_list_lock, flags);
+	list_add(&urbp->complete_list, &uhci->complete_list);
+	spin_unlock_irqrestore(&uhci->complete_list_lock, flags);
 }
 
-static struct uhci_td *uhci_alloc_td(struct usb_device *dev)
+/* FIXME: We should do our own cache since pci_alloc_consistent is */
+/* inefficient under i386 and ia64 atleast. One page per TD, ick */
+static struct uhci_td *uhci_alloc_td(struct uhci *uhci, struct usb_device *dev)
 {
+	dma_addr_t dma_handle;
 	struct uhci_td *td;
 
-	td = kmem_cache_alloc(uhci_td_cachep, in_interrupt() ? SLAB_ATOMIC : SLAB_KERNEL);
+	td = pci_alloc_consistent(uhci->dev, sizeof(*td), &dma_handle);
 	if (!td)
 		return NULL;
 
 	td->link = UHCI_PTR_TERM;
 	td->buffer = 0;
 
-	td->frameptr = NULL;
-	td->nexttd = td->prevtd = NULL;
+	td->dma_handle = dma_handle;
+	td->frame = -1;
 	td->dev = dev;
+
 	INIT_LIST_HEAD(&td->list);
+	INIT_LIST_HEAD(&td->fl_list);
 
 	usb_inc_dev_use(dev);
 
@@ -173,20 +208,19 @@
 static void uhci_insert_td(struct uhci *uhci, struct uhci_td *skeltd, struct uhci_td *td)
 {
 	unsigned long flags;
+	struct uhci_td *ltd;
+
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
 
-	spin_lock_irqsave(&uhci->framelist_lock, flags);
+	ltd = list_entry(skeltd->fl_list.prev, struct uhci_td, fl_list);
 
-	/* Fix the linked list pointers */
-	td->nexttd = skeltd->nexttd;
-	td->prevtd = skeltd;
-	if (skeltd->nexttd)
-		skeltd->nexttd->prevtd = td;
-	skeltd->nexttd = td;
+	td->link = ltd->link;
+	mb();
+	ltd->link = td->dma_handle;
 
-	td->link = skeltd->link;
-	skeltd->link = virt_to_bus(td);
+	list_add_tail(&td->fl_list, &skeltd->fl_list);
 
-	spin_unlock_irqrestore(&uhci->framelist_lock, flags);
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 }
 
 /*
@@ -196,27 +230,36 @@
  * frame list pointer -> iso td's (if any) ->
  * periodic interrupt td (if frame 0) -> irq td's -> control qh -> bulk qh
  */
-
 static void uhci_insert_td_frame_list(struct uhci *uhci, struct uhci_td *td, unsigned framenum)
 {
 	unsigned long flags;
-	struct uhci_td *nexttd;
 
 	framenum %= UHCI_NUMFRAMES;
 
-	spin_lock_irqsave(&uhci->framelist_lock, flags);
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
+
+	td->frame = framenum;
+
+	/* Is there a TD already mapped there? */
+	if (uhci->fl->frame_cpu[framenum]) {
+		struct uhci_td *ftd, *ltd;
+
+		ftd = uhci->fl->frame_cpu[framenum];
+		ltd = list_entry(ftd->fl_list.prev, struct uhci_td, fl_list);
+
+		list_add_tail(&td->fl_list, &ftd->fl_list);
 
-	td->frameptr = &uhci->fl->frame[framenum];
-	td->link = uhci->fl->frame[framenum];
-	if (!(td->link & (UHCI_PTR_TERM | UHCI_PTR_QH))) {
-		nexttd = (struct uhci_td *)uhci_ptr_to_virt(td->link);
-		td->nexttd = nexttd;
-		nexttd->prevtd = td;
-		nexttd->frameptr = NULL;
+		td->link = ltd->link;
+		mb();
+		ltd->link = td->dma_handle;
+	} else {
+		td->link = uhci->fl->frame[framenum];
+		mb();
+		uhci->fl->frame[framenum] = td->dma_handle;
+		uhci->fl->frame_cpu[framenum] = td;
 	}
-	uhci->fl->frame[framenum] = virt_to_bus(td);
 
-	spin_unlock_irqrestore(&uhci->framelist_lock, flags);
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 }
 
 static void uhci_remove_td(struct uhci *uhci, struct uhci_td *td)
@@ -224,29 +267,36 @@
 	unsigned long flags;
 
 	/* If it's not inserted, don't remove it */
-	if (!td->frameptr && !td->prevtd && !td->nexttd)
+	if (td->frame == -1 && list_empty(&td->fl_list))
 		return;
 
-	spin_lock_irqsave(&uhci->framelist_lock, flags);
-	if (td->frameptr) {
-		*(td->frameptr) = td->link;
-		if (td->nexttd) {
-			td->nexttd->frameptr = td->frameptr;
-			td->nexttd->prevtd = NULL;
-			td->nexttd = NULL;
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
+	if (td->frame != -1 && uhci->fl->frame_cpu[td->frame] == td) {
+		if (list_empty(&td->fl_list)) {
+			uhci->fl->frame[td->frame] = td->link;
+			uhci->fl->frame_cpu[td->frame] = NULL;
+		} else {
+			struct uhci_td *ntd;
+
+			ntd = list_entry(td->fl_list.next, struct uhci_td, fl_list);
+			uhci->fl->frame[td->frame] = ntd->dma_handle;
+			uhci->fl->frame_cpu[td->frame] = ntd;
 		}
-		td->frameptr = NULL;
 	} else {
-		if (td->prevtd) {
-			td->prevtd->nexttd = td->nexttd;
-			td->prevtd->link = td->link;
-		}
-		if (td->nexttd)
-			td->nexttd->prevtd = td->prevtd;
-		td->prevtd = td->nexttd = NULL;
+		struct uhci_td *ptd;
+
+		ptd = list_entry(td->fl_list.prev, struct uhci_td, fl_list);
+		ptd->link = td->link;
 	}
+
+	mb();
 	td->link = UHCI_PTR_TERM;
-	spin_unlock_irqrestore(&uhci->framelist_lock, flags);
+
+	list_del(&td->fl_list);
+	INIT_LIST_HEAD(&td->fl_list);
+	td->frame = -1;
+
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 }
 
 /*
@@ -256,22 +306,21 @@
 {
 	struct list_head *tmp, *head;
 	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
-	struct uhci_td *td, *prevtd;
-
-	if (!urbp)
-		return;
+	struct uhci_td *td, *ptd;
 
-	head = &urbp->list;
+	head = &urbp->td_list;
 	tmp = head->next;
 	if (head == tmp)
 		return;
 
+	/* Ordering isn't important here yet since the QH hasn't been */
+	/*  inserted into the schedule yet */
 	td = list_entry(tmp, struct uhci_td, list);
 
 	/* Add the first TD to the QH element pointer */
-	qh->element = virt_to_bus(td) | (breadth ? 0 : UHCI_PTR_DEPTH);
+	qh->element = td->dma_handle | (breadth ? 0 : UHCI_PTR_DEPTH);
 
-	prevtd = td;
+	ptd = td;
 
 	/* Then link the rest of the TD's */
 	tmp = tmp->next;
@@ -280,39 +329,43 @@
 
 		tmp = tmp->next;
 
-		prevtd->link = virt_to_bus(td) | (breadth ? 0 : UHCI_PTR_DEPTH);
+		ptd->link = td->dma_handle | (breadth ? 0 : UHCI_PTR_DEPTH);
 
-		prevtd = td;
+		ptd = td;
 	}
 
-	prevtd->link = UHCI_PTR_TERM;
+	ptd->link = UHCI_PTR_TERM;
 }
 
-static void uhci_free_td(struct uhci_td *td)
+static void uhci_free_td(struct uhci *uhci, struct uhci_td *td)
 {
-	if (!list_empty(&td->list))
+#ifdef DEBUG
+	if (!list_empty(&td->list) || !list_empty(&td->fl_list))
 		dbg("td is still in URB list!");
+#endif
 
 	if (td->dev)
 		usb_dec_dev_use(td->dev);
 
-	kmem_cache_free(uhci_td_cachep, td);
+	pci_free_consistent(uhci->dev, sizeof(*td), td, td->dma_handle);
 }
 
-static struct uhci_qh *uhci_alloc_qh(struct usb_device *dev)
+static struct uhci_qh *uhci_alloc_qh(struct uhci *uhci, struct usb_device *dev)
 {
+	dma_addr_t dma_handle;
 	struct uhci_qh *qh;
 
-	qh = kmem_cache_alloc(uhci_qh_cachep, in_interrupt() ? SLAB_ATOMIC : SLAB_KERNEL);
+	qh = pci_alloc_consistent(uhci->dev, sizeof(*qh), &dma_handle);
 	if (!qh)
 		return NULL;
 
 	qh->element = UHCI_PTR_TERM;
 	qh->link = UHCI_PTR_TERM;
 
+	qh->dma_handle = dma_handle;
 	qh->dev = dev;
-	qh->prevqh = qh->nextqh = NULL;
 
+	INIT_LIST_HEAD(&qh->list);
 	INIT_LIST_HEAD(&qh->remove_list);
 
 	usb_inc_dev_use(dev);
@@ -320,181 +373,277 @@
 	return qh;
 }
 
-static void uhci_free_qh(struct uhci_qh *qh)
+static void uhci_free_qh(struct uhci *uhci, struct uhci_qh *qh)
 {
+#ifdef DEBUG
+	if (!list_empty(&qh->list))
+		dbg("qh list not empty!");
+	if (!list_empty(&qh->remove_list))
+		dbg("qh still in remove_list!\n");
+#endif
+
 	if (qh->dev)
 		usb_dec_dev_use(qh->dev);
 
-	kmem_cache_free(uhci_qh_cachep, qh);
+	pci_free_consistent(uhci->dev, sizeof(*qh), qh, qh->dma_handle);
 }
 
-static void uhci_insert_qh(struct uhci *uhci, struct uhci_qh *skelqh, struct uhci_qh *qh)
+static void _uhci_insert_qh(struct uhci *uhci, struct uhci_qh *skelqh, struct uhci_qh *qh)
 {
-	unsigned long flags;
+	struct uhci_qh *lqh;
 
-	spin_lock_irqsave(&uhci->framelist_lock, flags);
+	/* Grab the last QH */
+	lqh = list_entry(skelqh->list.prev, struct uhci_qh, list);
 
-	/* Fix the linked list pointers */
-	qh->nextqh = skelqh->nextqh;
-	qh->prevqh = skelqh;
-	if (skelqh->nextqh)
-		skelqh->nextqh->prevqh = qh;
-	skelqh->nextqh = qh;
+	qh->link = lqh->link;		/* Does this really matter? */
+	mb();				/* Ordering is important */
+	lqh->link = qh->dma_handle | UHCI_PTR_QH;
+
+	list_add_tail(&qh->list, &skelqh->list);
+}
 
-	qh->link = skelqh->link;
-	skelqh->link = virt_to_bus(qh) | UHCI_PTR_QH;
+static void uhci_insert_qh(struct uhci *uhci, struct uhci_qh *skelqh, struct uhci_qh *qh)
+{
+	unsigned long flags;
 
-	spin_unlock_irqrestore(&uhci->framelist_lock, flags);
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
+	_uhci_insert_qh(uhci, skelqh, qh);
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 }
 
 static void uhci_remove_qh(struct uhci *uhci, struct uhci_qh *qh)
 {
 	unsigned long flags;
-	int delayed;
+	struct uhci_qh *prevqh;
 
-	/* If the QH isn't queued, then we don't need to delay unlink it */
-	delayed = (qh->prevqh || qh->nextqh);
+	/* Only go through the hoops if it's actually linked in */
+	if (list_empty(&qh->list)) {
+		uhci_free_qh(uhci, qh);
+		return;
+	}
+
+	qh->urbp = NULL;
+
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
 
-	spin_lock_irqsave(&uhci->framelist_lock, flags);
-	if (qh->prevqh) {
-		qh->prevqh->nextqh = qh->nextqh;
-		qh->prevqh->link = qh->link;
-	}
-	if (qh->nextqh)
-		qh->nextqh->prevqh = qh->prevqh;
-	qh->prevqh = qh->nextqh = NULL;
+	prevqh = list_entry(qh->list.prev, struct uhci_qh, list);
+
+	prevqh->link = qh->link;
+	mb();
 	qh->element = qh->link = UHCI_PTR_TERM;
-	spin_unlock_irqrestore(&uhci->framelist_lock, flags);
 
-	if (delayed) {
-		spin_lock_irqsave(&uhci->qh_remove_lock, flags);
+	list_del(&qh->list);
+	INIT_LIST_HEAD(&qh->list);
 
-		/* Check to see if the remove list is empty */
-		/* Set the IOC bit to force an interrupt so we can remove the QH */
-		if (list_empty(&uhci->qh_remove_list))
-			uhci_set_next_interrupt(uhci);
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 
-		/* Add it */
-		list_add(&qh->remove_list, &uhci->qh_remove_list);
+	spin_lock_irqsave(&uhci->qh_remove_list_lock, flags);
 
-		spin_unlock_irqrestore(&uhci->qh_remove_lock, flags);
-	} else
-		uhci_free_qh(qh);
+	/* Check to see if the remove list is empty. Set the IOC bit */
+	/* to force an interrupt so we can remove the QH */
+	if (list_empty(&uhci->qh_remove_list))
+		uhci_set_next_interrupt(uhci);
+
+	list_add(&qh->remove_list, &uhci->qh_remove_list);
+
+	spin_unlock_irqrestore(&uhci->qh_remove_list_lock, flags);
 }
 
-static spinlock_t uhci_append_urb_lock = SPIN_LOCK_UNLOCKED;
+static int uhci_fixup_toggle(struct urb *urb, unsigned int toggle)
+{
+	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
+	struct list_head *head, *tmp;
+
+	head = &urbp->td_list;
+	tmp = head->next;
+	while (head != tmp) {
+		struct uhci_td *td = list_entry(tmp, struct uhci_td, list);
+
+		tmp = tmp->next;
+
+		td->info &= ~(1 << TD_TOKEN_TOGGLE);
+		if (toggle)
+			td->info |= (1 << TD_TOKEN_TOGGLE);
+
+		toggle ^= 1;
+	}
+
+	return toggle;
+}
 
 /* This function will append one URB's QH to another URB's QH. This is for */
-/*  USB_QUEUE_BULK support */
+/*  USB_QUEUE_BULK support for bulk transfers and implicitily for control */
+/*  transfers */
 static void uhci_append_queued_urb(struct uhci *uhci, struct urb *eurb, struct urb *urb)
 {
+	/* eurb = existing, urb = new, furb = first, lurb = last */
 	struct urb_priv *eurbp, *urbp, *furbp, *lurbp;
 	struct list_head *tmp;
-	struct uhci_td *td, *ltd;
+	struct uhci_td *ftd, *lltd;
 	unsigned long flags;
 
 	eurbp = eurb->hcpriv;
 	urbp = urb->hcpriv;
 
-	spin_lock_irqsave(&uhci_append_urb_lock, flags);
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
 
-	/* Find the beginning URB in the queue */
+	/* Find the first URB in the queue */
 	if (eurbp->queued) {
-		struct list_head *head = &eurbp->urb_queue_list;
+		struct list_head *head = &eurbp->queue_list;
 
 		tmp = head->next;
 		while (tmp != head) {
 			struct urb_priv *turbp =
-				list_entry(tmp, struct urb_priv, urb_queue_list);
-
-			tmp = tmp->next;
+				list_entry(tmp, struct urb_priv, queue_list);
 
 			if (!turbp->queued)
 				break;
+
+			tmp = tmp->next;
 		}
 	} else
-		tmp = &eurbp->urb_queue_list;
+		tmp = &eurbp->queue_list;
 
-	furbp = list_entry(tmp, struct urb_priv, urb_queue_list);
+	furbp = list_entry(tmp, struct urb_priv, queue_list);
+	lurbp = list_entry(furbp->queue_list.prev, struct urb_priv, queue_list);
 
-	tmp = furbp->urb_queue_list.prev;
-	lurbp = list_entry(tmp, struct urb_priv, urb_queue_list);
+	lltd = list_entry(lurbp->td_list.prev, struct uhci_td, list);
+	ftd = list_entry(urbp->td_list.next, struct uhci_td, list);
 
-	/* Add this one to the end */
-	list_add_tail(&urbp->urb_queue_list, &furbp->urb_queue_list);
+	uhci_fixup_toggle(urb, uhci_toggle(lltd->info) ^ 1);
 
-	/* Grab the last TD from the last URB */
-	ltd = list_entry(lurbp->list.prev, struct uhci_td, list);
+	/* No breadth since this will only be called for bulk transfers */
+	lltd->link = ftd->dma_handle;
 
-	/* Grab the first TD from the first URB */
-	td = list_entry(urbp->list.next, struct uhci_td, list);
+	list_add_tail(&urbp->queue_list, &furbp->queue_list);
 
-	/* No breadth since this will only be called for bulk transfers */
-	ltd->link = virt_to_bus(td);
+	urbp->queued = 1;
 
-	spin_unlock_irqrestore(&uhci_append_urb_lock, flags);
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 }
 
 static void uhci_delete_queued_urb(struct uhci *uhci, struct urb *urb)
 {
 	struct urb_priv *urbp, *nurbp;
+	struct list_head *head, *tmp;
+	struct urb_priv *purbp;
+	struct uhci_td *pltd;
+	unsigned int toggle;
 	unsigned long flags;
 
 	urbp = urb->hcpriv;
 
-	spin_lock_irqsave(&uhci_append_urb_lock, flags);
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
+
+	if (list_empty(&urbp->queue_list))
+		goto out;
+
+	nurbp = list_entry(urbp->queue_list.next, struct urb_priv, queue_list);
+
+	/* Fix up the toggle for the next URB's */
+	if (!urbp->queued)
+		toggle = usb_gettoggle(urb->dev, usb_pipeendpoint(urb->pipe), usb_pipeout(urb->pipe));
+	else {
+		purbp = list_entry(urbp->queue_list.prev, struct urb_priv,
+				queue_list);
+
+		pltd = list_entry(purbp->td_list.prev, struct uhci_td, list);
+
+		toggle = uhci_toggle(pltd->info) ^ 1;
+	}
+	
+	head = &urbp->queue_list;
+	tmp = head->next;
+	while (head != tmp) {
+		struct urb_priv *turbp;
+
+		turbp = list_entry(tmp, struct urb_priv, queue_list);
+
+		tmp = tmp->next;
+
+		if (!turbp->queued)
+			break;
+
+		toggle = uhci_fixup_toggle(turbp->urb, toggle);
+	}
 
-	nurbp = list_entry(urbp->urb_queue_list.next, struct urb_priv,
-			urb_queue_list);
+	usb_settoggle(urb->dev, usb_pipeendpoint(urb->pipe),
+		usb_pipeout(urb->pipe), toggle);
 
 	if (!urbp->queued) {
 		/* We're the head, so just insert the QH for the next URB */
-		uhci_insert_qh(uhci, &uhci->skel_bulk_qh, nurbp->qh);
+		_uhci_insert_qh(uhci, uhci->skel_bulk_qh, nurbp->qh);
 		nurbp->queued = 0;
 	} else {
-		struct urb_priv *purbp;
-		struct uhci_td *ptd;
-
 		/* We're somewhere in the middle (or end). A bit trickier */
 		/*  than the head scenario */
-		purbp = list_entry(urbp->urb_queue_list.prev, struct urb_priv,
-				urb_queue_list);
+		purbp = list_entry(urbp->queue_list.prev, struct urb_priv,
+				queue_list);
+
+		pltd = list_entry(purbp->td_list.prev, struct uhci_td, list);
+		if (nurbp->queued) {
+			struct uhci_td *nftd;
 
-		ptd = list_entry(purbp->list.prev, struct uhci_td, list);
-		if (nurbp->queued)
 			/* Close the gap between the two */
-			ptd->link = virt_to_bus(list_entry(nurbp->list.next,
-					struct uhci_td, list));
-		else
+			nftd = list_entry(nurbp->td_list.next, struct uhci_td,
+					list);
+			pltd->link = nftd->dma_handle;
+		} else
 			/* The next URB happens to be the beggining, so */
 			/*  we're the last, end the chain */
-			ptd->link = UHCI_PTR_TERM;
-		
+			pltd->link = UHCI_PTR_TERM;
 	}
 
-	list_del(&urbp->urb_queue_list);
+	list_del(&urbp->queue_list);
+	INIT_LIST_HEAD(&urbp->queue_list);
 
-	spin_unlock_irqrestore(&uhci_append_urb_lock, flags);
+out:
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 }
 
-struct urb_priv *uhci_alloc_urb_priv(struct urb *urb)
+struct urb_priv *uhci_alloc_urb_priv(struct urb *urb, struct uhci *uhci)
 {
 	struct urb_priv *urbp;
 
 	urbp = kmem_cache_alloc(uhci_up_cachep, in_interrupt() ? SLAB_ATOMIC : SLAB_KERNEL);
-	if (!urbp)
+	if (!urbp) {
+		err("uhci_alloc_urb_priv: couldn't allocate memory for urb_priv\n");
 		return NULL;
+	}
 
 	memset((void *)urbp, 0, sizeof(*urbp));
 
 	urbp->inserttime = jiffies;
 	urbp->urb = urb;
+	urbp->dev = urb->dev;
 	
-	INIT_LIST_HEAD(&urbp->list);
-	INIT_LIST_HEAD(&urbp->urb_queue_list);
+	INIT_LIST_HEAD(&urbp->td_list);
+	INIT_LIST_HEAD(&urbp->queue_list);
+	INIT_LIST_HEAD(&urbp->complete_list);
 
 	urb->hcpriv = urbp;
 
+	if (urb->transfer_buffer_length) {
+		urbp->transfer_buffer = pci_alloc_consistent(uhci->dev,
+			urb->transfer_buffer_length, &urbp->transfer_buffer_dma_handle);
+		if (!urbp->transfer_buffer)
+			return NULL;
+
+		if (usb_pipeout(urb->pipe))
+			memcpy(urbp->transfer_buffer, urb->transfer_buffer,
+				urb->transfer_buffer_length);
+	}
+
+	if (usb_pipetype(urb->pipe) == PIPE_CONTROL && urb->setup_packet) {
+		urbp->setup_buffer = pci_alloc_consistent(uhci->dev,
+			sizeof(devrequest), &urbp->setup_buffer_dma_handle);
+		if (!urbp->setup_buffer)
+			return NULL;
+
+		memcpy(urbp->setup_buffer, urb->setup_packet,
+			sizeof(devrequest));
+	}
+
 	return urbp;
 }
 
@@ -504,13 +653,11 @@
 
 	td->urb = urb;
 
-	list_add_tail(&td->list, &urbp->list);
+	list_add_tail(&td->list, &urbp->td_list);
 }
 
-static void uhci_remove_td_from_urb(struct urb *urb, struct uhci_td *td)
+static void uhci_remove_td_from_urb(struct uhci_td *td)
 {
-	urb = NULL;	/* No warnings */
-
 	if (list_empty(&td->list))
 		return;
 
@@ -522,41 +669,54 @@
 
 static void uhci_destroy_urb_priv(struct urb *urb)
 {
-	struct list_head *tmp, *head;
+	struct list_head *head, *tmp;
 	struct urb_priv *urbp;
 	struct uhci *uhci;
-	struct uhci_td *td;
 	unsigned long flags;
 
 	spin_lock_irqsave(&urb->lock, flags);
 
 	urbp = (struct urb_priv *)urb->hcpriv;
 	if (!urbp)
-		goto unlock;
+		goto out;
 
-	if (!urb->dev || !urb->dev->bus || !urb->dev->bus->hcpriv)
-		goto unlock;
+	if (!urbp->dev || !urbp->dev->bus || !urbp->dev->bus->hcpriv) {
+		warn("uhci_destroy_urb_priv: urb %p belongs to disconnected device or bus?", urb);
+		goto out;
+	}
 
-	uhci = urb->dev->bus->hcpriv;
+	if (!list_empty(&urb->urb_list))
+		warn("uhci_destroy_urb_priv: urb %p still on uhci->urb_list or uhci->remove_list", urb);
 
-	head = &urbp->list;
+	if (!list_empty(&urbp->complete_list))
+		warn("uhci_destroy_urb_priv: urb %p still on uhci->complete_list", urb);
+
+	uhci = urbp->dev->bus->hcpriv;
+
+	head = &urbp->td_list;
 	tmp = head->next;
 	while (tmp != head) {
-		td = list_entry(tmp, struct uhci_td, list);
+		struct uhci_td *td = list_entry(tmp, struct uhci_td, list);
 
 		tmp = tmp->next;
 
-		uhci_remove_td_from_urb(urb, td);
-
+		uhci_remove_td_from_urb(td);
 		uhci_remove_td(uhci, td);
-
-		uhci_free_td(td);
+		uhci_free_td(uhci, td);
 	}
 
+	if (urbp->setup_buffer)
+		pci_free_consistent(uhci->dev, sizeof(devrequest),
+			urbp->setup_buffer, urbp->setup_buffer_dma_handle);
+
+	if (urbp->transfer_buffer)
+		pci_free_consistent(uhci->dev, urb->transfer_buffer_length,
+			urbp->transfer_buffer, urbp->transfer_buffer_dma_handle);
+
 	urb->hcpriv = NULL;
 	kmem_cache_free(uhci_up_cachep, urbp);
 
-unlock:
+out:
 	spin_unlock_irqrestore(&urb->lock, flags);
 }
 
@@ -565,18 +725,15 @@
 	unsigned long flags;
 	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
 
-	if (!urbp)
-		return;
-
-	spin_lock_irqsave(&uhci->framelist_lock, flags);
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
 
 	if ((!(urb->transfer_flags & USB_NO_FSBR)) && (!urbp->fsbr)) {
 		urbp->fsbr = 1;
 		if (!uhci->fsbr++)
-			uhci->skel_term_qh.link = virt_to_bus(&uhci->skel_hs_control_qh) | UHCI_PTR_QH;
+			uhci->skel_term_qh->link = uhci->skel_hs_control_qh->dma_handle | UHCI_PTR_QH;
 	}
 
-	spin_unlock_irqrestore(&uhci->framelist_lock, flags);
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 }
 
 static void uhci_dec_fsbr(struct uhci *uhci, struct urb *urb)
@@ -584,18 +741,15 @@
 	unsigned long flags;
 	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
 
-	if (!urbp)
-		return;
-
-	spin_lock_irqsave(&uhci->framelist_lock, flags);
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
 
 	if ((!(urb->transfer_flags & USB_NO_FSBR)) && urbp->fsbr) {
 		urbp->fsbr = 0;
 		if (!--uhci->fsbr)
-			uhci->skel_term_qh.link = UHCI_PTR_TERM;
+			uhci->skel_term_qh->link = UHCI_PTR_TERM;
 	}
 
-	spin_unlock_irqrestore(&uhci->framelist_lock, flags);
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
 }
 
 /*
@@ -633,7 +787,7 @@
 /*
  * Control transfers
  */
-static int uhci_submit_control(struct urb *urb)
+static int uhci_submit_control(struct urb *urb, struct urb *eurb)
 {
 	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
 	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
@@ -642,7 +796,7 @@
 	unsigned long destination, status;
 	int maxsze = usb_maxpacket(urb->dev, urb->pipe, usb_pipeout(urb->pipe));
 	int len = urb->transfer_buffer_length;
-	unsigned char *data = urb->transfer_buffer;
+	dma_addr_t data = urbp->transfer_buffer_dma_handle;
 
 	/* The "pipe" thing contains the destination in bits 8--18 */
 	destination = (urb->pipe & PIPE_DEVEP_MASK) | USB_PID_SETUP;
@@ -653,13 +807,13 @@
 	/*
 	 * Build the TD for the control request
 	 */
-	td = uhci_alloc_td(urb->dev);
+	td = uhci_alloc_td(uhci, urb->dev);
 	if (!td)
 		return -ENOMEM;
 
 	uhci_add_td_to_urb(urb, td);
 	uhci_fill_td(td, status, destination | (7 << 21),
-		virt_to_bus(urb->setup_packet));
+		urbp->setup_buffer_dma_handle);
 
 	/*
 	 * If direction is "send", change the frame from SETUP (0x2D)
@@ -679,7 +833,7 @@
 		if (pktsze > maxsze)
 			pktsze = maxsze;
 
-		td = uhci_alloc_td(urb->dev);
+		td = uhci_alloc_td(uhci, urb->dev);
 		if (!td)
 			return -ENOMEM;
 
@@ -688,7 +842,7 @@
 	
 		uhci_add_td_to_urb(urb, td);
 		uhci_fill_td(td, status, destination | ((pktsze - 1) << 21),
-			virt_to_bus(data));
+			data);
 
 		data += pktsze;
 		len -= pktsze;
@@ -697,7 +851,7 @@
 	/*
 	 * Build the final TD for control status 
 	 */
-	td = uhci_alloc_td(urb->dev);
+	td = uhci_alloc_td(uhci, urb->dev);
 	if (!td)
 		return -ENOMEM;
 
@@ -719,23 +873,22 @@
 	uhci_fill_td(td, status | TD_CTRL_IOC,
 		destination | (UHCI_NULL_DATA_SIZE << 21), 0);
 
-	qh = uhci_alloc_qh(urb->dev);
+	qh = uhci_alloc_qh(uhci, urb->dev);
 	if (!qh)
 		return -ENOMEM;
 
 	/* Low speed or small transfers gets a different queue and treatment */
 	if (urb->pipe & TD_CTRL_LS) {
 		uhci_insert_tds_in_qh(qh, urb, 0);
-		uhci_insert_qh(uhci, &uhci->skel_ls_control_qh, qh);
+		uhci_insert_qh(uhci, uhci->skel_ls_control_qh, qh);
 	} else {
 		uhci_insert_tds_in_qh(qh, urb, 1);
-		uhci_insert_qh(uhci, &uhci->skel_hs_control_qh, qh);
+		uhci_insert_qh(uhci, uhci->skel_hs_control_qh, qh);
 		uhci_inc_fsbr(uhci, urb);
 	}
 
 	urbp->qh = qh;
-
-	uhci_add_urb_list(uhci, urb);
+	qh->urbp = urbp;
 
 	return -EINPROGRESS;
 }
@@ -750,12 +903,10 @@
 	unsigned int status;
 	int ret = 0;
 
-	if (!urbp)
+	if (list_empty(&urbp->td_list))
 		return -EINVAL;
 
-	head = &urbp->list;
-	if (head->next == head)
-		return -EINVAL;
+	head = &urbp->td_list;
 
 	if (urbp->short_control_packet) {
 		tmp = head->prev;
@@ -845,12 +996,16 @@
 	    			uhci_packetout(td->info));
 
 err:
-	if (debug && ret != -EPIPE) {
+	if ((debug == 1 && ret != -EPIPE) || debug > 1) {
+		char buf[1024];
+
 		/* Some debugging code */
 		dbg("uhci_result_control() failed with status %x", status);
 
 		/* Print the chain for debugging purposes */
-		uhci_show_urb_queue(urb);
+		uhci_show_qh(urbp->qh, buf, sizeof(buf));
+
+		printk("%s", buf);
 	}
 
 	return ret;
@@ -868,34 +1023,34 @@
 	uhci_remove_qh(uhci, urbp->qh);
 
 	/* Delete all of the TD's except for the status TD at the end */
-	head = &urbp->list;
+	head = &urbp->td_list;
 	tmp = head->next;
 	while (tmp != head && tmp->next != head) {
 		struct uhci_td *td = list_entry(tmp, struct uhci_td, list);
 
 		tmp = tmp->next;
 
-		uhci_remove_td_from_urb(urb, td);
-
+		uhci_remove_td_from_urb(td);
 		uhci_remove_td(uhci, td);
-
-		uhci_free_td(td);
+		uhci_free_td(uhci, td);
 	}
 
-	urbp->qh = uhci_alloc_qh(urb->dev);
+	urbp->qh = uhci_alloc_qh(uhci, urb->dev);
 	if (!urbp->qh) {
 		err("unable to allocate new QH for control retrigger");
 		return -ENOMEM;
 	}
 
+	urbp->qh->urbp = urbp;
+
 	/* One TD, who cares about Breadth first? */
 	uhci_insert_tds_in_qh(urbp->qh, urb, 0);
 
 	/* Low speed or small transfers gets a different queue and treatment */
 	if (urb->pipe & TD_CTRL_LS)
-		uhci_insert_qh(uhci, &uhci->skel_ls_control_qh, urbp->qh);
+		uhci_insert_qh(uhci, uhci->skel_ls_control_qh, urbp->qh);
 	else
-		uhci_insert_qh(uhci, &uhci->skel_hs_control_qh, urbp->qh);
+		uhci_insert_qh(uhci, uhci->skel_hs_control_qh, urbp->qh);
 
 	return -EINPROGRESS;
 }
@@ -908,6 +1063,7 @@
 	struct uhci_td *td;
 	unsigned long destination, status;
 	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
+	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
 
 	if (urb->transfer_buffer_length > usb_maxpacket(urb->dev, urb->pipe, usb_pipeout(urb->pipe)))
 		return -EINVAL;
@@ -917,7 +1073,7 @@
 
 	status = (urb->pipe & TD_CTRL_LS) | TD_CTRL_ACTIVE | TD_CTRL_IOC;
 
-	td = uhci_alloc_td(urb->dev);
+	td = uhci_alloc_td(uhci, urb->dev);
 	if (!td)
 		return -ENOMEM;
 
@@ -927,12 +1083,9 @@
 	usb_dotoggle(urb->dev, usb_pipeendpoint(urb->pipe), usb_pipeout(urb->pipe));
 
 	uhci_add_td_to_urb(urb, td);
-	uhci_fill_td(td, status, destination,
-		virt_to_bus(urb->transfer_buffer));
-
-	uhci_insert_td(uhci, &uhci->skeltd[__interval_to_skel(urb->interval)], td);
+	uhci_fill_td(td, status, destination, urbp->transfer_buffer_dma_handle);
 
-	uhci_add_urb_list(uhci, urb);
+	uhci_insert_td(uhci, uhci->skeltd[__interval_to_skel(urb->interval)], td);
 
 	return -EINPROGRESS;
 }
@@ -945,12 +1098,9 @@
 	unsigned int status;
 	int ret = 0;
 
-	if (!urbp)
-		return -EINVAL;
-
 	urb->actual_length = 0;
 
-	head = &urbp->list;
+	head = &urbp->td_list;
 	tmp = head->next;
 	while (tmp != head) {
 		td = list_entry(tmp, struct uhci_td, list);
@@ -996,16 +1146,20 @@
 	    			uhci_packetout(td->info));
 
 err:
-	if (debug && ret != -EPIPE) {
+	if ((debug == 1 && ret != -EPIPE) || debug > 1) {
+		char buf[1024];
+
 		/* Some debugging code */
 		dbg("uhci_result_interrupt/bulk() failed with status %x",
 			status);
 
 		/* Print the chain for debugging purposes */
 		if (urbp->qh)
-			uhci_show_urb_queue(urb);
+			uhci_show_qh(urbp->qh, buf, sizeof(buf));
 		else
-			uhci_show_td(td);
+			uhci_show_td(td, buf, sizeof(buf));
+
+		printk(buf);
 	}
 
 	return ret;
@@ -1013,24 +1167,28 @@
 
 static void uhci_reset_interrupt(struct urb *urb)
 {
-	struct list_head *tmp;
+	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
 	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
 	struct uhci_td *td;
+	unsigned long flags;
 
-	if (!urbp)
-		return;
+	spin_lock_irqsave(&urb->lock, flags);
 
-	tmp = urbp->list.next;
-	td = list_entry(tmp, struct uhci_td, list);
-	if (!td)
-		return;
+	/* Root hub is special */
+	if (urb->dev == uhci->rh.dev)
+		goto out;
+
+	td = list_entry(urbp->td_list.next, struct uhci_td, list);
 
 	td->status = (td->status & 0x2F000000) | TD_CTRL_ACTIVE | TD_CTRL_IOC;
 	td->info &= ~(1 << TD_TOKEN_TOGGLE);
 	td->info |= (usb_gettoggle(urb->dev, usb_pipeendpoint(urb->pipe), usb_pipeout(urb->pipe)) << TD_TOKEN_TOGGLE);
 	usb_dotoggle(urb->dev, usb_pipeendpoint(urb->pipe), usb_pipeout(urb->pipe));
 
+out:
 	urb->status = -EINPROGRESS;
+
+	spin_unlock_irqrestore(&urb->lock, flags);
 }
 
 /*
@@ -1044,8 +1202,8 @@
 	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
 	int maxsze = usb_maxpacket(urb->dev, urb->pipe, usb_pipeout(urb->pipe));
 	int len = urb->transfer_buffer_length;
-	unsigned char *data = urb->transfer_buffer;
 	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
+	dma_addr_t data = urbp->transfer_buffer_dma_handle;
 
 	if (len < 0)
 		return -EINVAL;
@@ -1072,7 +1230,7 @@
 		if (pktsze > maxsze)
 			pktsze = maxsze;
 
-		td = uhci_alloc_td(urb->dev);
+		td = uhci_alloc_td(uhci, urb->dev);
 		if (!td)
 			return -ENOMEM;
 
@@ -1080,7 +1238,7 @@
 		uhci_fill_td(td, status, destination | ((pktsze - 1) << 21) |
 			(usb_gettoggle(urb->dev, usb_pipeendpoint(urb->pipe),
 			 usb_pipeout(urb->pipe)) << TD_TOKEN_TOGGLE),
-			virt_to_bus(data));
+			data);
 
 		data += pktsze;
 		len -= maxsze;
@@ -1092,22 +1250,20 @@
 			usb_pipeout(urb->pipe));
 	} while (len > 0);
 
-	qh = uhci_alloc_qh(urb->dev);
+	qh = uhci_alloc_qh(uhci, urb->dev);
 	if (!qh)
 		return -ENOMEM;
 
 	urbp->qh = qh;
+	qh->urbp = urbp;
 
 	/* Always assume depth first */
 	uhci_insert_tds_in_qh(qh, urb, 1);
 
-	if (urb->transfer_flags & USB_QUEUE_BULK && eurb) {
-		urbp->queued = 1;
+	if (urb->transfer_flags & USB_QUEUE_BULK && eurb)
 		uhci_append_queued_urb(uhci, eurb, urb);
-	} else
-		uhci_insert_qh(uhci, &uhci->skel_bulk_qh, qh);
-
-	uhci_add_urb_list(uhci, urb);
+	else
+		uhci_insert_qh(uhci, uhci->skel_bulk_qh, qh);
 
 	uhci_inc_fsbr(uhci, urb);
 
@@ -1124,11 +1280,12 @@
 {
 	struct urb *last_urb = NULL;
 	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
-	struct list_head *tmp, *head = &uhci->urb_list;
+	struct list_head *tmp, *head;
 	int ret = 0;
 	unsigned long flags;
 
-	nested_lock(&uhci->urblist_lock, flags);
+	spin_lock_irqsave(&uhci->urb_list_lock, flags);
+	head = &uhci->urb_list;
 	tmp = head->next;
 	while (tmp != head) {
 		struct urb *u = list_entry(tmp, struct urb, urb_list);
@@ -1150,7 +1307,7 @@
 	} else
 		ret = -1;	/* no previous urb found */
 
-	nested_unlock(&uhci->urblist_lock, flags);
+	spin_unlock_irqrestore(&uhci->urb_list_lock, flags);
 
 	return ret;
 }
@@ -1181,12 +1338,16 @@
 	return 0;
 }
 
+/*
+ * Isochronous transfers
+ */
 static int uhci_submit_isochronous(struct urb *urb)
 {
 	struct uhci_td *td;
 	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
 	int i, ret, framenum;
 	int status, destination;
+	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
 
 	status = TD_CTRL_ACTIVE | TD_CTRL_IOS;
 	destination = (urb->pipe & PIPE_DEVEP_MASK) | usb_packetid(urb->pipe);
@@ -1200,13 +1361,13 @@
 		if (!urb->iso_frame_desc[i].length)
 			continue;
 
-		td = uhci_alloc_td(urb->dev);
+		td = uhci_alloc_td(uhci, urb->dev);
 		if (!td)
 			return -ENOMEM;
 
 		uhci_add_td_to_urb(urb, td);
 		uhci_fill_td(td, status, destination | ((urb->iso_frame_desc[i].length - 1) << 21),
-			virt_to_bus(urb->transfer_buffer + urb->iso_frame_desc[i].offset));
+			urbp->transfer_buffer_dma_handle + urb->iso_frame_desc[i].offset);
 
 		if (i + 1 >= urb->number_of_packets)
 			td->status |= TD_CTRL_IOC;
@@ -1214,8 +1375,6 @@
 		uhci_insert_td_frame_list(uhci, td, framenum);
 	}
 
-	uhci_add_urb_list(uhci, urb);
-
 	return -EINPROGRESS;
 }
 
@@ -1226,13 +1385,10 @@
 	int status;
 	int i, ret = 0;
 
-	if (!urbp)
-		return -EINVAL;
-
 	urb->actual_length = 0;
 
 	i = 0;
-	head = &urbp->list;
+	head = &urbp->td_list;
 	tmp = head->next;
 	while (tmp != head) {
 		struct uhci_td *td = list_entry(tmp, struct uhci_td, list);
@@ -1249,7 +1405,7 @@
 
 		status = uhci_map_status(uhci_status_bits(td->status), usb_pipeout(urb->pipe));
 		urb->iso_frame_desc[i].status = status;
-		if (status != 0) {
+		if (status) {
 			urb->error_count++;
 			ret = status;
 		}
@@ -1262,28 +1418,30 @@
 
 static struct urb *uhci_find_urb_ep(struct uhci *uhci, struct urb *urb)
 {
-	struct list_head *tmp, *head = &uhci->urb_list;
+	struct list_head *tmp, *head;
 	unsigned long flags;
 	struct urb *u = NULL;
 
+	/* We don't match Isoc transfers since they are special */
 	if (usb_pipeisoc(urb->pipe))
 		return NULL;
 
-	nested_lock(&uhci->urblist_lock, flags);
+	spin_lock_irqsave(&uhci->urb_list_lock, flags);
+	head = &uhci->urb_list;
 	tmp = head->next;
 	while (tmp != head) {
 		u = list_entry(tmp, struct urb, urb_list);
 
 		tmp = tmp->next;
 
-		if (u->dev == urb->dev &&
-		    u->pipe == urb->pipe)
-			goto found;
+		if (u->dev == urb->dev && u->pipe == urb->pipe &&
+		    u->status == -EINPROGRESS)
+			goto out;
 	}
 	u = NULL;
 
-found:
-	nested_unlock(&uhci->urblist_lock, flags);
+out:
+	spin_unlock_irqrestore(&uhci->urb_list_lock, flags);
 
 	return u;
 }
@@ -1293,38 +1451,62 @@
 	int ret = -EINVAL;
 	struct uhci *uhci;
 	unsigned long flags;
-	struct urb *u;
+	struct urb *eurb;
 	int bustime;
 
 	if (!urb)
 		return -EINVAL;
 
-	if (!urb->dev || !urb->dev->bus || !urb->dev->bus->hcpriv)
+	if (!urb->dev || !urb->dev->bus || !urb->dev->bus->hcpriv) {
+		warn("uhci_submit_urb: urb %p belongs to disconnected device or bus?", urb);
 		return -ENODEV;
+	}
 
 	uhci = (struct uhci *)urb->dev->bus->hcpriv;
 
-	/* Short circuit the virtual root hub */
-	if (usb_pipedevice(urb->pipe) == uhci->rh.devnum)
-		return rh_submit_urb(urb);
-
-	u = uhci_find_urb_ep(uhci, urb);
-	if (u && !(urb->transfer_flags & USB_QUEUE_BULK))
-		return -ENXIO;
+	/* Grab the urb_list lock first to avoid deadlocks */
+	spin_lock_irqsave(&uhci->urb_list_lock, flags);
+	/* We use tail to make find_urb_ep more efficient */
+	list_add_tail(&urb->urb_list, &uhci->urb_list);
+	spin_unlock_irqrestore(&uhci->urb_list_lock, flags);
 
 	usb_inc_dev_use(urb->dev);
+
 	spin_lock_irqsave(&urb->lock, flags);
 
-	if (!uhci_alloc_urb_priv(urb)) {
+	if (urb->status == -EINPROGRESS || urb->status == -ECONNRESET ||
+	    urb->status == -ECONNABORTED) {
+		dbg("uhci_submit_urb: urb not available to submit (status = %d)", urb->status);
+		/* Since we can have problems on the out path */
 		spin_unlock_irqrestore(&urb->lock, flags);
 		usb_dec_dev_use(urb->dev);
 
-		return -ENOMEM;
+		return ret;
+	}
+
+	if (!uhci_alloc_urb_priv(urb, uhci)) {
+		ret = -ENOMEM;
+
+		goto out;
+	}
+
+	eurb = uhci_find_urb_ep(uhci, urb);
+	if (eurb && !(urb->transfer_flags & USB_QUEUE_BULK)) {
+		ret = -ENXIO;
+
+		goto out;
+	}
+
+	/* Short circuit the virtual root hub */
+	if (urb->dev == uhci->rh.dev) {
+		ret = rh_submit_urb(urb);
+
+		goto out;
 	}
 
 	switch (usb_pipetype(urb->pipe)) {
 	case PIPE_CONTROL:
-		ret = uhci_submit_control(urb);
+		ret = uhci_submit_control(urb, eurb);
 		break;
 	case PIPE_INTERRUPT:
 		if (urb->bandwidth == 0) {	/* not yet checked/allocated */
@@ -1340,7 +1522,7 @@
 			ret = uhci_submit_interrupt(urb);
 		break;
 	case PIPE_BULK:
-		ret = uhci_submit_bulk(urb, u);
+		ret = uhci_submit_bulk(urb, eurb);
 		break;
 	case PIPE_ISOCHRONOUS:
 		if (urb->bandwidth == 0) {	/* not yet checked/allocated */
@@ -1362,16 +1544,24 @@
 		break;
 	}
 
+out:
 	urb->status = ret;
 
 	spin_unlock_irqrestore(&urb->lock, flags);
 
 	if (ret == -EINPROGRESS)
-		ret = 0;
-	else {
-		uhci_unlink_generic(urb);
-		usb_dec_dev_use(urb->dev);
-	}
+		return 0;
+
+	/* If we got here, then we're done with this URB */
+	spin_lock_irqsave(&uhci->urb_list_lock, flags);
+	list_del(&urb->urb_list);
+	INIT_LIST_HEAD(&urb->urb_list);
+	spin_unlock_irqrestore(&uhci->urb_list_lock, flags);
+
+	uhci_unlink_generic(uhci, urb);
+	uhci_destroy_urb_priv(urb);
+
+	usb_dec_dev_use(urb->dev);
 
 	return ret;
 }
@@ -1379,18 +1569,28 @@
 /*
  * Return the result of a transfer
  *
- * Must be called with urblist_lock acquired
+ * Must be called with urb_list_lock acquired
  */
-static void uhci_transfer_result(struct urb *urb)
+static void uhci_transfer_result(struct uhci *uhci, struct urb *urb)
 {
-	struct usb_device *dev = urb->dev;
-	struct urb *turb;
-	int proceed = 0, is_ring = 0;
 	int ret = -EINVAL;
 	unsigned long flags;
+	struct urb_priv *urbp;
+
+	/* The root hub is special */
+	if (urb->dev == uhci->rh.dev)
+		return;
 
 	spin_lock_irqsave(&urb->lock, flags);
 
+	urbp = (struct urb_priv *)urb->hcpriv;
+
+	if (urb->status != -EINPROGRESS) {
+		info("uhci_transfer_result: called for URB %p not in flight?", urb);
+		spin_unlock_irqrestore(&urb->lock, flags);
+		return;
+	}
+
 	switch (usb_pipetype(urb->pipe)) {
 	case PIPE_CONTROL:
 		ret = uhci_result_control(urb);
@@ -1406,7 +1606,7 @@
 		break;
 	}
 
-	urb->status = ret;
+	urbp->status = ret;
 
 	spin_unlock_irqrestore(&urb->lock, flags);
 
@@ -1421,106 +1621,65 @@
 		/* Spinlock needed ? */
 		if (urb->bandwidth)
 			usb_release_bandwidth(urb->dev, urb, 1);
-		uhci_unlink_generic(urb);
+		uhci_unlink_generic(uhci, urb);
 		break;
 	case PIPE_INTERRUPT:
 		/* Interrupts are an exception */
 		if (urb->interval) {
-			urb->complete(urb);
-			uhci_reset_interrupt(urb);
-			return;
+			uhci_add_complete(urb);
+			return;		/* <-- note return */
 		}
 
 		/* Release bandwidth for Interrupt or Isoc. transfers */
 		/* Spinlock needed ? */
 		if (urb->bandwidth)
 			usb_release_bandwidth(urb->dev, urb, 0);
-		uhci_unlink_generic(urb);
+		uhci_unlink_generic(uhci, urb);
 		break;
+	default:
+		info("uhci_transfer_result: unknown pipe type %d for urb %p\n",
+			usb_pipetype(urb->pipe), urb);
 	}
 
-	if (urb->next) {
-		turb = urb->next;
-		do {
-			if (turb->status != -EINPROGRESS) {
-				proceed = 1;
-				break;
-			}
-
-			turb = turb->next;
-		} while (turb && turb != urb && turb != urb->next);
-
-		if (turb == urb || turb == urb->next)
-			is_ring = 1;
-	}
-
-	if (urb->complete && !proceed) {
-		urb->complete(urb);
-		if (!proceed && is_ring)
-			uhci_submit_urb(urb);
-	}
-
-	if (proceed && urb->next) {
-		turb = urb->next;
-		do {
-			if (turb->status != -EINPROGRESS &&
-			    uhci_submit_urb(turb) != 0)
-
-			turb = turb->next;
-		} while (turb && turb != urb->next);
+	list_del(&urb->urb_list);
+	INIT_LIST_HEAD(&urb->urb_list);
 
-		if (urb->complete)
-			urb->complete(urb);
-	}
-
-	/* We decrement the usage count after we're done with everything */
-	usb_dec_dev_use(dev);
+	uhci_add_complete(urb);
 }
 
-static int uhci_unlink_generic(struct urb *urb)
+static void uhci_unlink_generic(struct uhci *uhci, struct urb *urb)
 {
 	struct urb_priv *urbp = urb->hcpriv;
-	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
 
+	/* We can get called when urbp allocation fails, so check */
 	if (!urbp)
-		return -EINVAL;
+		return;
 
 	uhci_dec_fsbr(uhci, urb);	/* Safe since it checks */
 
-	uhci_remove_urb_list(uhci, urb);
-
 	if (urbp->qh)
 		/* The interrupt loop will reclaim the QH's */
 		uhci_remove_qh(uhci, urbp->qh);
 
-	if (!list_empty(&urbp->urb_queue_list))
-		uhci_delete_queued_urb(uhci, urb);
-
-	uhci_destroy_urb_priv(urb);
-
-	urb->dev = NULL;
-
-	return 0;
+	uhci_delete_queued_urb(uhci, urb);	/* It checks */
 }
 
+/* FIXME: If we forcefully unlink an urb, we should reset the toggle for */
+/*  that pipe to match what actually completed */
 static int uhci_unlink_urb(struct urb *urb)
 {
 	struct uhci *uhci;
-	int ret = 0;
 	unsigned long flags;
+	struct urb_priv *urbp = urb->hcpriv;
 
 	if (!urb)
 		return -EINVAL;
 
-	if (!urb->dev || !urb->dev->bus)
+	if (!urb->dev || !urb->dev->bus || !urb->dev->bus->hcpriv)
 		return -ENODEV;
 
 	uhci = (struct uhci *)urb->dev->bus->hcpriv;
 
-	/* Short circuit the virtual root hub */
-	if (usb_pipedevice(urb->pipe) == uhci->rh.devnum)
-		return rh_unlink_urb(urb);
-
 	/* Release bandwidth for Interrupt or Isoc. transfers */
 	/* Spinlock needed ? */
 	if (urb->bandwidth) {
@@ -1536,13 +1695,28 @@
 		}
 	}
 
-	if (urb->status == -EINPROGRESS) {
-		uhci_unlink_generic(urb);
+	if (urb->status != -EINPROGRESS)
+		return -1;
+
+	spin_lock_irqsave(&uhci->urb_list_lock, flags);
+	list_del(&urb->urb_list);
+	INIT_LIST_HEAD(&urb->urb_list);
+	spin_unlock_irqrestore(&uhci->urb_list_lock, flags);
 
+	uhci_unlink_generic(uhci, urb);
+
+	/* Short circuit the virtual root hub */
+	if (urb->dev == uhci->rh.dev) {
+		rh_unlink_urb(urb);
+		uhci_call_completion(urb);
+	} else {
 		if (urb->transfer_flags & USB_ASYNC_UNLINK) {
-			urb->status = -ECONNABORTED;
+			/* urb_list is available now since we called */
+			/*  uhci_unlink_generic already */
+
+			urbp->status = urb->status = -ECONNABORTED;
 
-			spin_lock_irqsave(&uhci->urb_remove_lock, flags);
+			spin_lock_irqsave(&uhci->urb_remove_list_lock, flags);
 
 			/* Check to see if the remove list is empty */
 			if (list_empty(&uhci->urb_remove_list))
@@ -1550,7 +1724,7 @@
 			
 			list_add(&urb->urb_list, &uhci->urb_remove_list);
 
-			spin_unlock_irqrestore(&uhci->urb_remove_lock, flags);
+			spin_unlock_irqrestore(&uhci->urb_remove_list_lock, flags);
 		} else {
 			urb->status = -ENOENT;
 
@@ -1563,12 +1737,11 @@
 			} else
 				schedule_timeout(1+1*HZ/1000); 
 
-			if (urb->complete)
-				urb->complete(urb);
+			uhci_call_completion(urb);
 		}
 	}
 
-	return ret;
+	return 0;
 }
 
 static int uhci_fsbr_timeout(struct uhci *uhci, struct urb *urb)
@@ -1584,7 +1757,7 @@
 	/*  and we'd be turning on FSBR next frame anyway, so it's a wash */
 	urbp->fsbr_timeout = 1;
 
-	head = &urbp->list;
+	head = &urbp->td_list;
 	tmp = head->next;
 	while (tmp != head) {
 		struct uhci_td *td = list_entry(tmp, struct uhci_td, list);
@@ -1620,9 +1793,7 @@
 	uhci_unlink_urb
 };
 
-/* -------------------------------------------------------------------
-   Virtual Root Hub
-   ------------------------------------------------------------------- */
+/* Virtual Root Hub */
 
 static __u8 root_hub_dev_des[] =
 {
@@ -1696,7 +1867,6 @@
 	0xff			/*  __u8  PortPwrCtrlMask; *** 7 ports max *** */
 };
 
-/*-------------------------------------------------------------------------*/
 /* prepare Interrupt pipe transaction data; HUB INTERRUPT ENDPOINT */
 static int rh_send_irq(struct urb *urb)
 {
@@ -1704,6 +1874,7 @@
 	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
 	unsigned int io_addr = uhci->io_addr;
 	__u16 data = 0;
+	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
 
 	for (i = 0; i < uhci->rh.numports; i++) {
 		data |= ((inw(io_addr + USBPORTSC1 + i * 2) & 0xa) > 0 ? (1 << (i + 1)) : 0);
@@ -1711,19 +1882,20 @@
 	}
 
 	*(__u16 *) urb->transfer_buffer = cpu_to_le16(data);
-	urb->actual_length = len;
-	urb->status = USB_ST_NOERROR;
 
 	if ((data > 0) && (uhci->rh.send != 0)) {
 		dbg("root-hub INT complete: port1: %x port2: %x data: %x",
 			inw(io_addr + USBPORTSC1), inw(io_addr + USBPORTSC2), data);
-		urb->complete(urb);
+		urb->actual_length = len;
+		urbp->status = 0;
+
+		uhci_add_complete(urb);
+		uhci_set_next_interrupt(uhci);
 	}
 
-	return USB_ST_NOERROR;
+	return 0;
 }
 
-/*-------------------------------------------------------------------------*/
 /* Virtual Root Hub INTs are polled by this timer every "interval" ms */
 static int rh_init_int_timer(struct urb *urb);
 
@@ -1731,46 +1903,49 @@
 {
 	struct urb *urb = (struct urb *)ptr;
 	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
-	struct list_head *tmp, *head = &uhci->urb_list;
-	struct urb_priv *urbp;
-	int len;
+	struct list_head list, *tmp, *head;
 	unsigned long flags;
 
-	if (uhci->rh.send) {
-		len = rh_send_irq(urb);
-		if (len > 0) {
-			urb->actual_length = len;
-			if (urb->complete)
-				urb->complete(urb);
+	if (uhci->rh.send)
+		rh_send_irq(urb);
+
+	INIT_LIST_HEAD(&list);
+
+	spin_lock_irqsave(&uhci->urb_list_lock, flags);
+	head = &uhci->urb_list;
+	tmp = head->next;
+	while (tmp != head) {
+		struct urb *u = list_entry(tmp, struct urb, urb_list);
+		struct urb_priv *urbp = (struct urb_priv *)u->hcpriv;
+
+		tmp = tmp->next;
+
+		/* Check if the FSBR timed out */
+		if (urbp->fsbr && time_after_eq(jiffies, urbp->inserttime + IDLE_TIMEOUT))
+			uhci_fsbr_timeout(uhci, u);
+
+		/* Check if the URB timed out */
+		if (u->timeout && time_after_eq(jiffies, u->timeout)) {
+			list_del(&u->urb_list);
+			list_add_tail(&u->urb_list, &list);
 		}
 	}
+	spin_unlock_irqrestore(&uhci->urb_list_lock, flags);
 
-	nested_lock(&uhci->urblist_lock, flags);
+	head = &list;
 	tmp = head->next;
 	while (tmp != head) {
-		struct urb *u = list_entry(tmp, urb_t, urb_list);
+		struct urb *u = list_entry(tmp, struct urb, urb_list);
 
 		tmp = tmp->next;
 
-		urbp = (struct urb_priv *)u->hcpriv;
-		if (urbp) {
-			/* Check if the FSBR timed out */
-			if (urbp->fsbr && time_after_eq(jiffies, urbp->inserttime + IDLE_TIMEOUT))
-				uhci_fsbr_timeout(uhci, u);
-
-			/* Check if the URB timed out */
-			if (u->timeout && time_after_eq(jiffies, u->timeout)) {
-				u->transfer_flags |= USB_ASYNC_UNLINK | USB_TIMEOUT_KILLED;
-				uhci_unlink_urb(u);
-			}
-		}
+		u->transfer_flags |= USB_ASYNC_UNLINK | USB_TIMEOUT_KILLED;
+		uhci_unlink_urb(u);
 	}
-	nested_unlock(&uhci->urblist_lock, flags);
 
 	rh_init_int_timer(urb);
 }
 
-/*-------------------------------------------------------------------------*/
 /* Root Hub INTs are polled by this timer */
 static int rh_init_int_timer(struct urb *urb)
 {
@@ -1786,7 +1961,6 @@
 	return 0;
 }
 
-/*-------------------------------------------------------------------------*/
 #define OK(x)			len = (x); break
 
 #define CLR_RH_PORTSTAT(x) \
@@ -1800,10 +1974,7 @@
 	outw(status, io_addr + USBPORTSC1 + 2 * (wIndex-1))
 
 
-/*-------------------------------------------------------------------------*/
-/*************************
- ** Root Hub Control Pipe
- *************************/
+/* Root Hub Control Pipe */
 
 static int rh_submit_urb(struct urb *urb)
 {
@@ -1814,7 +1985,7 @@
 	int leni = urb->transfer_buffer_length;
 	int len = 0;
 	int status = 0;
-	int stat = USB_ST_NOERROR;
+	int stat = 0;
 	int i;
 	unsigned int io_addr = uhci->io_addr;
 	__u16 cstatus;
@@ -1829,7 +2000,7 @@
 		uhci->rh.interval = urb->interval;
 		rh_init_int_timer(urb);
 
-		return USB_ST_NOERROR;
+		return -EINPROGRESS;
 	}
 
 	bmRType_bReq = cmd->requesttype | cmd->request << 8;
@@ -1937,7 +2108,6 @@
 		}
 		break;
 	case RH_SET_ADDRESS:
-		uhci->rh.devnum = wValue;
 		OK(0);
 	case RH_GET_DESCRIPTOR:
 		switch ((wValue & 0xff00) >> 8) {
@@ -1947,14 +2117,14 @@
 			OK(len);
 		case 0x02:	/* configuration descriptor */
 			len = min(leni, min(sizeof(root_hub_config_des), wLength));
-			memcpy (data, root_hub_config_des, len);
+			memcpy(data, root_hub_config_des, len);
 			OK(len);
 		case 0x03:	/* string descriptors */
-			len = usb_root_hub_string (wValue & 0xff,
+			len = usb_root_hub_string(wValue & 0xff,
 				uhci->io_addr, "UHCI-alt",
 				data, wLength);
 			if (len > 0) {
-				OK (min (leni, len));
+				OK(min (leni, len));
 			} else 
 				stat = -EPIPE;
 		}
@@ -1979,33 +2149,29 @@
 	}
 
 	urb->actual_length = len;
-	urb->status = stat;
-	if (urb->complete)
-		urb->complete(urb);
 
-	return USB_ST_NOERROR;
+	return stat;
 }
-/*-------------------------------------------------------------------------*/
 
 static int rh_unlink_urb(struct urb *urb)
 {
 	struct uhci *uhci = (struct uhci *)urb->dev->bus->hcpriv;
 
 	if (uhci->rh.urb == urb) {
+		urb->status = -ENOENT;
 		uhci->rh.send = 0;
+		uhci->rh.urb = NULL;
 		del_timer(&uhci->rh.rh_int_timer);
 	}
 	return 0;
 }
-/*-------------------------------------------------------------------*/
 
-void uhci_free_pending_qhs(struct uhci *uhci)
+static void uhci_free_pending_qhs(struct uhci *uhci)
 {
 	struct list_head *tmp, *head;
 	unsigned long flags;
 
-	/* Free any pending QH's */
-	spin_lock_irqsave(&uhci->qh_remove_lock, flags);
+	spin_lock_irqsave(&uhci->qh_remove_list_lock, flags);
 	head = &uhci->qh_remove_list;
 	tmp = head->next;
 	while (tmp != head) {
@@ -2014,10 +2180,147 @@
 		tmp = tmp->next;
 
 		list_del(&qh->remove_list);
+		INIT_LIST_HEAD(&qh->remove_list);
+
+		uhci_free_qh(uhci, qh);
+	}
+	spin_unlock_irqrestore(&uhci->qh_remove_list_lock, flags);
+}
+
+static void uhci_call_completion(struct urb *urb)
+{
+	struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
+	struct usb_device *dev = urb->dev;
+	int is_ring = 0, killed, resubmit_interrupt, status;
+	struct urb *nurb;
+
+	killed = (urb->status == -ENOENT || urb->status == -ECONNABORTED ||
+			urb->status == -ECONNRESET);
+	resubmit_interrupt = (usb_pipetype(urb->pipe) == PIPE_INTERRUPT &&
+			urb->interval && !killed);
+
+	nurb = urb->next;
+	if (nurb && !killed) {
+		/* First loop to check for any other URB's that are killed */
+		int count = 0;
+
+		while (nurb && nurb != urb && count < MAX_URB_LOOP) {
+			if (nurb->status == -ENOENT ||
+			    nurb->status == -ECONNABORTED ||
+			    nurb->status == -ECONNRESET) {
+				killed = 1;
+				break;
+			}
+
+			nurb = nurb->next;
+			count++;
+		}
+
+		if (count == MAX_URB_LOOP)
+			err("uhci_call_completion: too many linked URB's, loop? (first loop)");
+
+		/* Check to see if chain is a ring */
+		is_ring = (nurb == urb);
+	}
+
+	if (usb_pipein(urb->pipe) && urb->transfer_buffer_length)
+		memcpy(urb->transfer_buffer, urbp->transfer_buffer,
+			urb->transfer_buffer_length);
+
+	status = urbp->status;
+	if (!resubmit_interrupt)
+		/* We don't need urb_priv anymore */
+		uhci_destroy_urb_priv(urb);
+
+#if 0
+	nurb = urb->next;
+	if (nurb && !killed) {
+		/* Second loop to submit any other URB's */
+		int count = 0;
+
+		while (nurb && nurb != urb && count < MAX_URB_LOOP) {
+			if (nurb->status != -EINPROGRESS) {
+				/* usb_submit_urb since there's no reason */
+				/*  that this URB doesn't belong to another */
+				/*  HCD (ohci, ehci, etc) */
+				if (usb_submit_urb(nurb))
+					break;
+			}
+
+			nurb = nurb->next;
+			count++;
+		}
+
+		if (count == MAX_URB_LOOP)
+			err("uhci_call_completion: too many linked URB's, loop? (second loop)");
+	}
+#endif
+
+	if (!killed)
+		urb->status = status;
+
+	urb->dev = NULL;
+	if (urb->complete)
+		urb->complete(urb);
+
+	if (resubmit_interrupt) {
+		urb->dev = dev;
+		uhci_reset_interrupt(urb);
+	} else {
+		if (is_ring && !killed) {
+			urb->dev = dev;
+			uhci_submit_urb(urb);
+		} else {
+			/* We decrement the usage count after we're done */
+			/*  with everything */
+			usb_dec_dev_use(dev);
+		}
+	}
+}
+
+static void uhci_finish_completion(struct uhci *uhci)
+{
+	struct list_head *tmp, *head;
+	unsigned long flags;
+
+	spin_lock_irqsave(&uhci->complete_list_lock, flags);
+	head = &uhci->complete_list;
+	tmp = head->next;
+	while (tmp != head) {
+		struct urb_priv *urbp = list_entry(tmp, struct urb_priv, complete_list);
+		struct urb *urb = urbp->urb;
+
+		tmp = tmp->next;
+
+		list_del(&urbp->complete_list);
+		INIT_LIST_HEAD(&urbp->complete_list);
+
+		uhci_call_completion(urb);
+	}
+	spin_unlock_irqrestore(&uhci->complete_list_lock, flags);
+}
+
+static void uhci_remove_pending_qhs(struct uhci *uhci)
+{
+	struct list_head *tmp, *head;
+	unsigned long flags;
+
+	spin_lock_irqsave(&uhci->urb_remove_list_lock, flags);
+	head = &uhci->urb_remove_list;
+	tmp = head->next;
+	while (tmp != head) {
+		struct urb *urb = list_entry(tmp, struct urb, urb_list);
+		struct urb_priv *urbp = (struct urb_priv *)urb->hcpriv;
 
-		uhci_free_qh(qh);
+		tmp = tmp->next;
+
+		list_del(&urb->urb_list);
+		INIT_LIST_HEAD(&urb->urb_list);
+
+		urbp->status = urb->status = -ECONNRESET;
+		uhci_call_completion(urb);
 	}
-	spin_unlock_irqrestore(&uhci->qh_remove_lock, flags);
+	spin_unlock_irqrestore(&uhci->urb_remove_list_lock, flags);
 }
 
 static void uhci_interrupt(int irq, void *__uhci, struct pt_regs *regs)
@@ -2025,7 +2328,6 @@
 	struct uhci *uhci = __uhci;
 	unsigned int io_addr = uhci->io_addr;
 	unsigned short status;
-	unsigned long flags;
 	struct list_head *tmp, *head;
 
 	/*
@@ -2035,7 +2337,7 @@
 	status = inw(io_addr + USBSTS);
 	if (!status)	/* shared interrupt, not mine */
 		return;
-	outw(status, io_addr + USBSTS);
+	outw(status, io_addr + USBSTS);		/* Clear it */
 
 	if (status & ~(USBSTS_USBINT | USBSTS_ERROR)) {
 		if (status & USBSTS_RD)
@@ -2052,25 +2354,12 @@
 
 	uhci_free_pending_qhs(uhci);
 
-	spin_lock(&uhci->urb_remove_lock);
-	head = &uhci->urb_remove_list;
-	tmp = head->next;
-	while (tmp != head) {
-		struct urb *urb = list_entry(tmp, struct urb, urb_list);
-
-		tmp = tmp->next;
-
-		list_del(&urb->urb_list);
-
-		if (urb->complete)
-			urb->complete(urb);
-	}
-	spin_unlock(&uhci->urb_remove_lock);
+	uhci_remove_pending_qhs(uhci);
 
 	uhci_clear_next_interrupt(uhci);
 
-	/* Walk the list of pending TD's to see which ones completed */
-	nested_lock(&uhci->urblist_lock, flags);
+	/* Walk the list of pending URB's to see which ones completed */
+	spin_lock(&uhci->urb_list_lock);
 	head = &uhci->urb_list;
 	tmp = head->next;
 	while (tmp != head) {
@@ -2079,12 +2368,14 @@
 		tmp = tmp->next;
 
 		/* Checks the status and does all of the magic necessary */
-		uhci_transfer_result(urb);
+		uhci_transfer_result(uhci, urb);
 	}
-	nested_unlock(&uhci->urblist_lock, flags);
+	spin_unlock(&uhci->urb_list_lock);
+
+	uhci_finish_completion(uhci);
 }
 
-static void reset_hc(struct uhci *uhci)
+static void uhci_reset(struct uhci *uhci)
 {
 	unsigned int io_addr = uhci->io_addr;
 
@@ -2095,7 +2386,7 @@
 	wait_ms(10);
 }
 
-static void start_hc(struct uhci *uhci)
+static void uhci_start(struct uhci *uhci)
 {
 	unsigned int io_addr = uhci->io_addr;
 	int timeout = 1000;
@@ -2120,12 +2411,43 @@
 
 	/* Start at frame 0 */
 	outw(0, io_addr + USBFRNUM);
-	outl(virt_to_bus(uhci->fl), io_addr + USBFLBASEADD);
+	outl(uhci->fl->dma_handle, io_addr + USBFLBASEADD);
 
 	/* Run and mark it configured with a 64-byte max packet */
 	outw(USBCMD_RS | USBCMD_CF | USBCMD_MAXP, io_addr + USBCMD);
 }
 
+static int uhci_alloc_root_hub(struct uhci *uhci)
+{
+	struct usb_device *dev;
+
+	dev = usb_alloc_dev(NULL, uhci->bus);
+	if (!dev)
+		return -1;
+
+	uhci->bus->root_hub = dev;
+	uhci->rh.dev = dev;
+
+	return 0;
+}
+
+static int uhci_start_root_hub(struct uhci *uhci)
+{
+	usb_connect(uhci->rh.dev);
+
+	if (usb_new_device(uhci->rh.dev) != 0) {
+		usb_free_dev(uhci->rh.dev);
+
+		return -1;
+	}
+
+	return 0;
+}
+
+#ifdef CONFIG_PROC_FS
+static int uhci_num = 0;
+#endif
+
 /*
  * Allocate a frame list, and then setup the skeleton
  *
@@ -2140,8 +2462,9 @@
  *  - The second queue is the "control queue", split into low and high speed
  *  - The third queue is "bulk data".
  */
-static struct uhci *alloc_uhci(unsigned int io_addr, unsigned int io_size)
+static struct uhci *uhci_alloc(struct pci_dev *dev, unsigned int io_addr, unsigned int io_size)
 {
+	dma_addr_t dma_handle;
 	int i, port;
 	struct uhci *uhci;
 	struct usb_bus *bus;
@@ -2152,36 +2475,44 @@
 
 	memset(uhci, 0, sizeof(*uhci));
 
+	uhci->dev = dev;
 	uhci->irq = -1;
 	uhci->io_addr = io_addr;
 	uhci->io_size = io_size;
 
-	spin_lock_init(&uhci->qh_remove_lock);
+	/* Initialize some lists/spinlocks */
+	spin_lock_init(&uhci->qh_remove_list_lock);
 	INIT_LIST_HEAD(&uhci->qh_remove_list);
 
-	spin_lock_init(&uhci->urb_remove_lock);
+	spin_lock_init(&uhci->urb_remove_list_lock);
 	INIT_LIST_HEAD(&uhci->urb_remove_list);
 
-	nested_init(&uhci->urblist_lock);
+	spin_lock_init(&uhci->urb_list_lock);
 	INIT_LIST_HEAD(&uhci->urb_list);
 
-	spin_lock_init(&uhci->framelist_lock);
+	spin_lock_init(&uhci->complete_list_lock);
+	INIT_LIST_HEAD(&uhci->complete_list);
+
+	spin_lock_init(&uhci->frame_list_lock);
 
 	/* We need exactly one page (per UHCI specs), how convenient */
 	/* We assume that one page is atleast 4k (1024 frames * 4 bytes) */
-	uhci->fl = (void *)__get_free_page(GFP_KERNEL);
+	uhci->fl = pci_alloc_consistent(uhci->dev, sizeof(*uhci->fl), &dma_handle);
 	if (!uhci->fl)
-		goto au_free_uhci;
+		goto free_uhci;
+
+	memset((void *)uhci->fl, 0, sizeof(*uhci->fl));
+
+	uhci->fl->dma_handle = dma_handle;
 
 	bus = usb_alloc_bus(&uhci_device_operations);
 	if (!bus)
-		goto au_free_fl;
+		goto free_fl;
 
 	uhci->bus = bus;
 	bus->hcpriv = uhci;
 
 	/* Initialize the root hub */
-
 	/* UHCI specs says devices must have 2 ports, but goes on to say */
 	/*  they may have more but give no way to determine how many they */
 	/*  have. However, according to the UHCI spec, Bit 7 is always set */
@@ -2205,36 +2536,66 @@
 
 	uhci->rh.numports = port;
 
+	if (uhci_alloc_root_hub(uhci)) {
+		err("unable to allocate root hub");
+		goto free_fl;
+	}
+
+	uhci->skeltd[0] = uhci_alloc_td(uhci, uhci->rh.dev);
+	if (!uhci->skeltd[0]) {
+		err("unable to allocate TD 0");
+		goto free_fl;
+	}
+
 	/*
 	 * 9 Interrupt queues; link int2 to int1, int4 to int2, etc
 	 * then link int1 to control and control to bulk
 	 */
 	for (i = 1; i < 9; i++) {
-		struct uhci_td *td = &uhci->skeltd[i];
+		struct uhci_td *td;
+
+		td = uhci->skeltd[i] = uhci_alloc_td(uhci, uhci->rh.dev);
+		if (!td) {
+			err("unable to allocate TD %d", i);
+			goto free_tds;
+		}
 
 		uhci_fill_td(td, 0, (UHCI_NULL_DATA_SIZE << 21) | (0x7f << 8) | USB_PID_IN, 0);
-		td->link = virt_to_bus(&uhci->skeltd[i - 1]);
+		td->link = uhci->skeltd[i - 1]->dma_handle;
 	}
 
+	uhci->skel_term_td = uhci_alloc_td(uhci, uhci->rh.dev);
+	if (!uhci->skel_term_td) {
+		err("unable to allocate TD 0");
+		goto free_fl;
+	}
 
-	uhci_fill_td(&uhci->skel_int1_td, 0, (UHCI_NULL_DATA_SIZE << 21) | (0x7f << 8) | USB_PID_IN, 0);
-	uhci->skel_int1_td.link = virt_to_bus(&uhci->skel_ls_control_qh) | UHCI_PTR_QH;
+	for (i = 0; i < UHCI_NUM_SKELQH; i++) {
+		uhci->skelqh[i] = uhci_alloc_qh(uhci, uhci->rh.dev);
+		if (!uhci->skelqh[i]) {
+			err("unable to allocate QH %d", i);
+			goto free_qhs;
+		}
+	}
 
-	uhci->skel_ls_control_qh.link = virt_to_bus(&uhci->skel_hs_control_qh) | UHCI_PTR_QH;
-	uhci->skel_ls_control_qh.element = UHCI_PTR_TERM;
+	uhci_fill_td(uhci->skel_int1_td, 0, (UHCI_NULL_DATA_SIZE << 21) | (0x7f << 8) | USB_PID_IN, 0);
+	uhci->skel_int1_td->link = uhci->skel_ls_control_qh->dma_handle | UHCI_PTR_QH;
 
-	uhci->skel_hs_control_qh.link = virt_to_bus(&uhci->skel_bulk_qh) | UHCI_PTR_QH;
-	uhci->skel_hs_control_qh.element = UHCI_PTR_TERM;
+	uhci->skel_ls_control_qh->link = uhci->skel_hs_control_qh->dma_handle | UHCI_PTR_QH;
+	uhci->skel_ls_control_qh->element = UHCI_PTR_TERM;
 
-	uhci->skel_bulk_qh.link = virt_to_bus(&uhci->skel_term_qh) | UHCI_PTR_QH;
-	uhci->skel_bulk_qh.element = UHCI_PTR_TERM;
+	uhci->skel_hs_control_qh->link = uhci->skel_bulk_qh->dma_handle | UHCI_PTR_QH;
+	uhci->skel_hs_control_qh->element = UHCI_PTR_TERM;
+
+	uhci->skel_bulk_qh->link = uhci->skel_term_qh->dma_handle | UHCI_PTR_QH;
+	uhci->skel_bulk_qh->element = UHCI_PTR_TERM;
 
 	/* This dummy TD is to work around a bug in Intel PIIX controllers */
-	uhci_fill_td(&uhci->skel_term_td, 0, (UHCI_NULL_DATA_SIZE << 21) | (0x7f << 8) | USB_PID_IN, 0);
-	uhci->skel_term_td.link = UHCI_PTR_TERM;
+	uhci_fill_td(uhci->skel_term_td, 0, (UHCI_NULL_DATA_SIZE << 21) | (0x7f << 8) | USB_PID_IN, 0);
+	uhci->skel_term_td->link = UHCI_PTR_TERM;
 
-	uhci->skel_term_qh.link = UHCI_PTR_TERM;
-	uhci->skel_term_qh.element = virt_to_bus(&uhci->skel_term_td);
+	uhci->skel_term_qh->link = UHCI_PTR_TERM;
+	uhci->skel_term_qh->element = uhci->skel_term_td->dma_handle;
 
 	/*
 	 * Fill the frame list: make all entries point to
@@ -2244,8 +2605,8 @@
 	 * scatter the interrupt queues in a way that gives
 	 * us a reasonable dynamic range for irq latencies.
 	 */
-	for (i = 0; i < 1024; i++) {
-		struct uhci_td *irq = &uhci->skel_int1_td;
+	for (i = 0; i < UHCI_NUMFRAMES; i++) {
+		int irq = 0;
 
 		if (i & 1) {
 			irq++;
@@ -2269,7 +2630,7 @@
 		}
 
 		/* Only place we don't use the frame list routines */
-		uhci->fl->frame[i] =  virt_to_bus(irq);
+		uhci->fl->frame[i] =  uhci->skeltd[irq]->dma_handle;
 	}
 
 	return uhci;
@@ -2277,9 +2638,23 @@
 /*
  * error exits:
  */
-au_free_fl:
-	free_page((unsigned long)uhci->fl);
-au_free_uhci:
+free_qhs:
+	for (i = 0; i < UHCI_NUM_SKELQH; i++)
+		if (uhci->skelqh[i]) {
+			uhci_free_qh(uhci, uhci->skelqh[i]);
+			uhci->skelqh[i] = NULL;
+		}
+free_tds:
+	for (i = 0; i < UHCI_NUM_SKELTD; i++)
+		if (uhci->skeltd[i]) {
+			uhci_free_td(uhci, uhci->skeltd[i]);
+			uhci->skeltd[i] = NULL;
+		}
+
+free_fl:
+	pci_free_consistent(uhci->dev, sizeof(*uhci->fl), uhci->fl, uhci->fl->dma_handle);
+
+free_uhci:
 	kfree(uhci);
 
 	return NULL;
@@ -2288,51 +2663,70 @@
 /*
  * De-allocate all resources..
  */
-static void release_uhci(struct uhci *uhci)
+static void uhci_release(struct uhci *uhci)
 {
+	unsigned long flags;
+	int i;
+#ifdef CONFIG_PROC_FS
+	char buf[8];
+#endif
+
+	spin_lock_irqsave(&uhci->frame_list_lock, flags);
+	for (i = 0; i < UHCI_NUMFRAMES; i++) {
+		uhci->fl->frame[i] =  UHCI_PTR_TERM;
+		uhci->fl->frame_cpu[i] = NULL;
+	}
+	spin_unlock_irqrestore(&uhci->frame_list_lock, flags);
+
+	for (i = 0; i < UHCI_NUM_SKELQH; i++)
+		if (uhci->skelqh[i]) {
+			uhci_free_qh(uhci, uhci->skelqh[i]);
+			uhci->skelqh[i] = NULL;
+		}
+
+	for (i = 0; i < UHCI_NUM_SKELTD; i++)
+		if (uhci->skeltd[i]) {
+			uhci_free_td(uhci, uhci->skeltd[i]);
+			uhci->skeltd[i] = NULL;
+		}
+
+	release_region(uhci->io_addr, uhci->io_size);
+
 	if (uhci->irq >= 0) {
 		free_irq(uhci->irq, uhci);
 		uhci->irq = -1;
 	}
 
-	if (uhci->fl) {
-		free_page((unsigned long)uhci->fl);
-		uhci->fl = NULL;
-	}
+#ifdef CONFIG_PROC_FS
+	sprintf(buf, "hc%d", uhci->num);
 
-	usb_free_bus(uhci->bus);
-	kfree(uhci);
+	remove_proc_entry(buf, uhci_proc_root);
+	uhci->proc_entry = NULL;
+#endif
 }
 
-int uhci_start_root_hub(struct uhci *uhci)
+static void uhci_free(struct uhci *uhci)
 {
-	struct usb_device *dev;
-
-	dev = usb_alloc_dev(NULL, uhci->bus);
-	if (!dev)
-		return -1;
-
-	uhci->bus->root_hub = dev;
-	usb_connect(dev);
-
-	if (usb_new_device(dev) != 0) {
-		usb_free_dev(dev);
-
-		return -1;
+	if (uhci->fl) {
+		pci_free_consistent(uhci->dev, sizeof(*uhci->fl), uhci->fl, uhci->fl->dma_handle);
+		uhci->fl = NULL;
 	}
 
-	return 0;
+	usb_free_bus(uhci->bus);
+	kfree(uhci);
 }
 
 /*
- * If we've successfully found a UHCI, now is the time to increment the
- * module usage count, and return success..
+ * If we've successfully found a UHCI, now is the time to return success..
  */
-static int setup_uhci(struct pci_dev *dev, int irq, unsigned int io_addr, unsigned int io_size)
+static int uhci_found(struct pci_dev *dev, int irq, unsigned int io_addr, unsigned int io_size)
 {
 	int retval;
 	struct uhci *uhci;
 	char buf[8], *bufp = buf;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *ent;
+#endif
 
 #ifndef __sparc__
 	sprintf(buf, "%d", irq);
@@ -2342,17 +2736,34 @@
 	printk(KERN_INFO __FILE__ ": USB UHCI at I/O 0x%x, IRQ %s\n",
 		io_addr, bufp);
 
-	uhci = alloc_uhci(io_addr, io_size);
+	uhci = uhci_alloc(dev, io_addr, io_size);
 	if (!uhci)
 		return -ENOMEM;
+
 	dev->driver_data = uhci;
 
+#ifdef CONFIG_PROC_FS
+	uhci->num = uhci_num++;
+
+	sprintf(buf, "hc%d", uhci->num);
+
+	ent = create_proc_entry(buf, S_IFREG|S_IRUGO|S_IWUSR, uhci_proc_root);
+	if (!ent)
+		return -ENOMEM;
+
+	ent->data = uhci;
+	ent->proc_fops = &uhci_proc_operations;
+	ent->size = 0;
+	uhci->proc_entry = ent;
+#endif
+
 	request_region(uhci->io_addr, io_size, "usb-uhci");
 
-	reset_hc(uhci);
+	uhci_reset(uhci);
 
 	usb_register_bus(uhci->bus);
-	start_hc(uhci);
+
+	uhci_start(uhci);
 
 	retval = -EBUSY;
 	if (request_irq(irq, uhci_interrupt, SA_SHIRQ, "usb-uhci", uhci) == 0) {
@@ -2365,10 +2776,12 @@
 	}
 
 	/* Couldn't allocate IRQ if we got here */
+	uhci_reset(uhci);
+	uhci_release(uhci);
 
-	reset_hc(uhci);
-	release_region(uhci->io_addr, uhci->io_size);
-	release_uhci(uhci);
+	usb_deregister_bus(uhci->bus);
+
+	uhci_free(uhci);
 
 	return retval;
 }
@@ -2377,6 +2790,12 @@
 {
 	int i;
 
+	if (!pci_dma_supported(dev, 0xffffffffUL)) {
+		err("PCI subsystem doesn't support 32 bit DMA?");
+		return -ENODEV;
+	}
+	dev->dma_mask = 0xffffffffUL;
+
 	/* disable legacy emulation */
 	pci_write_config_word(dev, USBLEGSUP, 0);
 
@@ -2402,7 +2821,8 @@
 			break;
 
 		pci_set_master(dev);
-		return setup_uhci(dev, dev->irq, io_addr, io_size);
+
+		return uhci_found(dev, dev->irq, io_addr, io_size);
 	}
 
 	return -ENODEV;
@@ -2415,31 +2835,33 @@
 	if (uhci->bus->root_hub)
 		usb_disconnect(&uhci->bus->root_hub);
 
-	usb_deregister_bus(uhci->bus);
+	/* At this point, we're pretty much guaranteed that no new */
+	/*  connects can be made to this bus since there are no more */
+	/*  parents */
+	uhci_free_pending_qhs(uhci);
+	uhci_remove_pending_qhs(uhci);
+	uhci_finish_completion(uhci);
 
-	reset_hc(uhci);
-	release_region(uhci->io_addr, uhci->io_size);
+	uhci_reset(uhci);
+	uhci_release(uhci);
 
-	uhci_free_pending_qhs(uhci);
+	usb_deregister_bus(uhci->bus);
 
-	release_uhci(uhci);
+	uhci_free(uhci);
 }
 
 static void uhci_pci_suspend(struct pci_dev *dev)
 {
-	reset_hc((struct uhci *) dev->driver_data);
+	uhci_reset((struct uhci *)dev->driver_data);
 }
 
 static void uhci_pci_resume(struct pci_dev *dev)
 {
-	reset_hc((struct uhci *) dev->driver_data);
-	start_hc((struct uhci *) dev->driver_data);
+	uhci_reset((struct uhci *)dev->driver_data);
+	uhci_start((struct uhci *)dev->driver_data);
 }
 
-/*-------------------------------------------------------------------------*/
-
-static const struct pci_device_id __devinitdata uhci_pci_ids [] = { {
-
+static const struct pci_device_id __devinitdata uhci_pci_ids[] = { {
 	/* handle any USB UHCI controller */
 	class: 		((PCI_CLASS_SERIAL_USB << 8) | 0x00),
 	class_mask: 	~0,
@@ -2467,38 +2889,23 @@
 	resume:		uhci_pci_resume,
 #endif	/* PM */
 };
-
  
 static int __init uhci_hcd_init(void)
 {
-	int retval;
-
-	retval = -ENOMEM;
+	int retval = -ENOMEM;
 
-	/* We throw all of the TD's and QH's into a kmem cache */
-	/* TD's and QH's need to be 16 byte aligned and SLAB_HWCACHE_ALIGN */
-	/*  does this for us */
-	uhci_td_cachep = kmem_cache_create("uhci_td",
-		sizeof(struct uhci_td), 0,
-		SLAB_HWCACHE_ALIGN, NULL, NULL);
-
-	if (!uhci_td_cachep)
-		goto td_failed;
-
-	uhci_qh_cachep = kmem_cache_create("uhci_qh",
-		sizeof(struct uhci_qh), 0,
-		SLAB_HWCACHE_ALIGN, NULL, NULL);
-
-	if (!uhci_qh_cachep)
-		goto qh_failed;
+#ifdef CONFIG_PROC_FS
+	uhci_proc_root = create_proc_entry("uhci", S_IFDIR, 0);
+	if (!uhci_proc_root)
+		goto proc_failed;
+#endif
 
 	uhci_up_cachep = kmem_cache_create("uhci_urb_priv",
 		sizeof(struct urb_priv), 0, 0, NULL, NULL);
-
 	if (!uhci_up_cachep)
 		goto up_failed;
 
-	retval = pci_module_init (&uhci_pci_driver);
+	retval = pci_module_init(&uhci_pci_driver);
 	if (retval)
 		goto init_failed;
 
@@ -2509,29 +2916,24 @@
 		printk(KERN_INFO "uhci: not all urb_priv's were freed\n");
 
 up_failed:
-	if (kmem_cache_destroy(uhci_qh_cachep))
-		printk(KERN_INFO "uhci: not all QH's were freed\n");
-
-qh_failed:
-	if (kmem_cache_destroy(uhci_td_cachep))
-		printk(KERN_INFO "uhci: not all TD's were freed\n");
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry("uhci", 0);
 
-td_failed:
+proc_failed:
+#endif
 	return retval;
 }
 
 static void __exit uhci_hcd_cleanup (void) 
 {
-	pci_unregister_driver (&uhci_pci_driver);
+	pci_unregister_driver(&uhci_pci_driver);
 	
 	if (kmem_cache_destroy(uhci_up_cachep))
 		printk(KERN_INFO "uhci: not all urb_priv's were freed\n");
 
-	if (kmem_cache_destroy(uhci_qh_cachep))
-		printk(KERN_INFO "uhci: not all QH's were freed\n");
-
-	if (kmem_cache_destroy(uhci_td_cachep))
-		printk(KERN_INFO "uhci: not all TD's were freed\n");
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry("uhci", 0);
+#endif
 }
 
 module_init(uhci_hcd_init);
diff -urN -X dontdiff linux-2.4.1-pre8.orig/drivers/usb/uhci.h linux-2.4.1-pre8/drivers/usb/uhci.h
--- linux-2.4.1-pre8.orig/drivers/usb/uhci.h	Thu Jan  4 14:52:32 2001
+++ linux-2.4.1-pre8/drivers/usb/uhci.h	Mon Jan 22 17:04:59 2001
@@ -5,36 +5,6 @@
 #include <linux/usb.h>
 
 /*
- * This nested spinlock code is courtesy of Davide Libenzi <dlibenzi@maticad.it>
- */
-struct s_nested_lock {
-	spinlock_t lock;
-	void *uniq;
-	short int count;
-};
-
-#define nested_init(snl) \
-	spin_lock_init(&(snl)->lock); \
-	(snl)->uniq = NULL; \
-	(snl)->count = 0;
-
-#define nested_lock(snl, flags) \
-	if ((snl)->uniq == current) { \
-		(snl)->count++; \
-		flags = 0; /* No warnings */ \
-	} else { \
-		spin_lock_irqsave(&(snl)->lock, flags); \
-		(snl)->count++; \
-		(snl)->uniq = current; \
-	}
-
-#define nested_unlock(snl, flags) \
-	if (!--(snl)->count) { \
-		(snl)->uniq = NULL; \
-		spin_unlock_irqrestore(&(snl)->lock, flags); \
-	}
-
-/*
  * Universal Host Controller Interface data structures and defines
  */
 
@@ -97,11 +67,15 @@
 #define UHCI_MAX_SOF_NUMBER	2047	/* in an SOF packet */
 #define CAN_SCHEDULE_FRAMES	1000	/* how far future frames can be scheduled */
 
-struct uhci_framelist {
+struct uhci_frame_list {
 	__u32 frame[UHCI_NUMFRAMES];
-} __attribute__((aligned(4096)));
 
-struct uhci_td;
+	dma_addr_t dma_handle;
+
+	void *frame_cpu[UHCI_NUMFRAMES];
+};
+
+struct urb_priv;
 
 struct uhci_qh {
 	/* Hardware fields */
@@ -109,12 +83,13 @@
 	__u32 element;				/* Queue element pointer */
 
 	/* Software fields */
-	/* Can't use list_head since we want a specific order */
+	dma_addr_t dma_handle;
 	struct usb_device *dev;			/* The owning device */
 
-	struct uhci_qh *prevqh, *nextqh;
+	struct urb_priv *urbp;
 
-	struct list_head remove_list;
+	struct list_head list;			/* P: uhci->frame_list_lock */
+	struct list_head remove_list;		/* P: uhci->remove_list_lock */
 } __attribute__((aligned(16)));
 
 /*
@@ -141,8 +116,6 @@
 #define uhci_status_bits(ctrl_sts)	(ctrl_sts & 0xFE0000)
 #define uhci_actual_length(ctrl_sts)	((ctrl_sts + 1) & TD_CTRL_ACTLEN_MASK) /* 1-based */
 
-#define uhci_ptr_to_virt(x)	bus_to_virt(x & ~UHCI_PTR_BITS)
-
 /*
  * for TD <info>: (a.k.a. Token)
  */
@@ -170,7 +143,8 @@
  * On 64-bit machines we probably want to take advantage of the fact that
  * hw doesn't really care about the size of the sw-only area.
  *
- * Alas, not anymore, we have more than 4 words for software, woops
+ * Alas, not anymore, we have more than 4 words for software, woops.
+ * Everything still works tho, surprise! -jerdfelt
  */
 struct uhci_td {
 	/* Hardware fields */
@@ -180,13 +154,14 @@
 	__u32 buffer;
 
 	/* Software fields */
-	unsigned int *frameptr;		/* Frame list pointer */
-	struct uhci_td *prevtd, *nexttd; /* Previous and next TD in queue */
+	dma_addr_t dma_handle;
+	int frame;
 
 	struct usb_device *dev;
 	struct urb *urb;		/* URB this TD belongs to */
 
-	struct list_head list;
+	struct list_head list;		/* P: urb->lock */
+	struct list_head fl_list;	/* P: frame_list_lock */
 } __attribute__((aligned(16)));
 
 /*
@@ -289,8 +264,8 @@
 }
 
 struct virt_root_hub {
-	int devnum;		/* Address of Root Hub endpoint */
-	void *urb;
+	struct usb_device *dev;
+	struct urb *urb;
 	void *int_addr;
 	int send;
 	int interval;
@@ -306,6 +281,12 @@
  * a subset of what the full implementation needs.
  */
 struct uhci {
+	struct pci_dev *dev;
+
+	/* procfs */
+	int num;
+	struct proc_dir_entry *proc_entry;
+
 	/* Grabbed from PCI */
 	int irq;
 	unsigned int io_addr;
@@ -315,29 +296,40 @@
 
 	struct usb_bus *bus;
 
-	struct uhci_td skeltd[UHCI_NUM_SKELTD];	/* Skeleton TD's */
-	struct uhci_qh skelqh[UHCI_NUM_SKELQH];	/* Skeleton QH's */
+	struct uhci_td *skeltd[UHCI_NUM_SKELTD];	/* Skeleton TD's */
+	struct uhci_qh *skelqh[UHCI_NUM_SKELQH];	/* Skeleton QH's */
 
-	spinlock_t framelist_lock;
-	struct uhci_framelist *fl;		/* Frame list */
-	int fsbr;				/* Full speed bandwidth reclamation */
+	spinlock_t frame_list_lock;
+	struct uhci_frame_list *fl;		/* Frame list */
+	int fsbr;			/* Full speed bandwidth reclamation */
 
-	spinlock_t qh_remove_lock;
+	spinlock_t qh_remove_list_lock;
 	struct list_head qh_remove_list;
 
-	spinlock_t urb_remove_lock;
+	spinlock_t urb_remove_list_lock;
 	struct list_head urb_remove_list;
 
-	struct s_nested_lock urblist_lock;
+	spinlock_t urb_list_lock;
 	struct list_head urb_list;
 
+	spinlock_t complete_list_lock;
+	struct list_head complete_list;
+
 	struct virt_root_hub rh;	/* private data of the virtual root hub */
 };
 
 struct urb_priv {
 	struct urb *urb;
+	struct usb_device *dev;
+
+	void *setup_buffer;			/* CPU handle */
+	dma_addr_t setup_buffer_dma_handle;	/* DMA address */
+
+	void *transfer_buffer;			/* CPU handle */
+	dma_addr_t transfer_buffer_dma_handle;	/* DMA address */
 
 	struct uhci_qh *qh;		/* QH for this URB */
+	struct list_head td_list;	/* List of TD's (if !qh) */
 
 	int fsbr : 1;			/* URB turned on FSBR */
 	int fsbr_timeout : 1;		/* URB timed out on FSBR */
@@ -346,11 +338,13 @@
 					/*  a control transfer, retrigger */
 					/*  the status phase */
 
-	unsigned long inserttime;	/* In jiffies */
+	int status;			/* Final status */
 
-	struct list_head list;
+	unsigned long inserttime;	/* In jiffies */
 
-	struct list_head urb_queue_list;	/* URB's linked together */
+	/* P: urb->lock */
+	struct list_head queue_list;		/* URB's linked together */
+	struct list_head complete_list;		/* URB's to be completed */
 };
 
 /* -------------------------------------------------------------------------
@@ -408,6 +402,7 @@
 #define RH_REQ_ERR		-1
 #define RH_NACK			0x00
 
+#if 0
 /* needed for the debugging code */
 struct uhci_td *uhci_link_to_td(unsigned int element);
 
@@ -417,6 +412,7 @@
 void uhci_show_urb_queue(struct urb *urb);
 void uhci_show_queue(struct uhci_qh *qh);
 void uhci_show_queues(struct uhci *uhci);
+#endif
 
 #endif
 

--M9NhX3UHpAaciwkO--

