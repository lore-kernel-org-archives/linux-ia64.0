From: Stuart Anderson <anderson@metrolink.com>
Date: Thu, 17 Aug 2000 16:13:33 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205347@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've received some code, and should have hardware soon, so I was planning
on working on it.


On Wed, 16 Aug 2000, Marc Aurele La France wrote:

> On Fri, 11 Aug 2000, Keith Owens wrote:
> 
> > >> I guess my question now is:  Should the dlopen() loader be able to
> > >> resolve inter-module dependencies?  If not, what is left to be done with
> > >> the elf loader make it functional on IA64?
> 
> > >Support for the ELF64 relocation types. Just like a block of code was added
> > >for Alpha support, the same type of thing will have to be added for IA64.
> 
> > modutils 2.3.13 has IA64 relocation support, courtesy of Mike Stephens
> > at Intel.  obj/obj_ia64.c should be a reasonable starting point.
> 
> Is anyone going ahead with this?  If not, I can probably come pretty close
> to getting it working even though I'd be going in blind (no hardware).
> 
> Let me know.
> 
> Marc.
> 
> +----------------------------------+-----------------------------------+
> |  Marc Aurele La France           |  work:   1-780-492-9310           |
> |  Computing and Network Services  |  fax:    1-780-492-1729           |
> |  352 General Services Building   |  email:  tsi@ualberta.ca          |
> |  University of Alberta           +-----------------------------------+
> |  Edmonton, Alberta               |                                   |
> |  T6G 2H1                         |     Standard disclaimers apply    |
> |  CANADA                          |                                   |
> +----------------------------------+-----------------------------------+
> XFree86 Core Team member.  ATI driver and X server internals.
> 


                                Stuart

Stuart R. Anderson                               anderson@metrolink.com

Metro Link Incorporated                          South Carolina Office
5807 North Andrews Way                           129 Secret Cove Drive
Fort Lauderdale, Florida 33309                   Lexington, SC 29072
voice: 954.660.2500                              voice: 803.951.3630
fax:   954.938.1982                              SkyTel: 800.405.3401
http://www.metrolink.com/


