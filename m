From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 25 Jan 2002 16:08:15 +0000
Subject: Re: [Linux-ia64] Patch to fix latest kernels issue with FW83
Message-Id: <marc-linux-ia64-105590698805931@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805927@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805927@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 24 January 2002 12:46 pm, Mallick, Asit K wrote:
> We have root caused the stability problem with latest kernels and FW83
> (LION platform). The following patch (based on 2.4.17) fixes the
> problem.
...
> -   "ld4.bias r2 = [%0]\n"                  \
> +   "ld4 r2 = [%0]\n"                   \

Can you elaborate on this a bit?  All I know about ld.bias is the statement
in section 4.4.6.1 of Vol 1 that

    [ld.bias] is a hint to the implementation to acquire exclusive
    ownership of the line containing the addressed data.  The bias
    hint does not affect program functionality and may be ignored
    by the implementation.

I can believe the patch is a performance optimization (my intuition is that
when the holder writes the lock to release it, the waiter will merely
invalidate its shared line, where it previously had to invalidate and
copyout its exclusive line), but I don't see how this should improve
stability.  What am I missing?
-- 
Bjorn Helgaas - bjorn_helgaas@hp.com
Linux Systems Operation R&D
Hewlett-Packard

