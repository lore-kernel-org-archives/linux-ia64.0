From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Tue, 12 Dec 2017 02:47:57 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20171212024757.GC7798@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <1513009569.26342.43.camel@perches.com>
In-Reply-To: <1513009569.26342.43.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On (12/11/17 08:26), Joe Perches wrote:
> On Mon, 2017-12-11 at 21:50 +0900, Sergey Senozhatsky wrote:
> > print_symbol
> 
> Yay.
> 
> Just about exactly 5 years earlier...
> http://lists.infradead.org/pipermail/linux-arm-kernel/2012-December/137121.html

indeed :)

hopefully it won't take us another 5 years to finally

---

 include/linux/kallsyms.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
index 7288f9c395b6..794fd35cad4b 100644
--- a/include/linux/kallsyms.h
+++ b/include/linux/kallsyms.h
@@ -176,7 +176,8 @@ void __check_printsym_format(const char *fmt, ...)
 {
 }
 
-static inline void print_symbol(const char *fmt, unsigned long addr)
+static inline void __deprecated print_symbol(const char *fmt,
+					     unsigned long addr)
 {
 	__check_printsym_format(fmt, "");
 	__print_symbol(fmt, (unsigned long)

---

	-ss
