From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 27 Jul 2004 08:24:41 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <41061149.1030709@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes schrieb:

>I'm also worried about a few things in this patch.  Is relocate_kernel.S 
>really necessary in 2.6?  Can we copy the kernel to a contiguous 64MB aligned 
>area, drop into phys mode and just jump to it?  
>
You should be safe with that but you should consider flushing TLB 
entries of the old kernel before the newly started kernel inserts its 
own translations.

Christian

