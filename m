From: Keith Owens <kaos@sgi.com>
Date: Sat, 15 Mar 2003 02:40:54 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590709806129@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 15 Mar 2003 13:36:01 +1100, 
Keith Owens <kaos@sgi.com> wrote:
>David, closing the 1 bundle unwind window was a bit harder than I
>expected, it turns out that altrp does not specify where it applies, it
>is prologue global.  To get altrp to apply after mov b7=r28, I needed
>multiple prologues and bodies.  AFAICT this will unwind correctly on
>any instruction within ia64_spinlock_contention.  Could you verify that
>on your simulator (assuming it supports .save ar.pfs,r0)?

Damned cut and paste key!  Ignore that bit.


