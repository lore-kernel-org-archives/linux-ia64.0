From: Keith Owens <kaos@sgi.com>
Date: Fri, 05 Dec 2003 00:59:02 +0000
Subject: [RFE] Add stacked registers to SAL records (resend)
Message-Id: <marc-linux-ia64-107058596016407@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106870740330038@msgid-missing>
In-Reply-To: <marc-linux-ia64-106870740330038@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Originally sent November 13 with no response, try again.

SAL error records contain most registers in sal_processor_static_info,
but not the stacked registers.  What is the process for adding another
GUID to the SAL specification to contain the stacked registers?

Layout:

  number of stacked registers in this record
  cfm for frame at the time of failure
  stacked registers, ending with the cfm.sof registers

This GUID would be optional, if a particular SAL implementation did not
produce it then that platform would not have stacked registers printed
via salinfo.

