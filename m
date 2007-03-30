From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 30 Mar 2007 16:39:42 +0000
Subject: [patch 5/5] ia64: update memory attribute aliasing documentation & test cases
Message-Id: <200703301039.42979.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703211622.26630.bjorn.helgaas@hp.com>
In-Reply-To: <200703211622.26630.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Updates documentation and adds some test cases.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm10/Documentation/ia64/aliasing.txt
=================================--- work-mm10.orig/Documentation/ia64/aliasing.txt	2007-03-21 14:13:22.000000000 -0700
+++ work-mm10/Documentation/ia64/aliasing.txt	2007-03-21 14:17:42.000000000 -0700
@@ -112,16 +112,6 @@
 
 	The /dev/mem mmap constraints apply.
 
-	However, since this is for mapping legacy MMIO space, WB access
-	does not make sense.  This matters on machines without legacy
-	VGA support: these machines may have WB memory for the entire
-	first megabyte (or even the entire first granule).
-
-	On these machines, we could mmap legacy_mem as WB, which would
-	be safe in terms of attribute aliasing, but X has no way of
-	knowing that it is accessing regular memory, not a frame buffer,
-	so the kernel should fail the mmap rather than doing it with WB.
-
     read/write of /dev/mem
 
 	This uses copy_from_user(), which implicitly uses a kernel
@@ -138,14 +128,20 @@
 
     ioremap()
 
-	This returns a kernel identity mapping for use inside the
-	kernel.
+	This returns a mapping for use inside the kernel.
 
 	If the region is in kern_memmap, we should use the attribute
-	specified there.  Otherwise, if the EFI memory map reports that
-	the entire granule supports WB, we should use that (granules
-	that are partially reserved or occupied by firmware do not appear
-	in kern_memmap).  Otherwise, we should use a UC mapping.
+	specified there.
+
+	If the EFI memory map reports that the entire granule supports
+	WB, we should use that (granules that are partially reserved
+	or occupied by firmware do not appear in kern_memmap).
+
+	If the granule contains non-WB memory, but we can cover the
+	region safely with kernel page table mappings, we can use
+	ioremap_page_range() as most other architectures do.
+
+	Failing all of the above, we have to fall back to a UC mapping.
 
 PAST PROBLEM CASES
 
@@ -158,7 +154,7 @@
       succeed.  It may create either WB or UC user mappings, depending
       on whether the region is in kern_memmap or the EFI memory map.
 
-    mmap of 0x0-0xA0000 /dev/mem by "hwinfo" on HP sx1000 with VGA enabled
+    mmap of 0x0-0x9FFFF /dev/mem by "hwinfo" on HP sx1000 with VGA enabled
 
       See https://bugzilla.novell.com/show_bug.cgi?id0858.
 
@@ -171,28 +167,25 @@
       so it is safe to use WB mappings.
 
       The kernel VGA driver may ioremap the VGA frame buffer at 0xA0000,
-      which will use a granule-sized UC mapping covering 0-0xFFFFF.  This
-      granule covers some WB-only memory, but since UC is non-speculative,
-      the processor will never generate an uncacheable reference to the
-      WB-only areas unless the driver explicitly touches them.
+      which uses a granule-sized UC mapping.  This granule will cover some
+      WB-only memory, but since UC is non-speculative, the processor will
+      never generate an uncacheable reference to the WB-only areas unless
+      the driver explicitly touches them.
 
     mmap of 0x0-0xFFFFF legacy_mem by "X"
 
-      If the EFI memory map reports this entire range as WB, there
-      is no VGA MMIO hole, and the mmap should fail or be done with
-      a WB mapping.
-
-      There's no easy way for X to determine whether the 0xA0000-0xBFFFF
-      region is a frame buffer or just memory, so I think it's best to
-      just fail this mmap request rather than using a WB mapping.  As
-      far as I know, there's no need to map legacy_mem with WB
-      mappings.
-
-      Otherwise, a UC mapping of the entire region is probably safe.
-      The VGA hole means the region will not be in kern_memmap.  The
-      HP sx1000 chipset doesn't support UC access to the memory surrounding
-      the VGA hole, but X doesn't need that area anyway and should not
-      reference it.
+      If the EFI memory map reports that the entire range supports the
+      same attributes, we can allow the mmap (and we will prefer WB if
+      supported, as is the case with HP sx[12]000 machines with VGA
+      disabled).
+
+      If EFI reports the range as partly WB and partly UC (as on sx[12]000
+      machines with VGA enabled), we must fail the mmap because there's no
+      safe attribute to use.
+
+      If EFI reports some of the range but not all (as on Intel firmware
+      that doesn't report the VGA frame buffer at all), we should fail the
+      mmap and force the user to map just the specific region of interest.
 
     mmap of 0xA0000-0xBFFFF legacy_mem by "X" on HP sx1000 with VGA disabled
 
@@ -202,6 +195,16 @@
       This is a special case of the previous case, and the mmap should
       fail for the same reason as above.
 
+    read of /sys/devices/.../rom
+
+      For VGA devices, this may cause an ioremap() of 0xC0000.  This
+      used to be done with a UC mapping, because the VGA frame buffer
+      at 0xA0000 prevents use of a WB granule.  The UC mapping causes
+      an MCA on HP sx[12]000 chipsets.
+
+      We should use WB page table mappings to avoid covering the VGA
+      frame buffer.
+
 NOTES
 
     [1] SDM rev 2.2, vol 2, sec 4.4.1.
Index: work-mm10/Documentation/ia64/aliasing-test.c
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ work-mm10/Documentation/ia64/aliasing-test.c	2007-03-21 14:42:06.000000000 -0700
@@ -0,0 +1,247 @@
+/*
+ * Exercise /dev/mem mmap cases that have been troublesome in the past
+ *
+ * (c) Copyright 2007 Hewlett-Packard Development Company, L.P.
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <sys/types.h>
+#include <dirent.h>
+#include <fcntl.h>
+#include <fnmatch.h>
+#include <string.h>
+#include <sys/mman.h>
+#include <sys/stat.h>
+#include <unistd.h>
+
+int sum;
+
+int map_mem(char *path, off_t offset, size_t length, int touch)
+{
+	int fd, rc;
+	void *addr;
+	int *c;
+
+	fd = open(path, O_RDWR);
+	if (fd = -1) {
+		perror(path);
+		return -1;
+	}
+
+	addr = mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, offset);
+	if (addr = MAP_FAILED)
+		return 1;
+
+	if (touch) {
+		c = (int *) addr;
+		while (c < (int *) (offset + length))
+			sum += *c++;
+	}
+
+	rc = munmap(addr, length);
+	if (rc = -1) {
+		perror("munmap");
+		return -1;
+	}
+
+	close(fd);
+	return 0;
+}
+
+int scan_sysfs(char *path, char *file, off_t offset, size_t length, int touch)
+{
+	struct dirent **namelist;
+	char *name, *path2;
+	int i, n, r, rc, result = 0;
+	struct stat buf;
+
+	n = scandir(path, &namelist, 0, alphasort);
+	if (n < 0) {
+		perror("scandir");
+		return -1;
+	}
+
+	for (i = 0; i < n; i++) {
+		name = namelist[i]->d_name;
+
+		if (fnmatch(".", name, 0) = 0)
+			goto skip;
+		if (fnmatch("..", name, 0) = 0)
+			goto skip;
+
+		path2 = malloc(strlen(path) + strlen(name) + 3);
+		strcpy(path2, path);
+		strcat(path2, "/");
+		strcat(path2, name);
+
+		if (fnmatch(file, name, 0) = 0) {
+			rc = map_mem(path2, offset, length, touch);
+			if (rc = 0)
+				fprintf(stderr, "PASS: %s 0x%lx-0x%lx is %s\n", path2, offset, offset + length, touch ? "readable" : "mappable");
+			else if (rc > 0)
+				fprintf(stderr, "PASS: %s 0x%lx-0x%lx not mappable\n", path2, offset, offset + length);
+			else {
+				fprintf(stderr, "FAIL: %s 0x%lx-0x%lx not accessible\n", path2, offset, offset + length);
+				return rc;
+			}
+		} else {
+			r = lstat(path2, &buf);
+			if (r = 0 && S_ISDIR(buf.st_mode)) {
+				rc = scan_sysfs(path2, file, offset, length, touch);
+				if (rc < 0)
+					return rc;
+			}
+		}
+
+		result |= rc;
+		free(path2);
+
+skip:
+		free(namelist[i]);
+	}
+	free(namelist);
+	return rc;
+}
+
+char buf[1024];
+
+int read_rom(char *path)
+{
+	int fd, rc;
+	size_t size = 0;
+
+	fd = open(path, O_RDWR);
+	if (fd = -1) {
+		perror(path);
+		return -1;
+	}
+
+	rc = write(fd, "1", 2);
+	if (rc <= 0) {
+		perror("write");
+		return -1;
+	}
+
+	do {
+		rc = read(fd, buf, sizeof(buf));
+		if (rc > 0)
+			size += rc;
+	} while (rc > 0);
+
+	close(fd);
+	return size;
+}
+
+int scan_rom(char *path, char *file)
+{
+	struct dirent **namelist;
+	char *name, *path2;
+	int i, n, r, rc, result = 0;
+	struct stat buf;
+
+	n = scandir(path, &namelist, 0, alphasort);
+	if (n < 0) {
+		perror("scandir");
+		return -1;
+	}
+
+	for (i = 0; i < n; i++) {
+		name = namelist[i]->d_name;
+
+		if (fnmatch(".", name, 0) = 0)
+			goto skip;
+		if (fnmatch("..", name, 0) = 0)
+			goto skip;
+
+		path2 = malloc(strlen(path) + strlen(name) + 3);
+		strcpy(path2, path);
+		strcat(path2, "/");
+		strcat(path2, name);
+
+		if (fnmatch(file, name, 0) = 0) {
+			rc = read_rom(path2);
+
+			/*
+			 * It's OK if the ROM is unreadable.  Maybe there
+			 * is no ROM, or some other error ocurred.  The
+			 * important thing is that no MCA happened.
+			 */
+			if (rc > 0)
+				fprintf(stderr, "PASS: %s read %ld bytes\n", path2, rc);
+			else {
+				fprintf(stderr, "PASS: %s not readable\n", path2);
+				return rc;
+			}
+		} else {
+			r = lstat(path2, &buf);
+			if (r = 0 && S_ISDIR(buf.st_mode)) {
+				rc = scan_rom(path2, file);
+				if (rc < 0)
+					return rc;
+			}
+		}
+
+		result |= rc;
+		free(path2);
+
+skip:
+		free(namelist[i]);
+	}
+	free(namelist);
+	return rc;
+}
+
+main()
+{
+	int rc;
+
+	if (map_mem("/dev/mem", 0, 0xA0000, 1) = 0)
+		fprintf(stderr, "PASS: /dev/mem 0x0-0xa0000 is readable\n");
+	else
+		fprintf(stderr, "FAIL: /dev/mem 0x0-0xa0000 not accessible\n");
+
+	/*
+	 * It's not safe to blindly read the VGA frame buffer.  If you know
+	 * how to poke the card the right way, it should respond, but it's
+	 * not safe in general.  Many machines, e.g., Intel chipsets, cover
+	 * up a non-responding card by just returning -1, but others will
+	 * report the failure as a machine check.
+	 */
+	if (map_mem("/dev/mem", 0xA0000, 0x20000, 0) = 0)
+		fprintf(stderr, "PASS: /dev/mem 0xa0000-0xc0000 is mappable\n");
+	else
+		fprintf(stderr, "FAIL: /dev/mem 0xa0000-0xc0000 not accessible\n");
+
+	if (map_mem("/dev/mem", 0xC0000, 0x40000, 1) = 0)
+		fprintf(stderr, "PASS: /dev/mem 0xc0000-0x100000 is readable\n");
+	else
+		fprintf(stderr, "FAIL: /dev/mem 0xc0000-0x100000 not accessible\n");
+
+	/*
+	 * Often you can map all the individual pieces above (0-0xA0000,
+	 * 0xA0000-0xC0000, and 0xC0000-0x100000), but can't map the whole
+	 * thing at once.  This is because the individual pieces use different
+	 * attributes, and there's no single attribute supported over the
+	 * whole region.
+	 */
+	rc = map_mem("/dev/mem", 0, 1024*1024, 0);
+	if (rc = 0)
+		fprintf(stderr, "PASS: /dev/mem 0x0-0x100000 is mappable\n");
+	else if (rc > 0)
+		fprintf(stderr, "PASS: /dev/mem 0x0-0x100000 not mappable\n");
+	else
+		fprintf(stderr, "FAIL: /dev/mem 0x0-0x100000 not accessible\n");
+
+	scan_sysfs("/sys/class/pci_bus", "legacy_mem", 0, 0xA0000, 1);
+	scan_sysfs("/sys/class/pci_bus", "legacy_mem", 0xA0000, 0x20000, 0);
+	scan_sysfs("/sys/class/pci_bus", "legacy_mem", 0xC0000, 0x40000, 1);
+	scan_sysfs("/sys/class/pci_bus", "legacy_mem", 0, 1024*1024, 0);
+
+	scan_rom("/sys/devices", "rom");
+}
