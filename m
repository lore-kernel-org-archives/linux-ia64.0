From: "David N. Lombard" <david.lombard@mscsoftware.com>
Date: Wed, 24 Jul 2002 14:20:08 +0000
Subject: [Linux-ia64] Re: [PATCH] arch/ia64/tools/Makefile
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070303070402070409070200"
Message-Id: <marc-linux-ia64-105590701905829@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070303070402070409070200
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

sigh...  The earlier arch/ia64/tools/Makefile patch replicated the 
action for both targets -- a redundant action.

Attached is the file I intended to send.

David N. Lombard wrote:
> The arch/ia64/tools/Makefile has an empty action for the mrproper 
> target.  The result is that arch/ia64/tools/print_offsets.s, 
> arch/ia64/tools/print_offsets, and arch/ia64/tools/offsets.h remain 
> after a "make mrproper".  The files are deleted with "make distclean".
> 
> So, this could be a (subtle) intended difference between the mrproper 
> and distclean targets, but that seems unlikely.
> 
> The attached patch moves the file deletion from the clean target 
> (invoked via distclean) to the mrproper target; the distclean target 
> still results in the files being deleted.

-- 
David N. Lombard
MSC.Software

--------------070303070402070409070200
Content-Type: text/plain;
 name="ia64-tools.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ia64-tools.diff"

--- arch/ia64/tools/Makefile.orig	Tue Jul 23 17:01:41 2002
+++ arch/ia64/tools/Makefile	Tue Jul 23 17:01:55 2002
@@ -5,9 +5,9 @@
 all: 
 
 mrproper:
+	rm -f print_offsets.s print_offsets offsets.h
 
 clean:
-	rm -f print_offsets.s print_offsets offsets.h
 
 fastdep: offsets.h
 	@if ! cmp -s offsets.h ${TARGET}; then	\

--------------070303070402070409070200--


