From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 05 Dec 2000 10:58:57 +0000
Subject: Re: [Linux-ia64] No unwind data for ivt.S
Message-Id: <marc-linux-ia64-105590678205785@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205783@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205783@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 05 Dec 2000 11:46:01 +1100, 
Keith Owens <kaos@ocs.com.au> wrote:
>There is no unwind data in arch/ia64/kernel/ivt.S nor minstate.h (patch
>2.4.0-test10-ia64-001115) which makes it impossible to unwind past an
>interrupt.  Before I start on this code, has anybody already added
>unwind data to ivt.S?

Forget it, my error.  The problem was an old linker that did not sort
the unwind data.  By sheer coincidence the search algorithm found all
the correct unwind entries down to but not including the interrupt
handler - every time!


