From: "Alberto Munoz" <amunoz@vmware.com>
Date: Mon, 03 Nov 2003 17:51:27 +0000
Subject: RE: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106788207929468@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I was at HP (a good number of years ago, we (HP and Intel) spent a lot
of time trying to architect machine check behavior. Actually all of the
things you guys have been discussing were considered. Because I have not been
following up on this area in many years, I am not sure how much of the work
we did actually made it to official architecture documents, although I do
know that some of it did.

The main idea was that each layer of the machine check handling code will
either be able to transparently (to that layer) recover the error, or pass
the information up to the next layer (this information always included a flag
that would be set if the error was considered non-recoverable by the lower
layer, like for example a tag parity error on a dirty data cache line). The
layers we defined and the order in which they were executed when a machine
check abort occurred were PAL, SAL and the OS. I have seen some of this
information (although I have not checked how complete it is) in chapter 4 of
the SAL spec (Itanium Processor Family System Abstraction layer
Specification) and section 13.3.i of the architecture spec (Intel Itanium
Architecture Software Developers Manual, Volume 2: System Architecture). The
SAL_GET_STATE_INFO call was to be central to getting all this information to
the OS.

Bert Munoz

> -----Original Message-----
> From: Russ Anderson [mailto:rja@sgi.com]
> Sent: Monday, November 03, 2003 9:09 AM
> To: linux-ia64@vger.kernel.org
> Cc: rja@sgi.com
> Subject: Re: [RFC] Better MCA recovery on IPF
> 
> 
> Grant Grundler wrote:
> On Fri, Oct 31, 2003 at 02:09:12PM +0900, Hidetoshi Seto wrote:
> >> In the case of platform premising IPF, I think it is
> >> better to regard the Intel's Chipset as the de facto
> >> standard.
> >
> > hmm...given ia64 intel boxes I've played with have no error 
> containment
> > and softfail on everything, I'm not sure that's a good choice.
> > Or has enough been published about the chipset to change those
> > behaviors?
> 
> There are some errors on ia64 that are recoverable, with the right
> SW (PAL,SAL,Linux) and chipset support.  
> 
> There are some errors on ia64 that are not recoverable, but hopefully
> will be in newer cpu & chipset versions.
> 
> A Matthias points out, some of the recovery should abstracted out 
> in linux to hide the underlying hardware implementation.  
> 
> For example, in the case of an application hitting a memory 
> uncorrectable on a multi-processor system, the MCA will be handled 
> by PAL and SAL.  If SAL can determine the failing HW physical address,
> it could pass that information up to linux.  Linux could look at the
> physical address and figure out which application has that address
> mapped and kill the application, without crashing the system.  Linux
> should also not allow that physical memory to be reused by any other
> process.
> 
> Part of that recovery is platform specific (HW, PAL, SAL) but
> part of it is platform independent (linux converting the physical
> address, shooting the app, page handling).
> 
> As for IPF being "the defacto standard", IPF is certainly the
> platform I'm interested in (hence posting to linux-ia64), but others 
> will have their own preference.  The platform independent parts of 
> linux should have interfaces designed to work on any platform (duh).  
> Actual implementation will likely be done on several different 
> architectures.  
> 
> -- 
> Russ Anderson, OS RAS/Partitioning Project Lead  
> SGI - Silicon Graphics Inc          rja@sgi.com
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


