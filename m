From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Fri, 25 Feb 2005 02:22:44 +0000
Subject: RE: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <01EF044AAEE12F4BAAD955CB7506494303133CA3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <mailto:davidm@napali.hpl.hp.com> wrote on Thursday,
February 24, 2005 5:27 PM:

>>>>>> On Tue, 22 Feb 2005 10:24:40 -0800, "Seth, Rohit"
>>>>>> <rohit.seth@intel.com> said: 
> 
>   Rohit> I agree that the format of these fields should match the
>   Rohit> format of other fields in cpuinfo.....though it will be nice
>   Rohit> if we have the same format as that of i386 cpuinfo output.
> 
> I'm not sure there is much point to that:
> 
>  (a) The contents of /proc/cpuinfo is by definition
> architecture-specific 
> 

No arguments there.

>  (b) Applications _should_ allow any whitespace when parsing
>      /proc/cpuinfo, so in properly-written applications, it shouldn't
>      matter whether whitespace or tabs are used.
> 
> Changing the formatting of /proc/cpuinfo only runs the risk of
> existing tools, without benefit to properly written applications.
> 

I hope there are not that many apps that have this
behavior...particularly if they are (/want to be) portable.

In any case, I will have this changed (tabs replaced with white space)
in next rev of this patch.

>   Rohit> I was thinking of this information as something that apps can
>   Rohit> use to find the information about which logical execution
>   Rohit> units (leu) are threads on the same core, which leu are on
>   Rohit> the same package and so on.  This is similar to i386(HT
>   Rohit> enabled processors) where siblings gives the number of
>   Rohit> threads on the same package.
> 
> I'm not a fan of including redudant info in /proc files.
> 

I think we should have some consistency (wherever possible) in
/proc/cpuinfo fields across architectures.  This will help applications
writers.  Currently siblings and cpu core fields are already added for
i386 and x86_64.  

Thoughts?


>   Rohit> Typically the field names in various PAL call related data
>   Rohit> structures match their definition in SDM....
> 
> I don't think we need to constrain ourselves too much to what the PAL
> names are.  That code is part of the kernel and it should be readable.
> 

I probably should send you a bigger PAL field cleanup patch first ;-)

