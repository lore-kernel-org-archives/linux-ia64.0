From: Ben Woodard <woodard@redhat.com>
Date: Fri, 30 Jan 2004 02:36:23 +0000
Subject: Re: salinfo-0.4 patch
Message-Id: <1075430183.28355.22.camel@xenophanes>
List-Id: <linux-ia64.vger.kernel.org>
References: <1075324928.25461.273.camel@xenophanes>
In-Reply-To: <1075324928.25461.273.camel@xenophanes>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

How about this:

diff -ru salinfo-0.4/mca.c salinfo-0.4-new/mca.c
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
Only in salinfo-0.4-new/: mca.c~
Only in salinfo-0.4-new/: mca.c,v
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
+               if ( dup2(fd,1) != 1 && dup2(fd,2) != 2){
+                       perror(filename);
+                       goto out;
+               }
+               close(fd);
  
                printf("BEGIN HARDWARE ERROR STATE from %s on cpu %d\n", type, cpu);
                platform_info_print(buffer, 1, fd_data, cpu, oemdata_fd);


I found another bug that I tripped over. Evidently when running as a
daemon the freopen fails because the file is closed or something. I
didn't investigate the error state carefully. When it tries to do a
write later on in response to one of the printfs, it barfs and says gets
an error with EPIPE and the program monitoring that class of bugs exits.
Obviously this problem disappears if you run salinfo_decode
interactively. 

Doing the open and the dup2's seems to fix that problem but it hasn't
been extensively tested. We have this tiny little problem with the whole
salinfo system. It hangs the system.

When we ran the salinfo_decode code interactively it seemed to hang the
system because it was getting hung up on the freopen. However, when we
ran it with the init script and it made a daemon, then the system
appeared to stay up. It turns out that this was only because the CPE
version of salinfo_decode was exiting when it got the the freopen.
Therefore it was never getting to the bug (which Jim and I think is
likely a race condition of some kind) that hangs the system.

Now that I fixed the problem with freopen running as a daemon and the
salinfo_decode program gets beyond that point even when it is running in
a daemon mode, we are hanging the system almost every single time now. 

Jim is looking for more race conditions and for ways to fix the ones he
already sees. I will be working on that as well on Monday.

-ben


On Wed, 2004-01-28 at 15:43, Keith Owens wrote:
> On 28 Jan 2004 15:23:28 -0800, 
> Ben Woodard <woodard@redhat.com> wrote:
> >It is a race, let's see who can find the missing --indent first. ;-)
> 
> --- mca.c.old	2004-01-29 10:43:05.000000000 +1100
> +++ mca.c	2004-01-29 10:43:08.000000000 +1100
> @@ -834,7 +834,7 @@
>  		iprintf("Invalid PCI Component Error Record format: length = %d, "
>  		       " Size PCI Data = %ld, Num Mem-Map/IO-Map Regs = %d/%d\n",
>  		       pcei->header.len, n_pci_data, n_mem_regs, n_io_regs);
> -		return;
> +		goto out;
>  	}
>  
>  	if (n_mem_regs) {
> @@ -857,6 +857,8 @@
>  	}
>  	if (pcei->valid.oem_data)
>  		platform_pci_comp_err_print(&pcei->header, p_oem_data);
> +out:
> +	--indent;
>  }
>  
>  /* Format and log the platform specifie error record section data */

