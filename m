From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 04 Jul 2008 23:25:30 +0000
Subject: Re: the printk problem
Message-Id: <alpine.LFD.1.10.0807041622270.2815@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com> <20080704104634.GA31634@digi.com>
	<20080704111540.ddffd241.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org>
	<alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
	<1215212420.8970.8.camel@pasglop>
In-Reply-To: <1215212420.8970.8.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, Peter Anvin <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, parisc-linux@parisc-linux.org



On Sat, 5 Jul 2008, Benjamin Herrenschmidt wrote:
>=20
> I'll give it a try using =EF=BB=BFprobe_kernel_address() instead on monda=
y.

Here's the updated patch which uses probe_kernel_address() instead (and=20
moves the whole #ifdef mess out of the code that wants it and into a=20
helper function - and maybe we should then put that helper into=20
kallsyms.h, but that's a different issue).

Still all happily untested, of course. And still with no actual users=20
converted.

			Linus

---
 lib/vsprintf.c |  108 +++++++++++++++++++++++++++++++++++++++++-----------=
---
 1 files changed, 80 insertions(+), 28 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 6021757..1fbb1c0 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -22,6 +22,8 @@
 #include <linux/string.h>
 #include <linux/ctype.h>
 #include <linux/kernel.h>
+#include <linux/kallsyms.h>
+#include <linux/uaccess.h>
=20
 #include <asm/page.h>		/* for PAGE_SIZE */
 #include <asm/div64.h>
@@ -482,6 +484,77 @@ static char *number(char *buf, char *end, unsigned lon=
g long num, int base, int
 	return buf;
 }
=20
+static char *string(char *buf, char *end, char *s, int field_width, int pr=
ecision, int flags)
+{
+	int len, i;
+
+	if ((unsigned long)s < PAGE_SIZE)
+		s =3D "<NULL>";
+
+	len =3D strnlen(s, precision);
+
+	if (!(flags & LEFT)) {
+		while (len < field_width--) {
+			if (buf < end)
+				*buf =3D ' ';
+			++buf;
+		}
+	}
+	for (i =3D 0; i < len; ++i) {
+		if (buf < end)
+			*buf =3D *s;
+		++buf; ++s;
+	}
+	while (len < field_width--) {
+		if (buf < end)
+			*buf =3D ' ';
+		++buf;
+	}
+	return buf;
+}
+
+static inline void *dereference_function_descriptor(void *ptr)
+{
+#if defined(CONFIG_IA64) || defined(CONFIG_PPC64)
+	void *p;
+	if (!probe_kernel_address(ptr, p))
+		ptr =3D p;
+#endif
+	return ptr;
+}
+
+
+/*
+ * Show a '%p' thing.  A kernel extension is that the '%p' is followed
+ * by an extra set of alphanumeric characters that are extended format
+ * specifiers.  Right now we just handle 'F' (for symbolic Function
+ * pointers) and 'S' (for Symbolic data pointers), but this can easily
+ * be extended in the future (network address types etc).
+ *
+ * The difference between 'S' and 'F' is that on ia64 and ppc64 function
+ * pointers are really function descriptors, which contain a pointer the
+ * real address.=20
+ */
+static char *pointer(const char *fmt, char *buf, char *end, void *ptr, int=
 base, int size, int precision, int type)
+{
+	switch (*fmt) {
+	case 'F':
+		ptr =3D dereference_function_descriptor(ptr);
+		/* Fallthrough */
+	case 'S': {	/* Other (direct) pointer */
+#if CONFIG_KALLSYMS
+		char sym[KSYM_SYMBOL_LEN];
+		sprint_symbol(sym, (unsigned long) ptr);
+		return string(buf, end, sym, size, precision, type);
+#else
+		type |=3D SPECIAL;
+		break;
+#endif
+	}
+	}
+	return number(buf, end, (unsigned long long) ptr, base, size, precision, =
type);
+}
+
 /**
  * vsnprintf - Format a string and place it in a buffer
  * @buf: The buffer to place the result into
@@ -502,11 +575,9 @@ static char *number(char *buf, char *end, unsigned lon=
g long num, int base, int
  */
 int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
 {
-	int len;
 	unsigned long long num;
-	int i, base;
+	int base;
 	char *str, *end, c;
-	const char *s;
=20
 	int flags;		/* flags to number() */
=20
@@ -622,29 +693,7 @@ int vsnprintf(char *buf, size_t size, const char *fmt,=
 va_list args)
 				continue;
=20
 			case 's':
-				s =3D va_arg(args, char *);
-				if ((unsigned long)s < PAGE_SIZE)
-					s =3D "<NULL>";
-
-				len =3D strnlen(s, precision);
-
-				if (!(flags & LEFT)) {
-					while (len < field_width--) {
-						if (str < end)
-							*str =3D ' ';
-						++str;
-					}
-				}
-				for (i =3D 0; i < len; ++i) {
-					if (str < end)
-						*str =3D *s;
-					++str; ++s;
-				}
-				while (len < field_width--) {
-					if (str < end)
-						*str =3D ' ';
-					++str;
-				}
+				str =3D string(str, end, va_arg(args, char *), field_width, precision,=
 flags);
 				continue;
=20
 			case 'p':
@@ -653,9 +702,12 @@ int vsnprintf(char *buf, size_t size, const char *fmt,=
 va_list args)
 					field_width =3D 2*sizeof(void *);
 					flags |=3D ZEROPAD;
 				}
-				str =3D number(str, end,
-						(unsigned long) va_arg(args, void *),
+				str =3D pointer(fmt+1, str, end,
+						va_arg(args, void *),
 						16, field_width, precision, flags);
+				/* Skip all alphanumeric pointer suffixes */
+				while (isalnum(fmt[1]))
+					fmt++;
 				continue;
=20
=20
