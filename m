From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Aug 2007 23:41:11 +0000
Subject: RE: [PATCH] [429/2many] MAINTAINERS - SGI SN-IA64 (Altix) SERIAL CONSOLE DRIVER
Message-Id: <617E1C2C70743745A92448908E030B2A0229F782@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46bffbb8.4fakUMLGtqE0GdFV%joe@perches.com>
In-Reply-To: <46bffbb8.4fakUMLGtqE0GdFV%joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: joe@perches.com, torvalds@linux-foundation.org, pfg@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@linux-foundation.org


@@ -4084,6 +4084,7 @@ P:	Pat Gefre
 M:	pfg@sgi.com
 L:	linux-ia64@vger.kernel.org
 S:	Supported
+F:	Documentation/ia64/serial.txt
 
 SGI VISUAL WORKSTATION 320 AND 540
 P:	Andrey Panin


Huh?  Perhaps this should be:

+F:	drivers/serial/sn_console.c

-Tony
