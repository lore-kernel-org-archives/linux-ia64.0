From: Ben Woodard <woodard@redhat.com>
Date: Wed, 04 Feb 2004 01:19:50 +0000
Subject: Re: [patch] 0/5 2.4.25-pre7 mca.c cleanup
Message-Id: <1075857590.11543.89.camel@xenophanes>
List-Id: <linux-ia64.vger.kernel.org>
References: <6503.1075705201@kao2.melbourne.sgi.com>
In-Reply-To: <6503.1075705201@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith,

I just tested your changes and unfortunately though they definitely
eliminate the possibility that a race condition occurs in the printing
of the errors by the mca handlers, it does not fix our problem here.

There still seems to be some sort of race condition (or other error) in
the salinfo /proc file system handling code. The reason that I believe
this is that when I trigger the memory errors with the salinfo_decode
daemon running the machine immediately hangs. If I kill the
salinfo_decode daemons first and then trigger the errors, the computer
survives. I can then start the salinfo_decode daemons and everything
works fine and I get some errors stored in the decoded area.

One thing that I have noticed in the errors was that in some of the
cases I would see something like:

CPU 3: SAL log contains CPE error record
CPU 1: SAL log contains CPE error record

Then the computer would hang. Whereas in the cases where I wasn't
running the salinfo_decode daemon what I see is:

CPU 3: SAL log contains CPE error record
CPU 3: SAL log contains CPE error record
CPU 3: SAL log contains CPE error record
CPU 3: SAL log contains CPE error record
CPU 1: SAL log contains CPE error record
...<for a long time>

This leads me to believe that it is a race condition somewhere either in
the way that the salinfo /proc file system is implemented or in the
interaction between the mca handler and the salinfo.

One last thing, we are running a slightly patched version of
salinfo_decode here. There are two distinct changes. One of which you
are exceptionally familiar with and the other is of my own contrivance.

--- salinfo-0.4/mca.c   2003-12-04 12:03:18.000000000 -0800
+++ salinfo-0.4-new/mca.c       2004-01-29 14:13:25.000000000 -0800
@@ -834,7 +834,7 @@
                iprintf("Invalid PCI Component Error Record format: length = %d, "
                       " Size PCI Data = %ld, Num Mem-Map/IO-Map Regs = %d/%d\n",
                       pcei->header.len, n_pci_data, n_mem_regs, n_io_regs);
-               return;
+               goto out;
        }
  
        if (n_mem_regs) {
@@ -857,6 +857,8 @@
        }
        if (pcei->valid.oem_data)
                platform_pci_comp_err_print(&pcei->header, p_oem_data);
+ out:
+       --indent;
 }
  
 /* Format and log the platform specifie error record section data */
diff -ru salinfo-0.4/salinfo_decode.c salinfo-0.4-new/salinfo_decode.c
--- salinfo-0.4/salinfo_decode.c        2003-11-24 14:37:28.000000000 -0800
+++ salinfo-0.4-new/salinfo_decode.c    2004-01-29 15:14:50.000000000 -0800
@@ -276,10 +276,15 @@
                        cpu,
                        type,
                        suffix);
-               if (!(freopen(filename, "w", stdout) && freopen(filename, "w", stderr))) {
-                       perror(filename);
+               if ((fd = open(filename, O_WRONLY|O_CREAT|O_EXCL, S_IRUSR|S_IWUSR)) < 0){
+                       perror(filename);
                        goto out;
                }
+               if ( dup2(1,fd) != 1 && dup2(2,fd) != 2){
+                       perror(filename);
+                       goto out;
+               }
+               close(fd);
  
                printf("BEGIN HARDWARE ERROR STATE from %s on cpu %d\n", type, cpu);
                platform_info_print(buffer, 1, fd_data, cpu, oemdata_fd);

The changes in salinfo_decode.c fix a problem where the salinfo_decode
daemon crashes when it receives the second error since stdout and stderr
are already closed causing the freopen to fail.

I'm going to begin looking for the race condition. Let me know via
private email if you find it before I do even if you do not have a fix
for it yet, so that I don't waste my time looking for something you've
already found. I'll do the same for you. When we have the fix, we'll
return to the linux-ia64 mailing list.

-ben

On Mon, 2004-02-02 at 17:27, Keith Owens wrote:
> On 02 Feb 2004 16:36:17 -0800, 
> Ben Woodard <woodard@redhat.com> wrote:
> >Jim Garlick and I have both been trying to make the smallest changes
> >possible to fix the problems we have been seeing.
> 
> My changes delete all of the unnecessary and racy use of printk() from
> mca.c, which should go a long way to fixing the problems that you and
> Jim are seeing.  If you still see hangs or problems after my clean up,
> please let me know ASAP.

