From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 24 Mar 2001 01:27:28 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005349@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 23 Mar 2001 16:58:59 -0800, 
Cary Coutant <cary@cup.hp.com> wrote:
>Except for calls to noreturn procedures (which I failed to anticipate in 
>the design and specification of the unwind architecture), the return 
>point must always be in the same unwind region as the call, because 
>nothing can happen to change the unwind state between the call and the 
>return point.

Just to make it explicit.  Will the runtime architecture be updated to
forbid a call as the last instruction in an unwind region?  Or do we
have to somehow cope with this corner case?


