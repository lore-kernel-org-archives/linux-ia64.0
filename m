From: dann frazier <dannf@hp.com>
Date: Sat, 08 Jan 2005 02:42:42 +0000
Subject: Re: sn/kernel/bte_error.c build error
Message-Id: <20050108024242.GB7366@jale>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201841.GB6009@jale>
In-Reply-To: <20050106201841.GB6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A UP build of 2.6.10 fails in bte_error.c because HZ is undefined.
Approved by Jesse in Message-Id: <200501061330.48941.jbarnes@engr.sgi.com>

Signed-off-by: dann frazier <dannf@hp.com>
Signed-off-by: Jesse Barnes <jbarnes@engr.sgi.com>

--- kernel-source-2.6.10/arch/ia64/sn/kernel/bte_error.c.orig	2005-01-06 13:20:10.954478087 -0700
+++ kernel-source-2.6.10/arch/ia64/sn/kernel/bte_error.c	2005-01-06 12:54:41.483793698 -0700
@@ -15,6 +15,7 @@
 #include "xtalk/xwidgetdev.h"
 #include "xtalk/hubdev.h"
 #include <asm/sn/bte.h>
+#include <asm/param.h>
 
 /*
  * Bte error handling is done in two parts.  The first captures
