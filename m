From: Len Brown <len.brown@intel.com>
Date: Tue, 21 Dec 2004 02:46:03 +0000
Subject: Re: Need interactive ACPI interpreter
Message-Id: <1103597163.11833.3735.camel@d845pe>
List-Id: <linux-ia64.vger.kernel.org>
References: <41C07FBD.90108@qwest.net>
In-Reply-To: <41C07FBD.90108@qwest.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "John S. Worley" <jsworley@qwest.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 2004-12-15 at 13:17, John S. Worley wrote:
> Hi all -
> 
>      I am looking for a user-mode, interactive ACPI
> interpreter under Linux. Specifically, I need to be able
> to load arbitrary ACPI file(s) (AML or ASL) and then execute
> the methods and see the results. If it can read from
> /proc as well, so much the better.

The ACPI interpreter that we use in the Linux kernel
is also available as a standalone acpiexec program here:

http://www.intel.com/technology/IAPC/acpi/downloads.htm

cheers,
-Len


