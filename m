From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 16 Jun 2004 16:32:14 +0000
Subject: Re: fix for palinfo.c
Message-Id: <200406161032.14087.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 15 June 2004 11:28 am, Stephane Eranian wrote:
> Please apply this following patch to palinfo.c.
> 
> Thanks
> 
> ChangeLog:
> 	- Fix tfor description of bit 52 and 53 of bus_info. They were swapped
> 	- Fix typo for bit 55 in bus_info.

Your patch didn't apply cleanly, but I did it by hand.  Can you check that
the attached is correct?  Thanks.

#### AUTHOR eranian@hpl.hp.com
#### COMMENT START
### Comments for ChangeSet
[PATCH] ia64: fix info in /proc/pal/*/bus_info

This patch fixes to minor bugs:
 - corrected descriptions for bit 52 and 53 of the /proc/pal/CPU*/bus_info
   entry; they were swapped
 - corrected a typo for bit 55 of the /proc/pal/CPU*/bus_info entry

Signed-off-by: Stephane Eranian <eranian@hpl.hp.com>
Signed-off-by: David Mosberger <davidm@hpl.hp.com>
Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
### Comments for arch/ia64/kernel/palinfo.c
ia64: fix info in /proc/pal/*/bus_info
#### COMMENT END

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/06/16 10:28:33-06:00 eranian@hpl.hp.com 
#   [PATCH] ia64: fix info in /proc/pal/*/bus_info
#   
#   This patch fixes to minor bugs:
#    - corrected descriptions for bit 52 and 53 of the /proc/pal/CPU*/bus_info
#      entry; they were swapped
#    - corrected a typo for bit 55 of the /proc/pal/CPU*/bus_info entry
#   
#   Signed-off-by: Stephane Eranian <eranian@hpl.hp.com>
#   Signed-off-by: David Mosberger <davidm@hpl.hp.com>
#   Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
# 
# arch/ia64/kernel/palinfo.c
#   2004/06/16 10:25:13-06:00 eranian@hpl.hp.com +2 -2
#   ia64: fix info in /proc/pal/*/bus_info
# 
diff -Nru a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
--- a/arch/ia64/kernel/palinfo.c	2004-06-16 10:28:54 -06:00
+++ b/arch/ia64/kernel/palinfo.c	2004-06-16 10:28:54 -06:00
@@ -509,10 +509,10 @@
 	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 	NULL, NULL, NULL, NULL,
-	"Enable Cache Line Repl. Exclusive",
 	"Enable Cache Line Repl. Shared",
+	"Enable Cache Line Repl. Exclusive",
 	"Disable Transaction Queuing",
-	"Disable Reponse Error Checking",
+	"Disable Response Error Checking",
 	"Disable Bus Error Checking",
 	"Disable Bus Requester Internal Error Signalling",
 	"Disable Bus Requester Error Signalling",
