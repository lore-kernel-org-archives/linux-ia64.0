From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 01 Nov 2001 00:49:37 +0000
Subject: Re: [Linux-ia64] gcc won't inline function returning struct?
Message-Id: <marc-linux-ia64-105590698805432@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805421@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805421@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>If it makes function calls when the author was expecting it to do two
>computations, its performance may well be insufficient to function.

I've never heard this argument before.  It does make some sense.

It does have a flaw though.  If the code was originally written for IA-32, and
proven to meet timing constraints on the IA-32 host, then there is no guarantee
that it will work on an IA-64 host.  The timing analysis will all have to be
redone.  So perhaps the program has a valid reason for using extern inline,
but it is still non-portable, which was the point I was trying to make.

Jim

