From: Gururaj Ananthateerta <gururaj@cup.hp.com>
Date: Sat, 10 Nov 2001 00:08:06 +0000
Subject: [Linux-ia64] adding new network device driver
Message-Id: <marc-linux-ia64-105590698805461@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have written a driver for a netwok deive. I want to add it in the kernel.
I have compiled the code with 2.4.0 patched with the latest patch. The new
kernel (my_kernel) contains my driver symbols. 

When I boot with new kernel my driver probe routine is not entered. 
Is there anyplace I need to inform the kernel about the existence 
of the new driver.

THis is on ia64 on RH7.1 and whole thing is on Lion.

Thanks
Guru


