From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Wed, 06 Apr 2005 19:28:15 +0000
Subject: Re: [patch] add MCA recovery on/off switch
Message-Id: <4254384F.8050601@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504060327.j363REMp8976934@clink.americas.sgi.com>
In-Reply-To: <200504060327.j363REMp8976934@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:
> On Tuesday, April 5, 2005 8:32 pm, Randy.Dunlap wrote:
> 
>>Russ Anderson wrote:
>>
>>>Create /proc/sys/kernel/mca_recovery to turn on/off the MCA recovery
>>>code. This allows the recovery code to be enabled or disabled without
>>>having to reboot.
>>
>>Is there also a way to disable MCA recovery on the command line
>>as a boot option?  Using sysctl for it could be too late.
> 
> 
> Yeah, we added the 'nomca' option a while back to disable machine check 
> recovery altogether, but it prevents it from being enabled later on iirc.

Well I searched Documentation/kernel-parameters.txt
and didn't find it there, so please send a patch for that too.  :)

-- 
~Randy
