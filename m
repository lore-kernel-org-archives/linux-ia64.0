From: Aaron Young <ayoung@google.engr.sgi.com>
Date: Tue, 27 Jun 2006 22:09:16 +0000
Subject: Re: [PATCH] fix prom revision checks in SN kernel
Message-Id: <200606272209.PAA86361@google.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606271946.MAA19328@google.engr.sgi.com>
In-Reply-To: <200606271946.MAA19328@google.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> > Yeah, I didn't go for any clean up. We *shouldn't* be adding
> > any more explicit prom rev. checks to the code because we
> > now have an interface to check for prom "features" - see
> > sn_prom_feature_available().
> 
> Recollections of that in the hind-brain prompted me to think
> that there should be a better way.
> 
> > Unfortunately these checks were added before the interface
> > was available and therefore the checks have to stay.
> 
> Makes sense.
> 
> > I can still do some clean up if preferred.
> 
> No, 3-places doesn't really justify invention of a generic
> method ... and since you've already got a better method that
> will prevent this from spreading elsewhere, I'll take it
> as-is.
> 

 Tony, hold up. I was just informed there is a patch in-play which
 will conflict with this one:

http://marc.theaimsgroup.com/?l=linux-ia64&m3944733900687&w=2

 It removes the prom rev. check from
 drivers/pci/hotplug/sgi_hotplug.c replacing it with
 a sn_prom_feature_available() call. It's obviously
 the preferrable code.

 Should I resubmit without a change to drivers/pci/hotplug/sgi_hotplug.c?

 Thanks,

 -Aaron
