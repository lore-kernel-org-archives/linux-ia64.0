From: Martin Hicks <mort@wildopensource.com>
Date: Wed, 11 Feb 2004 21:23:28 +0000
Subject: Re: [PATCH] Add EXPORT_SYMBOL for physical_node_map
Message-Id: <20040211212328.GN12142@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ZPDwMsyfds7q4mrK"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040203185728.GX13322@localhost>
In-Reply-To: <20040203185728.GX13322@localhost>
To: linux-ia64@vger.kernel.org


--ZPDwMsyfds7q4mrK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline



On Tue, Feb 10, 2004 at 01:51:43PM -0800, David Mosberger wrote:
> >>>>> On Tue, 3 Feb 2004 13:57:28 -0500, Martin Hicks <mort@wildopensource.com> said:
> 
>   Martin> Can you please include this EXPORT_SYMBOL in the next release.  A few
>   Martin> macros that use physical_node_map are used in modules.
> 
> I share Christoph's concern but since this code is SGI's and Jesse is
> apparently OK with it, I'd have applied it---if only the patch
> actually applied.  I think there is some whitespace breakage in your
> patch.

Here's another attempt then.  Against Linus' latest bk tree.

mh

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE

--ZPDwMsyfds7q4mrK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="physical_node_map-2.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1610  -> 1.1611 
#	arch/ia64/sn/kernel/setup.c	1.31    -> 1.32   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/11	mort@green.i.bork.org	1.1611
# Export physical_node_map
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Wed Feb 11 16:21:36 2004
+++ b/arch/ia64/sn/kernel/setup.c	Wed Feb 11 16:21:36 2004
@@ -71,6 +71,8 @@
 
 short physical_node_map[MAX_PHYSNODE_ID];
 
+EXPORT_SYMBOL(physical_node_map);
+
 int	numionodes;
 /*
  * This is the address of the RRegs in the HSpace of the global

--ZPDwMsyfds7q4mrK--
