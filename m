From: Andreas Schwab <schwab@suse.de>
Date: Tue, 27 Aug 2002 19:24:21 +0000
Subject: Re: [Linux-ia64] PATCH 2.4.19 ppp_generic.c
Message-Id: <marc-linux-ia64-105590701905987@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905985@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905985@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-9"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Grant Grundler <grundler@cup.hp.com> writes:

|> ppp_generic.c won't build as a module.
|> Using "outl" as a label is a bad idea.

IMHO <asm/io.h> should be fixed:

--- linux/include/asm-ia64/io.h.~1~
+++ linux/include/asm-ia64/io.h
@@ -272,18 +272,18 @@ __outsl (unsigned long port, void *src,=20
 #define __outw		platform_outw
 #define __outl		platform_outl
=20
-#define inb		__inb
-#define inw		__inw
-#define inl		__inl
-#define insb		__insb
-#define insw		__insw
-#define insl		__insl
-#define outb		__outb
-#define outw		__outw
-#define outl		__outl
-#define outsb		__outsb
-#define outsw		__outsw
-#define outsl		__outsl
+#define inb(a)		__inb(a)
+#define inw(a)		__inw(a)
+#define inl(a)		__inl(a)
+#define insb(a,b,c)	__insb(a,b,c)
+#define insw(a,b,c)	__insw(a,b,c)
+#define insl(a,b,c)	__insl(a,b,c)
+#define outb(a,b)	__outb(a,b)
+#define outw(a,b)	__outw(a,b)
+#define outl(a,b)	__outl(a,b)
+#define outsb(a,b,c)	__outsb(a,b,c)
+#define outsw(a,b,c)	__outsw(a,b,c)
+#define outsl(a,b,c)	__outsl(a,b,c)
=20
 /*
  * The address passed to these functions are ioremap()ped already.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

