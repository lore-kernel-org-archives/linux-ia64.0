From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 16 Dec 2005 10:16:41 +0000
Subject: Re: [Gelato-technical] Linux-on-Linux for IA64
Message-Id: <20051216101641.GB19488@frankl.hpl.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="5mCyUwZo2JvN/JJP"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Peter,

On Fri, Dec 16, 2005 at 02:09:18PM +1100, Peter Chubb wrote:
> 
> Hi Folks,
> 	Ever wanted UML-like functionality for Itanium?  Now you can
> have it!
> 
Yes!

> This week we made the first release of Linux-On-Linux, a
> paravirtualised system that allows Linux to be used as a hypervisor.
> 
> You can get it from
> http://www.ertos.nicta.com.au/software/virtualisation/
> 
Got this to compile using 2.6.15-rc5 (host/guest). I had to manually
apply two small patches in the guest.

I had to use the attached patch for the vmm.

The problem is that it does not boot, I get this:

$ vmm bootloader vmlinux maxcpus=2 simscsi=sd
args: vmlinux maxcpus=2 simscsi=sd
Allowing running on processor 0 of 2
pagesize = 16384
Physical memory at 0x80000 -> 0x20000000
[3460] Hi, I am the trace thread!
3462: CPU 0
entry = 0x1008e0
loading vmlinux...
starting kernel...
purging region 4
Cannot map from 0x8000000100000000,0x8000000103ffffff to 0x4000000--- [3462] SIGSEGV in VMM: IP 0x20001e170 VA 0x60000fffffb33b08
Exited with signal 6
1 stops, 0 redirects, 0 VMM, 0 sigreturns, 0 signalstops, 0 traps, 1 sigstops


Any clue?

-- 

-Stephane

--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="vmm.diff"

diff -ur vmm.orig/userspace/main.c vmm/userspace/main.c
--- vmm.orig/userspace/main.c   2005-12-13 17:22:28.000000000 -0800
+++ vmm/userspace/main.c        2005-12-16 02:06:58.000000000 -0800
@@ -403,7 +403,7 @@
 void
 vm_perror(char *string)
 {
-       fprintf(stderr, "%s: %s\n", string, sys_errlist[errno]);
+       fprintf(stderr, "%s: %s\n", string, strerror(errno));
 }

 /*
diff -ur vmm.orig/userspace/syscall.c vmm/userspace/syscall.c
--- vmm.orig/userspace/syscall.c        2005-12-05 16:23:53.000000000 -0800
+++ vmm/userspace/syscall.c     2005-12-16 02:08:04.000000000 -0800
@@ -147,7 +147,7 @@
        }

        if (ptrace(PTRACE_ADDRRANGE, pid, 0UL, &_text - 1) == -1)
-               fprintf(stderr, "ptrace(ADDRRANGE failed: %s\n", sys_errlist[errno]);
+               fprintf(stderr, "ptrace(ADDRRANGE failed: %s\n", strerror(errno));
        else
                ptrace(PTRACE_ADDRRANGE, pid, &_etext, (5UL<<61)-(unsigned long)&_etext);


--5mCyUwZo2JvN/JJP--
