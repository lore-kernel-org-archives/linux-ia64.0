From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Fri, 27 Apr 2007 20:00:53 +0000
Subject: Re: Inquiry about brl statement
Message-Id: <ed5aea430704271300tc55a342v5ee7eec5d67f43@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704271716.57969.christian.kandeler@hob.de>
In-Reply-To: <200704271716.57969.christian.kandeler@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

I'm sure I missed that point about brl.  I probably just assumed it
would have the same behavior as regular branches.  Thanks for catching
that.

  --david

On 4/27/07, Luck, Tony <tony.luck@intel.com> wrote:
> > As I remember it, a taken branch acts as a stop whereas a non-taken
> > branch doesn't (so if no explicit stop bit is following a branch, then
> > it must be OK for the entire group to be executed in parallel).  I
> > suppose it's possible the definition changed or that my (admittedly
> > bad) memory is playing tricks on me. ;-)
>
> The SDM page for "brl" doesn't look to have any get-out-of stop-bits-free
> option.  It says:
>
>  "This instruction must be immediately followed by a stop; otherwise
>   its behaviour is undefined."
>
> -Tony
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
