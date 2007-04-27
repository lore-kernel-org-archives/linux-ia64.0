From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Fri, 27 Apr 2007 16:18:52 +0000
Subject: Re: Inquiry about brl statement
Message-Id: <ed5aea430704270918l3968ad2bn242bdbbe587b2f2@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704271716.57969.christian.kandeler@hob.de>
In-Reply-To: <200704271716.57969.christian.kandeler@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As I remember it, a taken branch acts as a stop whereas a non-taken
branch doesn't (so if no explicit stop bit is following a branch, then
it must be OK for the entire group to be executed in parallel).  I
suppose it's possible the definition changed or that my (admittedly
bad) memory is playing tricks on me. ;-)

  --david

On 4/27/07, Christian Kandeler <christian.kandeler@hob.de> wrote:
> Hello,
>
> in the definition of the BRL_COND_FSYS_BUBBLE_DOWN macro in
> arch/ia64/kernel/gate.S, shouldn't there be a stop bit after the brl.cond
> instruction? According to the Intel specs, the current definition (which has
> no stop bit) triggers undefined behavior.
>
>
> Regards,
> Christian Kandeler
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
