From: "Tang, Yu" <yu.tang@intel.com>
Date: Tue, 15 Jan 2002 07:56:16 +0000
Subject: RE: [Linux-ia64] kmalloc() size-limitation
Message-Id: <marc-linux-ia64-105590698805829@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805828@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805828@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

if I am not missing something, kmalloc is SLAB based on _get_free_pages
nowadays,  and alloc_pages() is based on _get_free_pages directly.  you may
get the more limitations than alloc_pages(). the reason for choosing kmalloc
mainly, is that it makes less fragments when allocing and freeing memories
that's not large as pages.

-----Original Message-----
From: Christian Hildner [mailto:christian.hildner@hob.de]
Sent: 2002年1月15日 15:15
To: davidm@hpl.hp.com; linux ia64 kernel list; LKML
Subject: [Linux-ia64] kmalloc() size-limitation


David,

you proposed me to use alloc_pages() instead of kmalloc() in order to get
memory bigger than the
128K limit of the kmalloc() call. But even driver-developers don't want to
handle with the page
struct unless this is unavoidable. Which are the disadvantages of increasing
the size limit of
kmalloc() to 256K, 512K or 1M since machines are getting bigger and 64Bit
machines break with
current memory limitations?

Since kmalloc() is implemented in the non arch specific part this also goes
to the lkml.

Christian


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

