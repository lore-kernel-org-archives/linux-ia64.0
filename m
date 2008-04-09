From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 09 Apr 2008 23:01:17 +0000
Subject: Re: [PATCH 1/2] ia64 kdump: add kdump_on_fatal_mca
Message-Id: <200804091701.17749.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FAF533.8010707@jp.fujitsu.com>
In-Reply-To: <47FAF533.8010707@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 08 April 2008 12:54:13 pm Luck, Tony wrote:
> > As an alternative, could kdump_on_fatal_mca be turned on by 
> > default in Altix (in the Altix specific boot code)?  Then
> > we could set our default without impacting other vendors.
> 
> This is a sysctl variable ... are there any cases where we
> set these to different default values for different platforms?
> 
> It would seem better for the kernel to set the default value
> to the most useful one, and for system owners that don't want
> the default behaviour to just add an entry to /etc/sysctl.conf
> to set their preference.
> 
> I'm not sure how we decide what is the most useful default.
> So far SGI are voting for enabling dumping for MCA, and
> Fujitsu have implicitly voted to disable (as that is what
> Seto-san's patch sets).  Any other opinions?

I'd like dumping on MCA to be enabled by default.
