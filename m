From: "Christian Groessler" <cpg@aladdin.de>
Date: Thu, 14 Sep 2000 14:36:55 +0000
Subject: [Linux-ia64] module fix for test8
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0__=gzsViD6Vr0BBlCVTJkcdo0WpFVMFI53AOaSkZS79EZf9rxIhKhX9nLOB"
Message-Id: <marc-linux-ia64-105590678205493@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--0__=gzsViD6Vr0BBlCVTJkcdo0WpFVMFI53AOaSkZS79EZf9rxIhKhX9nLOB
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline



Hi David,

I had to do this change to ia64_ksyms.c to get some modules to
work. They complained about unknown symbol ia64_iobase.

-------------
--- ia64_ksyms.c.org    Mon Sep 11 12:31:50 2000
+++ ia64_ksyms.c        Thu Sep 14 14:44:58 2000
@@ -88,3 +88,6 @@
 EXPORT_SYMBOL_NOVERS(__udivdi3);
 EXPORT_SYMBOL_NOVERS(__moddi3);
 EXPORT_SYMBOL_NOVERS(__umoddi3);
+
+extern unsigned long ia64_iobase;
+EXPORT_SYMBOL(ia64_iobase);
-------------

ia64_iobase gets referenced in io.h's __ia64_get_io_port_base function.

David or Tim, the one responsible for this area,
could you please add the following file to
include/asm-ia64 ? It's needed to compile the parport
modules.

regards,
chris

(See attached file: parport.h.gz)

--0__=gzsViD6Vr0BBlCVTJkcdo0WpFVMFI53AOaSkZS79EZf9rxIhKhX9nLOB
Content-type: application/octet-stream; 
	name="parport.h.gz"
Content-Disposition: attachment; filename="parport.h.gz"
Content-transfer-encoding: base64

H4sICGziwDkCA3BhcnBvcnQuaACNUEtLAzEQPptfMdJLW9rdVkSoirj0ogex1ILHkCaz3aHZJCbZ
wiL+d7PQtZeinoZ5fK/JxwzG4IR31sesugWnRSytr6fBoaSSJKyW0xBbjf0VkKFIQlMQkaxJ+I5i
aV3raVdFGC5HMF8sFhO4ms1mABuq4V00uwruI9WPst2iR73PFNbWZNJmzf7hSLKpKEBJSStUttEK
rNEtbDFJSt0oVLBtQXk6oA/50U5fuZOZzBJLztiASqOwBF68vfDn4uaar4r16nW94U9skBZk8NwO
5oyFmFLJJBiBc4WHLiycJHjCKp6i824QYNgdiiZa8h8T6BtVi9Hd/6iMNU7Sn2zsk114jI03v5n5
gZ5MfKVvoFFUQj6Gy+GZ1KPuZd8krQsUCAIAAA==

--0__=gzsViD6Vr0BBlCVTJkcdo0WpFVMFI53AOaSkZS79EZf9rxIhKhX9nLOB--


