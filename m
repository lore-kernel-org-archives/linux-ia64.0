From: "Alberto Munoz" <amunoz@vmware.com>
Date: Wed, 05 Nov 2003 17:37:51 +0000
Subject: RE: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106805441113849@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



> -----Original Message-----
> From: Matthew Wilcox [mailto:willy@debian.org]
> Sent: Wednesday, November 05, 2003 9:31 AM
> To: Alberto Munoz
> Cc: Luck, Tony; Jack Steiner; Matthias Fouquet-Lapar; Russ Anderson;
> linux-ia64@vger.kernel.org
> Subject: Re: [RFC] Better MCA recovery on IPF
> 
> 
> On Wed, Nov 05, 2003 at 09:14:08AM -0800, Alberto Munoz wrote:
> > What implementation of the Itanium processor supports 
> avoiding MCAs from
> > lfetch or code fetch operations? I don't think Itanium 1 or 
> 2 do this. How
> > about Madison?
> 
> Oops, misunderstanding here.  Madison and Deerfield are also 
> Itanium 2.
> It's like Coppermine and Tualatin are both Pentium 3.  When 
> the difference
> is only cache size, die size, clock frequency and so on, they're not
> going to change the number.  For bigger changes, they might ;-)

Not really a misunderstanding. I just got a little lose with the names. I
should have said Merced, McKinley instead of Itanium 1 and 2.

In any case, it has been my experience that some times there are fairly major
changes in RAS features (typically addressing shortcomings of a predecessor)
betweens processors of the same vintage (McKinley, Madison and Deerfield).

Bert Munoz
> -- 
> "It's not Hollywood.  War is real, war is primarily not about 
> defeat or
> victory, it is about death.  I've seen thousands and 
> thousands of dead bodies.
> Do you think I want to have an academic debate on this 
> subject?" -- Robert Fisk
> 
> 


