From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Wed, 29 Mar 2006 17:31:23 +0000
Subject: Re: gate.S and recent toolchains
Message-Id: <200603291731.k2THVNjF2006521@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB0DE.1040409@sgi.com>
In-Reply-To: <442AB0DE.1040409@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> Russ Anderson wrote on Wednesday, March 29, 2006 9:23 AM
> > Chen, Kenneth W wrote:
> > > 
> > > Russ, do you reference __mca_table at run time?  It looks like so.  It's
> > > problematic that __mca_table is in __init section.  Though I doubt that
> > > was the reason Jes ran into.
> > 
> > It was right next to __ex_table in the original patch.
> > Yes, it is referenced at run time and should not be in 
> > the __init section.
> 
> I guess it's a merge error then :-P

This patch moves __mca_table out of the __init section.

Jes, can you give this a try?

-----------------------------------------------------
 arch/ia64/kernel/vmlinux.lds.S |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

Index: linux-2.6-linus/arch/ia64/kernel/vmlinux.lds.S
=================================--- linux-2.6-linus.orig/arch/ia64/kernel/vmlinux.lds.S	2006-03-28 09:03:23.000000000 -0600
+++ linux-2.6-linus/arch/ia64/kernel/vmlinux.lds.S	2006-03-29 11:24:56.943922578 -0600
@@ -70,6 +70,15 @@ SECTIONS
 	  __stop___ex_table = .;
 	}
 
+  /* MCA table */
+  . = ALIGN(16);
+  __mca_table : AT(ADDR(__mca_table) - LOAD_OFFSET)
+	{
+	  __start___mca_table = .;
+	  *(__mca_table)
+	  __stop___mca_table = .;
+	}
+
   /* Global data */
   _data = .;
 
@@ -128,15 +137,6 @@ SECTIONS
 	  *(.initcall6.init)
 	  *(.initcall7.init)
 	  __initcall_end = .;
-	}
-
-  /* MCA table */
-  . = ALIGN(16);
-  __mca_table : AT(ADDR(__mca_table) - LOAD_OFFSET)
-	{
-	  __start___mca_table = .;
-	  *(__mca_table)
-	  __stop___mca_table = .;
 	}
 
   .data.patch.vtop : AT(ADDR(.data.patch.vtop) - LOAD_OFFSET)

