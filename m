From: "Donny Cooper" <dcooper@hstc.necsyl.com>
Date: Thu, 26 Apr 2001 14:36:11 +0000
Subject: [Linux-ia64] malloc problems
Message-Id: <marc-linux-ia64-105590693005473@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

3 SDV systems, we'll call them Tom, Dick, & Harry:
(2)BigSur
	Tom   (1 x B3, 1GB Mem)
	Dick  (2 x B3, 1GB Mem)
(1)Lion
	Harry (4 x B3, 4GB Mem)

Problem:
When running the exact same executable, Dick and Harry, consistently give
the same results and Tom consistently gives different results.


Systems have been verified to be the same in many aspects:
OS environment
Kernel
BIOS/Firmware
CMOS settings
Mem type and board locations
SCSI and settings

Below is a small sample of code and the results I get on each system:

dynamic_area = (unsigned char *) malloc ( membytes );
printf(" dyn_area = %x %lx, mem= %x \n",dynamic_area,dynamic_area,membytes);

Result from Tom: (1-way BigSur)
dyn_area = 40000010 40000010, mem= 2000018

Result from Dick & Harry:(2-way BigSur & 4-way Lion)
dyn_area = 10 2000000000000010, mem= 2000018

Is it a single-CPU thing?
Any ideas are appreciated.

Thanks.
***************************************************************************
Donny Cooper                     | Direct Phone : (281) 465-1506
NEC Systems, Inc.                | Houston Metro: (281) 296-0912 x 1506
High Performance Computing Center| Fax          : (281) 465-1599
4200 Research Forest Dr, #400    | E-mail       : dcooper@atcc.necsyl.com
The Woodlands, TX 77381          | URL          : http://www.necservers.com
***************************************************************************


