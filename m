From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Fri, 05 Jan 2018 10:25:38 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20180105102538.GC471@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <20180105100300.j3svmcvvpfe2iows@pathway.suse.cz>
 <20180105102105.GB471@jagdpanzerIV>
In-Reply-To: <20180105102105.GB471@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On (01/05/18 19:21), Sergey Senozhatsky wrote:
> On (01/05/18 11:03), Petr Mladek wrote:
> [..]
> > Anyway, print_symbol() is an old weird API and it would be nice
> > to eventually get rid of it. I could take this patches into
> > printk.git.
> 
> no objections from my side if the patch set will go through the printk tree.
> shall we wait for ACKs or can we move on? do you plan to land it in 4.16?
> 
> > Would you mind if I change the commit messages to something like?:
> > 
> >     print_symbol() is an old weird API. It has been
> >     obsoleted by printk() and %pS format specifier.
> 
> I wouldn't. let's drop the "weird" part. other than that looks
> good to me.

oh, one more thing. one extra patch, which gets rid of
print_symbol()/__print_symbol().

8< =
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] kallsyms: remove print_symbol() function

No more print_symbol()/__print_symbol() users left, remove these
symbols.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Suggested-by: Joe Perches <joe@perches.com>
---
 Documentation/filesystems/sysfs.txt                    |  4 ++--
 Documentation/translations/zh_CN/filesystems/sysfs.txt |  4 ++--
 include/linux/kallsyms.h                               | 18 ------------------
 kernel/kallsyms.c                                      | 11 -----------
 4 files changed, 4 insertions(+), 33 deletions(-)

diff --git a/Documentation/filesystems/sysfs.txt b/Documentation/filesystems/sysfs.txt
index 9a3658cc399e..a1426cabcef1 100644
--- a/Documentation/filesystems/sysfs.txt
+++ b/Documentation/filesystems/sysfs.txt
@@ -154,8 +154,8 @@ static ssize_t dev_attr_show(struct kobject *kobj, struct attribute *attr,
         if (dev_attr->show)
                 ret = dev_attr->show(dev, dev_attr, buf);
         if (ret >= (ssize_t)PAGE_SIZE) {
-                print_symbol("dev_attr_show: %s returned bad count\n",
-                                (unsigned long)dev_attr->show);
+                printk("dev_attr_show: %pS returned bad count\n",
+                                dev_attr->show);
         }
         return ret;
 }
diff --git a/Documentation/translations/zh_CN/filesystems/sysfs.txt b/Documentation/translations/zh_CN/filesystems/sysfs.txt
index 7d3b05edb8ce..452271dda141 100644
--- a/Documentation/translations/zh_CN/filesystems/sysfs.txt
+++ b/Documentation/translations/zh_CN/filesystems/sysfs.txt
@@ -167,8 +167,8 @@ static ssize_t dev_attr_show(struct kobject *kobj, struct attribute *attr,
         if (dev_attr->show)
                 ret = dev_attr->show(dev, dev_attr, buf);
         if (ret >= (ssize_t)PAGE_SIZE) {
-                print_symbol("dev_attr_show: %s returned bad count\n",
-                                (unsigned long)dev_attr->show);
+                printk("dev_attr_show: %pS returned bad count\n",
+                                dev_attr->show);
         }
         return ret;
 }
diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
index 23190e5c940b..657a83b943f0 100644
--- a/include/linux/kallsyms.h
+++ b/include/linux/kallsyms.h
@@ -94,9 +94,6 @@ extern int sprint_symbol(char *buffer, unsigned long address);
 extern int sprint_symbol_no_offset(char *buffer, unsigned long address);
 extern int sprint_backtrace(char *buffer, unsigned long address);
 
-/* Look up a kernel symbol and print it to the kernel messages. */
-extern void __print_symbol(const char *fmt, unsigned long address);
-
 int lookup_symbol_name(unsigned long addr, char *symname);
 int lookup_symbol_attrs(unsigned long addr, unsigned long *size, unsigned long *offset, char *modname, char *name);
 
@@ -166,23 +163,8 @@ static inline int kallsyms_show_value(void)
 	return false;
 }
 
-/* Stupid that this does nothing, but I didn't create this mess. */
-#define __print_symbol(fmt, addr)
 #endif /*CONFIG_KALLSYMS*/
 
-/* This macro allows us to keep printk typechecking */
-static __printf(1, 2)
-void __check_printsym_format(const char *fmt, ...)
-{
-}
-
-static inline void print_symbol(const char *fmt, unsigned long addr)
-{
-	__check_printsym_format(fmt, "");
-	__print_symbol(fmt, (unsigned long)
-		       __builtin_extract_return_addr((void *)addr));
-}
-
 static inline void print_ip_sym(unsigned long ip)
 {
 	printk("[<%px>] %pS\n", (void *) ip, (void *) ip);
diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
index 24f456689f9c..a23e21ada81b 100644
--- a/kernel/kallsyms.c
+++ b/kernel/kallsyms.c
@@ -429,17 +429,6 @@ int sprint_backtrace(char *buffer, unsigned long address)
 	return __sprint_symbol(buffer, address, -1, 1);
 }
 
-/* Look up a kernel symbol and print it to the kernel messages. */
-void __print_symbol(const char *fmt, unsigned long address)
-{
-	char buffer[KSYM_SYMBOL_LEN];
-
-	sprint_symbol(buffer, address);
-
-	printk(fmt, buffer);
-}
-EXPORT_SYMBOL(__print_symbol);
-
 /* To avoid using get_symbol_offset for every symbol, we carry prefix along. */
 struct kallsym_iter {
 	loff_t pos;
-- 
2.15.1

