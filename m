From: "Abbott, Phillip" <phillip.abbott@hp.com>
Date: Mon, 24 Nov 2003 10:38:16 +0000
Subject: RE: PFN to virtual address for identity mapped segment
Message-Id: <marc-linux-ia64-106967039515888@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106958992125849@msgid-missing>
In-Reply-To: <marc-linux-ia64-106958992125849@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

How about porting mcore to ia-64 ? it seems to work nicely on ia-32, and
is quicker reaping dumps ...

-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Keith Owens
Sent: 24 November 2003 00:28
To: arvind.kan@wipro.com
Cc: linux-ia64@vger.kernel.org
Subject: Re: PFN to virtual address for identity mapped segment 


On Sun, 23 Nov 2003 17:56:10 +0530, 
Arvind Kandhare <arvind.kan@wipro.com> wrote:
>We are working on porting LKCD (Linux Kernel Crash Dump) to the ia64 platform.

LKCD already works on ia64, SGI use it all the time.  Inside SGI, I
(kaos a.t. sgi.com) maintain the kernel patches for LKCD, Tom Morano
(tjm a.t. sgi.com) maintains the user space code (lcrash).  Tom has
made a lot of changes to lcrash to make it support discontiguous memory
and other ia64 peculiarities.

-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
