From: Christian Hildner <christian.hildner@hob.de>
Date: Thu, 10 Jan 2002 10:18:49 +0000
Subject: [Linux-ia64] kmalloc() and page sizes
Message-Id: <marc-linux-ia64-105590698805788@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all!

In the current kernels the size limit for kmalloc() is 128KB. The ia64
architecture provides pagesizes ranging from 4K, ... , 64K, 256K, ... ,
4G. If we would increase the maximum kmalloc() size limit to 256K (or
1M) this would match perfectly to the pagesizes.

Since I need a large (256K) segment from kmalloc(), I would appreciate
the increase of the size limit. Maybe also other 64Bit architectures
could benefit from that.

Please tell your opinion to the list.

Christian


