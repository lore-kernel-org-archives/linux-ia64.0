From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Wed, 08 Aug 2001 19:22:11 +0000
Subject: Re: [Linux-ia64] AGP
Message-Id: <marc-linux-ia64-105590693006013@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693006009@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693006009@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patch gets rid of the agpgart.o undefined symbol errors.
However, loading the module fails on Lion with -ENODEV (no surprise, since
there's no AGP slot). That means that the DRM modules for ATI cards
also cannot be loaded => no DRI on Lion except with Matrox (I think the
Matrox DRM driver does not require AGP to be loaded).

Martin

--- linux/drivers/char/agp/Makefile.old	Wed Aug  8 14:52:25 2001
+++ linux/drivers/char/agp/Makefile	Wed Aug  8 14:55:26 2001
@@ -5,7 +5,7 @@

 O_TARGET	:= agp.o

-export-objs := agpgart_be.o
+export-objs := agpgart_be.o vmmap.o

 list-multi := agpgart.o
 agpgart-objs := agpgart_fe.o agpgart_be.o





