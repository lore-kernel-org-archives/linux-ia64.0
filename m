From: Cary Coutant <cary@cup.hp.com>
Date: Mon, 26 Mar 2001 22:58:42 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005353@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Just to make it explicit.  Will the runtime architecture be updated to
>forbid a call as the last instruction in an unwind region?  Or do we
>have to somehow cope with this corner case?

I have made the following proposal, in the IA-64 psABI group, to amend 
the runtime document:

>... I propose adding the following rule to Section 8.7, 
>"Requirements for unwinding the stack," in the Software Conventions and 
>Runtime Architecture document:
>
>* The return BR must contain an address that can be used to
>  determine the unwind state of the calling procedure. For
>  example, a compiler may choose to optimize calls to
>  procedures that do not return. If it does so, however, it must
>  ensure that the unwind information for the procedure properly
>  describes the unwind state at the return point, even though the
>  return point will never be executed. This may require the
>  insertion of an otherwise unnecessary nop or break instruction.

-cary

