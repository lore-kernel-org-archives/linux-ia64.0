From: Jack Steiner <steiner@sgi.com>
Date: Fri, 11 Jan 2002 22:42:07 +0000
Subject: Re: [Linux-ia64] latest MCA logging patch
Message-Id: <marc-linux-ia64-105590698805813@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> Will you check only for Intel firmware or all IA-64 firmware in
> existence?  The original SAL spec did not require re-entrancy and I
> don't think it's safe to remove the lock unless we know for sure that
> all existing implementations have been fixed (or are no longer in
> use).

SGI firmware should not have any reentrancy issues.

-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


