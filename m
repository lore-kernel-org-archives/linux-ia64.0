From: "Robert K Gjertsen" <gjertsen@us.ibm.com>
Date: Tue, 30 Oct 2001 14:30:22 +0000
Subject: [Linux-ia64] Re: Lion problems with 2.4.13...
Message-Id: <marc-linux-ia64-105590698805415@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I haven't tried this out yet, but I plan to in a day or two. No guarantees
for non-ibm machines, but
I figure we just grabbed this from Intel (and I'll be applying this to my
beta level Lion / boat anchor).

You can get the BIOS-99 and BMC-24 (Bios/Firmware 1.1) on the web at:
www.pc.ibm.com\support    by
searching on xSeries 380 86831rx

or (much easier)

ftp.pc.ibm.com /pub/pccbbs/pc_servers/33p2588.iso
          /pub/pccbbs/pc_servers/33p2588.zip  (for LS120)
                           33p2588.txt



On an entirely different note, I see that flush_tlb_all is exported by the
Linux kernel. I've rolled my own
functions for flush_tlb_page and flush_tlb_range for our filesystem, but it
would be nice if these were
also exported by the kernel (I see there is a ptcg lock being used in this
code although I think I'm OK
not using this on pages that we are fiddling with).
How do I go about seeing if flush_tlb_range could also be exported in the
ia64 Linux code stream?

--Rob


