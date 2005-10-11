From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Oct 2005 22:11:11 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200510112211.j9BMBBnG018025@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 drivers/char/mbcs.c |    3 +++
 1 files changed, 3 insertions(+)

diff-tree 96f339c6b95344942fe5fce012ff4f2a3b2cb80d (from ed39f731ab2e77e58122232f6e27333331d7793d)
Author: Greg Edwards <edwardsg@sgi.com>
Date:   Wed Sep 28 17:05:19 2005 -0500

    [IA64] mbcs_init() should give up unless running on sn2
    
    CONFIG_SGI_MBCS is enabled in generic kernels, but the driver may
    oops some other platforms.  Check whether we are running on sn2
    and bail out if we are not before doing anything dangerous.
    
    Acked-by: Bruce Losure <blosure@americas.sgi.com>
    Signed-off-by: Greg Edwards <edwardsg@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/drivers/char/mbcs.c b/drivers/char/mbcs.c
--- a/drivers/char/mbcs.c
+++ b/drivers/char/mbcs.c
@@ -830,6 +830,9 @@ static int __init mbcs_init(void)
 {
 	int rv;
 
+	if (!ia64_platform_is("sn2"))
+		return -ENODEV;
+
 	// Put driver into chrdevs[].  Get major number.
 	rv = register_chrdev(mbcs_major, DEVICE_NAME, &mbcs_ops);
 	if (rv < 0) {
