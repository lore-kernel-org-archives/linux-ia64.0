From: "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com>
Date: Fri, 11 Apr 2003 19:05:30 +0000
Subject: [Linux-ia64] ias and stack unwind
Message-Id: <marc-linux-ia64-105590723705471@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone had any problems with the stack unwind directives and ias?
For some reason when I put the unwind directives in my assembler code,
then do a "readelf -u", it says that the assembly routine has version 2
unwind info and can't list it.  libunwind seems to have similar problems
and can't unwind from the assembly routine.  For all the C routines in
the program, the unwind info version is 1, as the IA64 Software Conventions
and Runtime Architecture Guide indicates it should be.

Any pointers for getting ias to use version 1 would be appreciated.


Jay

