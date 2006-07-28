From: Greg Edwards <edwardsg@sgi.com>
Date: Fri, 28 Jul 2006 15:03:55 +0000
Subject: Re: [PATCH] add platform check to a couple sn2-only drivers
Message-Id: <20060728150355.GE27686@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060728143626.GD27686@sgi.com>
In-Reply-To: <20060728143626.GD27686@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 28, 2006 at 03:50:22PM +0100, Christoph Hellwig wrote:
| On Fri, Jul 28, 2006 at 09:36:26AM -0500, Greg Edwards wrote:
| > -	nasid_t event_nasid = ia64_sn_get_console_nasid();
| > +	nasid_t event_nasid;
| > +
| > +	if (!ia64_platform_is("sn2"))
| > +		return -ENODEV;
| > +
| > +	event_nasid = ia64_sn_get_console_nasid();
| 
| this one is okay and required.
| 
| >  static int __devinit
| >  ioc4_init(void)
| >  {
| > +	if (!ia64_platform_is("sn2"))
| > +		return -ENODEV;
| > +
| 
| this one not.  The pci id matching will take care of things. 

Ok, thanks Christoph.  Brent brought that up, too, but we had been
burned by thinking we had it covered before on other drivers.
Tony, revised patch below.

Add a platform check to the snsc driver init function, to prevent
loading on non-sn2 systems.

Signed-off-by: Greg Edwards <edwardsg@sgi.com>

---
 drivers/char/snsc.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: git-linus/drivers/char/snsc.c
=================================--- git-linus.orig/drivers/char/snsc.c	2006-07-28 09:58:08.167283230 -0500
+++ git-linus/drivers/char/snsc.c	2006-07-28 09:58:45.095703646 -0500
@@ -374,7 +374,12 @@ scdrv_init(void)
 	struct sysctl_data_s *scd;
 	void *salbuf;
 	dev_t first_dev, dev;
-	nasid_t event_nasid = ia64_sn_get_console_nasid();
+	nasid_t event_nasid;
+
+	if (!ia64_platform_is("sn2"))
+		return -ENODEV;
+
+	event_nasid = ia64_sn_get_console_nasid();
 
 	if (alloc_chrdev_region(&first_dev, 0, num_cnodes,
 				SYSCTL_BASENAME) < 0) {
