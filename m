From: Jack Steiner <steiner@sgi.com>
Date: Fri, 15 Aug 2003 01:28:20 +0000
Subject: Re: Discontig patch for 2.4.21
Message-Id: <marc-linux-ia64-106091102022869@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106073158319638@msgid-missing>
In-Reply-To: <marc-linux-ia64-106073158319638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> I applied this patch for 2.4.  There were a couple conflicts (for
> instance, some of the non-ia64 ACPI stuff is already in 2.4), so I
> wouldn't be too surprised if I messed something up, so please
> look things over.
> 
> Bjorn
> 

FYI

I am still testing the patch. I have been able to compile ok & am part
way thru early boot on the SGI platform. So far, I have not run into any 
patch-related problems.

The failures that I am slowly working thru are related to missing code that
is needed for the SGI platform but (yuck) has not been submitted yet.

I'll try to get the rest of the SGI code submitted as soon as I get thru boot.


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

