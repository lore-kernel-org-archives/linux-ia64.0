From: "Christian Groessler" <cpg@aladdin.de>
Date: Fri, 18 Aug 2000 14:11:06 +0000
Subject: [Linux-ia64] parport for ia64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0__=9ESbNhGPjhbkrPKaQo5ZkDHl8pgorfpWnwgaP2F2jljCY9GYCMyabmD5"
Message-Id: <marc-linux-ia64-105590678205356@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--0__=9ESbNhGPjhbkrPKaQo5ZkDHl8pgorfpWnwgaP2F2jljCY9GYCMyabmD5
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline




Hi,

I had to add the following file as include/asm-ia64/parport.h to compile
the parport modules on ia64.

(See attached file: parport.h.gz)

But when compiling with default optimizations, I get the following:

-----------
make[2]: Entering directory `/usr/src/linux-2.4.0-test6/drivers/parport'
gcc -D__KERNEL__ -I/usr/src/linux/include -Wall -Wstrict-prototypes -g -O2
-fomit-frame-pointer -pipe  -Wa,-x -ffixed-r13
-mfixed-range=f10-f15,f32-f127 -funwind-tables -fno-strict-aliasing
-DMODULE   -DEXPORT_SYMTAB -c parport_pc.c
parport_pc.c: In function `cleanup_module':
parport_pc.c:2698: warning: implicit declaration of function `free_dma'
parport_pc.c: In function `parport_pc_read_status':
parport_pc.c:2719: Internal compiler error in
`add_abstract_origin_attribute', at dwarf2out.c:7532
Please submit a full bug report.
See <URL:http://www.gnu.org/software/gcc/faq.html#bugreport> for
instructions.
make[2]: *** [parport_pc.o] Error 1
-----------

When I removed the -O2 from the compile flags, it compiled fine.

Kernel: linux-2.4.0-test6-ia64-000811
gcc: gcc version 2.9-ia64-000216-final

regards,
chris

--0__=9ESbNhGPjhbkrPKaQo5ZkDHl8pgorfpWnwgaP2F2jljCY9GYCMyabmD5
Content-type: application/octet-stream; 
	name="parport.h.gz"
Content-Disposition: attachment; filename="parport.h.gz"
Content-transfer-encoding: base64

H4sICDQ/nTkCA3BhcnBvcnQuaACNUEtLAzEQPptfMdJLW9rdVkSoirj0ogex1ILHkCaz3aHZJCbZ
wiL+d7PQtZeinoZ5fK/JxwzG4IR31sesugWnRSytr6fBoaSSJKyW0xBbjf0VkKFIQlMQkaxJ+I5i
aV3raVdFGC5HMF8sFhO4ms1mABuq4V00uwruI9WPst2iR73PFNbWZNJmzf7hSLKpKEBJSStUttEK
rNEtbDFJSt0oVLBtQXk6oA/50U5fuZOZzBJLztiASqOwBF68vfDn4uaar4r16nW94U9skBZk8NwO
5oyFmFLJJBiBc4WHLiycJHjCKp6i824QYNgdiiZa8h8T6BtVi9Hd/6iMNU7Sn2zsk114jI03v5n5
gZ5MfKVvoFFUQj6Gy+GZ1KPuZd8krQsUCAIAAA==

--0__=9ESbNhGPjhbkrPKaQo5ZkDHl8pgorfpWnwgaP2F2jljCY9GYCMyabmD5--


