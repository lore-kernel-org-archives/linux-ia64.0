From: =?ISO-8859-1?Q?G=E9rard_Roudier?= <groudier@free.fr>
Date: Tue, 05 Feb 2002 21:23:02 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698806010@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


On Wed, 6 Feb 2002, David S. Miller wrote:

>    From: Christoph Hellwig <hch@caldera.de>
>    Date: Wed, 6 Feb 2002 09:35:58 +0100
>
>    On Wed, Feb 06, 2002 at 12:29:06AM -0800, David S. Miller wrote:
>    > So who needs it? :-)
>
>    The new sym53c8xx driver (sym2), and that one only if is actually is
>    configured for DAC-mode (SYM_CONF_DMA_ADDRESSING_MODE > 0).
>
> It is not using the DMA apis correctly then, it should be using
> dma_addr_t which may or may not be 64-bits on a given platform.
>
> The sym2 driver needs to be fixed.

The code written at 't' time was using what was available at that time.
If you can let me know when Linux will be rewritten in Java, this will be
useful for me to be ready in time. :-)

--- sym_glue.c	Sun Dec 30 21:33:10 2001
+++ a.c	Tue Feb  5 22:17:30 2002
@@ -313,11 +313,7 @@
 #ifndef SYM_LINUX_DYNAMIC_DMA_MAPPING
 typedef u_long		bus_addr_t;
 #else
-#if	SYM_CONF_DMA_ADDRESSING_MODE > 0
-typedef dma64_addr_t	bus_addr_t;
-#else
 typedef dma_addr_t	bus_addr_t;
-#endif
 #endif

You may get a couple of warnings, but since I haven't hardware to check
this, I am ready to apply patches.


  G=E9rard.

PS:
The driver Java version is planned to be available on April the 1rst.  ;)



