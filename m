From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Mon, 10 Feb 2003 05:12:33 +0000
Subject: Re: [Linux-ia64] Script for decoding PSR in oopses
Message-Id: <marc-linux-ia64-105590709805831@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 31, 2003 at 12:10:29PM -0800, Jim Hull wrote:
> Peter wrote:
> 
> > BTW, there's a bug in the AWK script:
> 
> There's also a bug in perl version of ia64_psr:

And ia64_isr is missing ir:

--- ia64_isr.orig       Mon Feb 10 16:03:42 2003
+++ ia64_isr    Mon Feb 10 16:08:28 2003
@@ -12,6 +12,7 @@
        [ 35, 1, "na" ],
        [ 36, 1, "sp" ],
        [ 37, 1, "rs" ],
+       [ 38, 1, "ir" ],
        [ 39, 1, "ni" ],
        [ 40, 1, "so" ],
        [ 41, 2, "ei" ],

Matt


