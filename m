From: Greg Banks <gnb@melbourne.sgi.com>
Date: Thu, 20 Nov 2003 00:52:33 +0000
Subject: Re: qla2xxxx driver for IA64
Message-Id: <marc-linux-ia64-106928969122724@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926349321842@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926349321842@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> >>>>> On Wed, 19 Nov 2003 09:10:34 -0800, Evan Felix <evan.felix@pnl.gov> said:
> 
>   Evan> the IA64 ioctl.h file did not hav the _IOXX_BAD macros, and i
>   Evan> added them, i'm not sure how safe that was, but it compiled.
> 
> Last time I checked, the _IOXX_BAD macros were not used anywhere in
> the standard kernel and that's why I leaned against including them
> (they seemed like a very temporary thing to me).  Perhaps the driver
> could be fixed instead to not use the bad macros?

Andrew,

In the v8.00.00b6 version the function pointer for the ioctl() handler
is not set up in qla2x00_driver_template in qla_os.c so none of the
ioctl()s work anyway.

This patch fixes it.

--- drivers/scsi/qla2xxx.v8.00.00b6.orig/qla_os.c	Wed Nov  5 10:48:29 2003
+++ drivers/scsi/qla2xxx/qla_os.c	Sat Nov  8 00:54:58 2003
@@ -405,6 +405,7 @@
 	.module			= THIS_MODULE,
 	.name			= DRIVER_NAME,
 	.proc_name		= DRIVER_NAME,
+	.ioctl	    	    	= qla2x00_ioctl,
 	.proc_info		= qla2x00_proc_info,
 	.queuecommand		= qla2x00_queuecommand,
 

Also, possibly one of the contributing factors which required
the use of _IOWR_BAD instead of _IOWR is the spurious sizeof()
in exioctln.h:

#define	QL_IOCTL_BASE(idx)	\
    _IOWR_BAD(QLMULTIPATH_MAGIC, idx, sizeof(EXT_IOCTL))
                                      ^^^^^^

The macro expects a type as the third argument, not a size (despite
the name of the parameter in the macro definition).

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
