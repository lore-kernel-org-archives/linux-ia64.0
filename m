From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 11 Aug 2003 02:10:45 +0000
Subject: Kill warning in drivers/input/misc/uinput.c on IA64 (2.6.0)
Message-Id: <marc-linux-ia64-106056819032612@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Vojtech,
   Attached patch kills a warning when compiling on a 64-bit
architecture (ssize_t is long, not int)

=== drivers/input/misc/uinput.c 1.11 vs edited ==--- 1.11/drivers/input/misc/uinput.c	Sat Jun 21 21:42:40 2003
+++ edited/drivers/input/misc/uinput.c	Thu Aug  7 11:56:12 2003
@@ -226,7 +226,7 @@
 	return retval;
 }
 
-static int uinput_write(struct file *file, const char *buffer, size_t count, loff_t *ppos)
+static ssize_t uinput_write(struct file *file, const char *buffer, size_t count, loff_t *ppos)
 {
 	struct uinput_device	*udev = file->private_data;
 	

--
Dr Peter Chubb     http://www.gelato.unsw.edu.au  peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.

