From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 09 Sep 2002 22:54:28 +0000
Subject: Re: [Linux-ia64] [trivial] Request for merging of two sets of redundant SGI IA64 Configure.help text
Message-Id: <marc-linux-ia64-105590701906018@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906017@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906017@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You can just go ahead and delete the second version of each of the
options if you'd like.

Thanks,
Jesse

On Mon, Sep 09, 2002 at 04:01:21PM -0600, Steven Cole wrote:
> Greetings,
> 
> Could one of you help resolve the following very trivial problem.  In
> 2.4.20-pre5 Documentation/Configure.help, there exists two
> Configure.help entries for CONFIG_IA64_SGI_SN_SIM and
> CONFIG_IA64_SGI_SN_DEBUG.
> 
> The configurators will of course only display the first of the two.
> Would someone please indicate which of the texts is the more accurate or
> combine them as you see fit.  You can send me the results or make up a
> patch yourself.
> 
> If this is a moot point, deleting the second text would be the default
> thing to do.
> 
> Thanks,
> Steven
> (Configure.help maintainer)
> 
> 1st text for CONFIG_IA64_SGI_SN_SIM:
> 
> CONFIG_IA64_SGI_SN_SIM
>   Build a kernel that runs on both the SGI simulator AND on hardware.
>   There is a very slight performance penalty on hardware for including this
>   option.
> 
> 2nd text for CONFIG_IA64_SGI_SN_SIM:
> 
> Enable SGI Medusa Simulator Support
> CONFIG_IA64_SGI_SN_SIM
>   If you are compiling a kernel that will run under SGI's IA64
>   simulator (Medusa) then say Y, otherwise say N.
> 
> --------------------------------------------------------------------------
> 
> 1st text for CONFIG_IA64_SGI_SN_DEBUG:
> 
> CONFIG_IA64_SGI_SN_DEBUG
>   This enables addition debug code that helps isolate
>   platform/kernel bugs. There is a small but measurable performance
>   degradation when this option is enabled.
> 
> 2nd text for CONFIG_IA64_SGI_SN_DEBUG:
> 
> Enable SGI SN extra debugging code
> CONFIG_IA64_SGI_SN_DEBUG
>   Turns on extra debugging code in the SGI SN (Scalable NUMA) platform
>   for IA64.  Unless you are debugging problems on an SGI SN IA64 box,
>   say N.
> 
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

