From: "Deepak Kumar Gupta, Noida" <dkumar@noida.hcltech.com>
Date: Sat, 29 Nov 2003 07:19:27 +0000
Subject: problem in using kdb-4.3- 2.4.22 for ia64
Message-Id: <marc-linux-ia64-107008951015543@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Everybody
I am trying to use kdb with 2 CPU ia64 machine (hp-zx6000). I am facing
following problems: -

1. When I have tried to compile kernel with enable usb keyboard support for
kdb, then I got compilation errors in drivers/usb/hid-core.c at line number
72. After removing the compilation error (by adding missing field input in
the structure driver/usb/hid.h), it compiles successfully.

2. After booting the system on kdb enabled kernel, when I crashed it (using
simple crash module), control goes to KDB. But my now my keyboard is not
working properly. Remember I have USB keyboard with me.

Can you suggest me where am I wrong ?

Looking for ur co-operation and help..
Please CC mail to me also, as I am not member of mailing list..

Thanks and Best Regards
Deepak Kumar Gupta
 
