From: Matthew Wilcox <willy@debian.org>
Date: Thu, 01 Nov 2001 00:40:56 +0000
Subject: Re: [Linux-ia64] gcc won't inline function returning struct?
Message-Id: <marc-linux-ia64-105590698805431@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805421@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805421@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 31, 2001 at 04:27:17PM -0800, Jim Wilson wrote:
> extern inline means emit this function inline if you can, otherwise emit
> nothing.  Since gcc makes no promise that it will inline any function, it
> is inherently unsafe to put extern inline in a C file.  There is no guarantee
> that it will work.

You're overlooking an important reason to mark functions as extern inline.
That is the case where the author knows that having the functions out
of line will cause the software to not work.  I believe this is true in
this instance -- the software is a softmodem and is therefore real-time.
If it makes function calls when the author was expecting it to do two
computations, its performance may well be insufficient to function.

It is better for this program to fail to compile than run too slowly.

-- 
Revolutions do not require corporate support.

