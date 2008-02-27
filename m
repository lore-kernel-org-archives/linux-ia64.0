From: Robin Holt <holt@sgi.com>
Date: Wed, 27 Feb 2008 10:53:32 +0000
Subject: Re: ia64_mca_cpe_int_handler
Message-Id: <20080227105331.GR11391@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47BF02EC.4080102@bull.net>
In-Reply-To: <47BF02EC.4080102@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 27, 2008 at 11:06:31AM +0100, Zoltan Menyhart wrote:
> Russ,
>
> Thank you for your remarks.
>
> I want to add a new mechanism for the MCA/INIT handlers to be able to
> store their logs in a safe way. (No locks, no waiting,...)
> This will be based on the two buffers and the atomic counter for each
> of the MCA/INIT handlers.
>
> And I want to keep the existing mechanism when we are not in MCA/INIT
> handlers' contexts.
>
> Using separate mechanisms, avoids MCA/INIT handlers interfering with
> the interrupts and the polling.
>
> Should we receive too many CPEIs / CMCIs, chaining into polling,
> may make us lose events.
>
> Should we receive too many recovered MCAs or INITs, there will
> always be some logs lost. I want to keep the first and the last log.
> The first one to know how it begins.
> Why the last one? I've got a _feeling_ that the last one will have
> accumulated consequences (whatever it is) of the preceding ones.

Is this records per cpu or records total?

In my experience, the first and last are somewhat random.  Often, when
we have received multiple MCA's due to an event, the telling record is
in the middle of the heap and not easily determined without some
experience with that type of event group.  Is there any reasonable way
to keep all the records or at least a larger group than just two.

Russ, do you know what the max number of MCA/INIT records we would
expect to see during a worst-case type event?

Thanks,
Robin
