From: "H . J . Lu" <hjl@valinux.com>
Date: Thu, 15 Feb 2001 20:21:17 +0000
Subject: Re: [Linux-ia64] gnu-efi-1.1 released
Message-Id: <marc-linux-ia64-105590693005154@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205639@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205639@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 30, 2000 at 01:55:19PM -0800, Stephane Eranian wrote:
> 
> Hi All,
> 
> I have uploaded version 1.1 of the gnu-efi package on our FTP site.
> 

Here is a patch to define INTERFACE_DECL for gcc.


H.J.
---
--- gnu-efi-1.1/inc/ia32/efibind.h.type	Mon Oct  9 17:49:02 2000
+++ gnu-efi-1.1/inc/ia32/efibind.h	Thu Feb 15 12:07:16 2001
@@ -206,3 +206,19 @@ typedef uint32_t   UINTN;
             (_if)->LoadInternal(type, name, entry)
 
 #endif /*  EFI_FW_NT  */
+
+/* 
+ *  Some compilers don't support the forward reference construct:
+ *   typedef struct XXXXX
+ * 
+ *  The following macro provide a workaround for such cases.
+ */
+#ifdef __GNUC__
+#define INTERFACE_DECL(x) struct x
+#else
+#ifdef NO_INTERFACE_DECL
+#define INTERFACE_DECL(x)
+#else
+#define INTERFACE_DECL(x) typedef struct x
+#endif
+#endif
--- gnu-efi-1.1/inc/ia64/efibind.h.type	Mon Oct  9 17:49:02 2000
+++ gnu-efi-1.1/inc/ia64/efibind.h	Thu Feb 15 12:05:34 2001
@@ -156,3 +156,18 @@ typedef uint64_t   UINTN;
 #define LOAD_INTERNAL_DRIVER(_if, type, name, entry)    \
         (_if)->LoadInternal(type, name, entry)
 
+/* 
+ *  Some compilers don't support the forward reference construct:
+ *   typedef struct XXXXX
+ * 
+ *  The following macro provide a workaround for such cases.
+ */
+#ifdef __GNUC__
+#define INTERFACE_DECL(x) struct x
+#else
+#ifdef NO_INTERFACE_DECL
+#define INTERFACE_DECL(x)
+#else
+#define INTERFACE_DECL(x) typedef struct x
+#endif
+#endif

