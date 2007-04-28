From: "Jim Hull" <jim.hull@hp.com>
Date: Sat, 28 Apr 2007 00:20:02 +0000
Subject: RE: Inquiry about brl statement
Message-Id: <036201c7892a$f87d9540$0b3af40f@americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704271716.57969.christian.kandeler@hob.de>
In-Reply-To: <200704271716.57969.christian.kandeler@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David:

If brl had existed from the beginning, then its stop-bit requirements would
have matched those of regular branches.  However, it was added after Merced
could no longer be changed, and because of where it is encoded, and the
desire to enable an OS to emulate it on Merced, it had to have the
must-always-be-followed-by-a-stop-bit rule.

 -- Jim 

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of David 
> Mosberger-Tang
> Sent: Friday, April 27, 2007 1:01 PM
> To: Luck, Tony
> Cc: Christian Kandeler; linux-ia64@vger.kernel.org
> Subject: Re: Inquiry about brl statement
> 
> Tony,
> 
> I'm sure I missed that point about brl.  I probably just assumed it
> would have the same behavior as regular branches.  Thanks for catching
> that.
> 
>   --david
> 
> On 4/27/07, Luck, Tony <tony.luck@intel.com> wrote:
> > > As I remember it, a taken branch acts as a stop whereas a 
> non-taken
> > > branch doesn't (so if no explicit stop bit is following a 
> branch, then
> > > it must be OK for the entire group to be executed in parallel).  I
> > > suppose it's possible the definition changed or that my 
> (admittedly
> > > bad) memory is playing tricks on me. ;-)
> >
> > The SDM page for "brl" doesn't look to have any get-out-of 
> stop-bits-free
> > option.  It says:
> >
> >  "This instruction must be immediately followed by a stop; otherwise
> >   its behaviour is undefined."
> >
> > -Tony
> >
> 
> 
> -- 
> Mosberger Consulting LLC, http://www.mosberger-consulting.com/
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


