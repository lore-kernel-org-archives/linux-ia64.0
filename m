From: Alex Williamson <alex_williamson@hp.com>
Date: Thu, 14 Feb 2002 17:11:19 +0000
Subject: [Linux-ia64] [PATCH] linux/fs/partitions/efi.c error handling
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------ED50CD7C3154735BA5B81ACD"
Message-Id: <marc-linux-ia64-105590701905131@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806044@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806044@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------ED50CD7C3154735BA5B81ACD
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   I was testing w/ some disks that appear to have bad partition
tables and was getting the following error messages:

SCSI device sdt: 35566480 512-byte hdwr sectors (18210 MB)
 sdt:<4>  Warning: Disk has a valid GPT signature but invalid PMBR.
  Use GNU Parted to correct disk.

Unfortunately, that's not where the problem stopped.  I got
random pointer dereference problems, and was apparently having
data structures freed out from under them.  Turns out the
find_valid_gpt() was freeing data structures more than once and
passing back pointers to freed structures.  Patch below.

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------ED50CD7C3154735BA5B81ACD
Content-Type: text/plain; charset=us-ascii;
 name="efi.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="efi.diff"

--- linux/fs/partitions/efi.c~	25 Jan 2002 20:15:06 -0000	1.2
+++ linux/fs/partitions/efi.c	14 Feb 2002 16:50:07 -0000
@@ -549,10 +549,14 @@ find_valid_gpt(struct gendisk *hd, struc
 
 		*gpt = pgpt;
 		*ptes = pptes;
-		if (agpt)
+		if (agpt) {
 			kfree(agpt);
-		if (aptes)
+			agpt = NULL;
+		}
+		if (aptes) {
 			kfree(aptes);
+			aptes = NULL;
+		}
 	} /* if primary is valid */
 	else {
 		/* Primary GPT is bad, check the Alternate GPT */
@@ -602,6 +606,8 @@ find_valid_gpt(struct gendisk *hd, struc
 	/* Both primary and alternate GPTs are bad, and/or PMBR is invalid.
 	 * This isn't our disk, return 0.
 	 */
+	*gpt = *ptes = NULL;
+
 	if (pgpt) {
 		kfree(pgpt);
 		pgpt = NULL;

--------------ED50CD7C3154735BA5B81ACD--


