From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 15 Jan 2002 07:14:52 +0000
Subject: [Linux-ia64] kmalloc() size-limitation
Message-Id: <marc-linux-ia64-105590698805828@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

you proposed me to use alloc_pages() instead of kmalloc() in order to get memory bigger than the
128K limit of the kmalloc() call. But even driver-developers don't want to handle with the page
struct unless this is unavoidable. Which are the disadvantages of increasing the size limit of
kmalloc() to 256K, 512K or 1M since machines are getting bigger and 64Bit machines break with
current memory limitations?

Since kmalloc() is implemented in the non arch specific part this also goes to the lkml.

Christian


