From: Daniel Yeisley <dpy102@alumni.psu.edu>
Date: Fri, 22 Mar 2002 20:57:07 +0000
Subject: [Linux-ia64] ia64_log_get error while booting
Message-Id: <marc-linux-ia64-105590701905330@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm new to Linux on the IA64.  I installed Redhat 7.2 for the Itanium on a Lion 
system this morning.  It seemed to work fine.  I changed my screen resolution 
and rebooted.  I get a warning saying that my event log is full.  Linux starts 
to boot, but then it goes into what seems to be an infinite loop of alternating 
error messages.  They go by very quickly, but I believe that they are:
ia64_log_get: Failed to retrieve SAL error record type ...
ia64_mca_cpe_int_handler: received interrupt. vector = 
I've looked in the kernel source and both messages come from mca.c.  I'm not 
sure what the problem is.  I can't boot the machine, not even from the Redhat 
CDs.




--------------------------------------------------
Get Your FREE E-Mail Account Today at AcmeMail.net
http://www.acmemail.net

