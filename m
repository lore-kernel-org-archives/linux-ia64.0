From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 04 Feb 2002 21:16:41 +0000
Subject: Re: [Linux-ia64] kmalloc() size-limitation
Message-Id: <marc-linux-ia64-105590698805986@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805828@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805828@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christian Hildner <christian.hildner@hob.de> writes:

> David,
> 
> you proposed me to use alloc_pages() instead of kmalloc() in order
> to get memory bigger than the 128K limit of the kmalloc() call. But
> even driver-developers don't want to handle with the page struct
> unless this is unavoidable. Which are the disadvantages of
> increasing the size limit of kmalloc() to 256K, 512K or 1M since
> machines are getting bigger and 64Bit machines break with current
> memory limitations?

Because drivers needs to work on all architectures and relying on
different hahavior from kmalloc() is bad.

Jes

