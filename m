From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 Jun 2004 03:02:48 +0000
Subject: RE: Question on 2xECC status
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01794F95@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <6E0C289723A0564F9A8279E236E8565F07A0057F@pdsmsx402.pd.intel.com>
In-Reply-To: <6E0C289723A0564F9A8279E236E8565F07A0057F@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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
