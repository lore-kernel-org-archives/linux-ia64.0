From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 10 Dec 2004 02:51:01 +0000
Subject: Re: [RFC] Change the effect of SAL_{GET,CLEAR}_STATE_INFO for MCA/INIT
Message-Id: <41B90F15.8060602@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12433.1102594994@ocs3.ocs.com.au>
In-Reply-To: <12433.1102594994@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> Making these calls context sensitive is a small change to SAL.  The SAL
> MCA/INIT handlers have already constructed and stored the required
> record before calling the OS handler.  All SAL has to do is :-
> 
> * Save the address of the current record on this cpu.
> * Call the OS handler.
> * On return from the OS handler, clear the pointer to the current
>   record.
> * SAL_GET_STATE_INFO - if the current record pointer is set then return
>   that record, otherwise do existing processing.
> * SAL_CLEAR_STATE_INFO - if the current record pointer is set then
>   clear that record and the current record pointer, otherwise do
>   existing processing.

That makes sense.

When I was coding my OS_MCA handler, I used to think if there were something
like SAL_{GET,CLEAR}_STATE_INFO_FROM_BOTTOM or some extra parameter for
SAL_{GET,CLEAR}_STATE_INFO to select which log it should deal.

Your proposal sounds good.
It's more simple, and more easy.

> This change is backwards compatible.

Marvelous!

BTW, who is in charge of receptionist for such proposal?


Thanks,
H.Seto

