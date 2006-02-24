From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 24 Feb 2006 19:46:23 +0000
Subject: [PATCH] Fix pcibios_setup
Message-Id: <20060224194623.GS28587@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


pcibios_setup() should return NULL if it handled a parameter.  Since ia64
handles no parameters, it should return the string that was passed in,
not NULL.  This brings ia64 into line with all other architectures that
handle no parameters.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Index: ./arch/ia64/pci/pci.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/pci/pci.c,v
retrieving revision 1.30
diff -u -p -r1.30 pci.c
--- ./arch/ia64/pci/pci.c	4 Feb 2006 04:51:25 -0000	1.30
+++ ./arch/ia64/pci/pci.c	24 Feb 2006 19:40:20 -0000
@@ -579,7 +579,7 @@ pcibios_align_resource (void *data, stru
 char * __init
 pcibios_setup (char *str)
 {
-	return NULL;
+	return str;
 }
 
 int
