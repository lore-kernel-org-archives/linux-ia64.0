From: "Wang, Zhenyu Z" <zhenyu.z.wang@intel.com>
Date: Fri, 18 Jun 2004 03:12:36 +0000
Subject: RE: Question on 2xECC status
Message-Id: <6E0C289723A0564F9A8279E236E8565F07A00657@pdsmsx402.pd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <6E0C289723A0564F9A8279E236E8565F07A0057F@pdsmsx402.pd.intel.com>
In-Reply-To: <6E0C289723A0564F9A8279E236E8565F07A0057F@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 
Tony,

Thanks for the answer.

So MCA recovery for uncorrectable memory error is not supported by linux now, right?

I said "report to user space" means linux can retrieve the error and by some way like
proc interface to tell user there is corrected error.

salinfo_decode daemon is doing this job, right?

-zhen
 
-----Original Message-----
From: Luck, Tony 
Sent: 2004年6月18日 11:03
To: Wang, Zhenyu Z; linux-ia64@vger.kernel.org
Subject: RE: Question on 2xECC status

>I have question about current support of 2xECC in linux-ia64.
>Does it support uncorrectable memory errors now?

Uncorrectable memory errors are currently fatal for Linux.
Details of the error will be extracted from the SAL error
log after the system reboots and be reported.

>By correctable memory errors, does it report to user space?

Corrected errors are logged by SAL, Linux retrieves the errors
(either by polling or in response to CMCI/CPEI interrupts
depending on the platform, and the rate at which errors are
being reported).  User programs can examine the error logs to
see what errors occurred.

What do you mean by "report to user space"?  A user program
that is making use of memory that experiences a corrected
error would observe a slight delay in execution, but there
isn't any easy way for the application to see that happened
to it.

-Tony
