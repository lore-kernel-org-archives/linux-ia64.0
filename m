From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 27 May 2004 21:06:31 +0000
Subject: Re: [PATCH] don't udelay() in sn_mmiob
Message-Id: <200405271706.32205.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_XhltA6iX4kTGPOn"
List-Id: <linux-ia64.vger.kernel.org>
References: <200405261749.02254.jbarnes@engr.sgi.com>
In-Reply-To: <200405261749.02254.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org


--Boundary-00=_XhltA6iX4kTGPOn
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday, May 27, 2004 4:46 pm, David Mosberger wrote:
> Wouldn't you want at least a cpu_relax() in that loop?

That'll cause the CPU to switch to the other thread if it's SMT so it won't 
spin waiting for the access to complete?  If so, then yes.  Here's an updated 
patch.

sn_mmiob is a lightweight way to ensure PCI write ordering, intended to be 
used as an alternative to doing a PIO read. Unfortunately, with the udelay() 
in there, it ends up being slower than a PCI read on small configurations, so 
remove it in favor of a simple cpu_relax() so that we're HT-friendly.

Thanks,
Jesse

--Boundary-00=_XhltA6iX4kTGPOn
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="no-udelay-mmiob.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="no-udelay-mmiob.patch"

===== arch/ia64/sn/io/machvec/iomv.c 1.8 vs edited =====
--- 1.8/arch/ia64/sn/io/machvec/iomv.c	Tue Sep 16 12:00:45 2003
+++ edited/arch/ia64/sn/io/machvec/iomv.c	Wed May 26 13:49:19 2004
@@ -71,6 +71,6 @@
 {
 	while ((((volatile unsigned long) (*pda->pio_write_status_addr)) & SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK) != 
 				SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK)
-		udelay(1);
+		cpu_relax();
 }
 EXPORT_SYMBOL(sn_mmiob);

--Boundary-00=_XhltA6iX4kTGPOn--
