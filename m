From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Fri, 25 Feb 2005 20:12:34 +0000
Subject: RE: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <01EF044AAEE12F4BAAD955CB7506494303134201@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <mailto:davidm@napali.hpl.hp.com> wrote on Thursday,
February 24, 2005 10:12 PM:

>>>>>> On Thu, 24 Feb 2005 18:22:44 -0800, "Seth, Rohit"
>>>>>> <rohit.seth@intel.com> said: 

>   Rohit> I think we should have some consistency (wherever possible)
>   Rohit> in /proc/cpuinfo fields across architectures.  This will help
>   Rohit> applications writers.  Currently siblings and cpu core fields
>   Rohit> are already added for i386 and x86_64.
> 
> Hmmh, I don't see a "cpu core id" field in the x86 code.  Am I missing
> something?
> 

"Cpu Cores" identifying the number of cores in a physical package is
present in x86_64 and not there in i386 tree.  

Will following work:

Physical id: Identifying the unique physical package id for LEU
Core id: Identifying the unique core id on that specific physical
package
Siblings: Identifying the total number LEUs on that physical package.

Siblings is the one that apps have already started using on i386.

-rohit
