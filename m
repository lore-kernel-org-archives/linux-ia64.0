From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Fri, 25 Feb 2005 20:47:56 +0000
Subject: RE: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <01EF044AAEE12F4BAAD955CB7506494303134254@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ashok Raj <mailto:ashok.raj@intel.com> wrote on Friday, February 25,
2005 12:27 PM:

> On Fri, Feb 25, 2005 at 12:12:34PM -0800, Seth, Rohit wrote:
>> 
>>    Will following work:
>> 
>>    Physical id: Identifying the unique physical package id for LEU
> 
> The spec states that physical processor id or (die id) is not required
> to be unique.  Are you depending on this being unique?
> 

SAL_PHYSICAL_ID_INFO (in conjunction with PAL_LOGICAL_TO_PHYSICAL) is
guranteed to give unique values for each package in a system.

> also PAL_LOGICAL_TO_PHYSICAL states that num_log (or total number of
> logical processors in this die) doesnt necessarily need to be cpp *
> tpc) 
>

Siblings will be equal to num_log.
 
> just fyi: even if the numbers might be the same in most cases, its
> possible 
> that they could be different, because one thread didnt boot due to
> some 
> failure)
> 

