From: Richard Hirst <rhirst@linuxcare.com>
Date: Thu, 12 Jul 2001 11:16:58 +0000
Subject: [Linux-ia64] 010626 kernel, copy_from_user() broken?
Message-Id: <marc-linux-ia64-105590693005846@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
  Summary:  I had to change PIPE_DEPTH in arch/ia64/lib/copy_user.S
from 21 to 4 to make copy_from_user() work with non-aligned user
addresses on my B3 cpu.  PIPE_DEPTH was 4 in the 010530 kernel.

Long description of how I got to this point:

  I'm working on the debian installer for ia64.  Most of the functionality,
including /bin/mount, is provided by busybox.  The first thing rcS does
on booting the installer is "mount proc /proc -t proc".  That worked fine
with the 010530 kernel, but fails with 010626.

Basically the kernel seems to have trouble reading the filesystem type
parameter, thinks it is an empty string, and ends up calling modprobe
for module name "".

Busybox mount uses getopt() to process its arguments, and when it finds
-t it simply sents char *filesystemtype = optarg.  That means the type
argument to mount() is different from device and dir, because it is
referencing env space.  If I make busybox malloc space for the type
string and copy optarg there, it works fine.

I got busybox mount to print the first three args to mount() before and
after the call:

0x60000000000150e0=/proc
0x60000000000160f0=/proc
0x80000fffffffbf84=proc

same before and after, as expected.  I got the kernel sys_mount to print
the address in user space of the type arg, which matched the users idea
of the value.  sys_mount() calls copy_mount_options (type, &type_page),
but if I then printk("'%s'\n", (char *)type_page), it yields ''.

I added printk's to copy_mount_options(), and saw it calls

copy_from_user(0xe00000003dc98000,0x80000fffffffbf84, 0x4000), which
claims to copy 0x7c bytes (i.e. to end of page).

I then did "export a=b" and tried the mount again; this time the type
param was at user address 0x80000fffffffbf80, and the mount worked.

Checking kernel changes, I found this.  Reverting the change made it work
again:

 
diff -urN linux-2.4.5/arch/ia64/lib/copy_user.S linux-2.4.5-lia/arch/ia64/lib/copy_user.S
--- linux-2.4.5/arch/ia64/lib/copy_user.S	Sun Apr 29 15:49:26 2001
+++ linux-2.4.5-lia/arch/ia64/lib/copy_user.S	Tue Jun 26 22:31:21 2001
@@ -35,7 +35,7 @@
 // Tuneable parameters
 //
 #define COPY_BREAK	16	// we do byte copy below (must be >)
-#define PIPE_DEPTH	4	// pipe depth
+#define PIPE_DEPTH	21	// pipe depth
 
 #define EPI		p[PIPE_DEPTH-1] // PASTE(p,16+PIPE_DEPTH-1)
 


Richard


