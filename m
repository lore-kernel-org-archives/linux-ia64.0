From: Joseph V Moss <jmoss@ichips.intel.com>
Date: Sat, 24 Feb 2001 23:18:38 +0000
Subject: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005199@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Fri, 23 Feb 2001, Jesse Barnes wrote:
> 
> > 
> > This seems like the sort of info that should be in Configure.help.  Anyone
> > interested in posting a patch to add it?
> > 
> 
> As attachment. This is over 2.4.1 + 010131 ia64 patch. I also added help for
> B1/B2 specific stuff. Please verify that it is correct...

You've got a small cut'n'paste error there:
 
> +Enable Itanium B1-step specific code
> +CONFIG_ITANIUM_B1_SPECIFIC
> +  Select this option to bild a kernel for an Itanium prototype system
> +  with a B1-step CPU.  You have a B0-step CPU if the "revision" field in
                                     ^^

> +  /proc/cpuinfo is 2.
> +
> +Enable Itanium B2-step specific code
> +CONFIG_ITANIUM_B2_SPECIFIC
> +  Select this option to bild a kernel for an Itanium prototype system
> +  with a B2-step CPU.  You have a B0-step CPU if the "revision" field in
                                     ^^


> +  /proc/cpuinfo is 3.
> +

