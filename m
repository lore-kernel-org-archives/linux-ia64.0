From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 12 Nov 2002 08:43:02 +0000
Subject: Re: [Linux-ia64] [PATCH] Performance Patch for TLB misses
Message-Id: <marc-linux-ia64-105590709805398@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805350@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805350@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger schrieb:

> Useless to the user, but dangerous to the health of the machine!
> Please note that attribute aliasing can lead to a machine-check and
> therefore is an absolute no-no (the machine check could be triggered
> either by a hardware-prefetch or due to speculative memory accesses
> inside the kernel).
>
>         --david

David, John, Mario,

I still haven't read volume 2 (System Architecture) to the end, so I learned another piece of
the total complexity of IA64 now. Maybe you want to use the other two ideas for 2.5 kernels. But
only if you like them.

Christian


