From: "Andrew Vasquez" <andrew.vasquez@qlogic.com>
Date: Mon, 24 Nov 2003 16:54:13 +0000
Subject: RE: qla2xxxx driver for IA64
Message-Id: <marc-linux-ia64-106969377710201@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926349321842@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926349321842@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All,

> <evan.felix@pnl.gov> said:
> 
>   Evan> the IA64 ioctl.h file did not hav the _IOXX_BAD macros, and i
>   Evan> added them, i'm not sure how safe that was, but it compiled.
> 

The cooresponding callers of the IOCTLs have not had the changes added 
to support the 8.x driver -- you should be ok for now.

> Last time I checked, the _IOXX_BAD macros were not used anywhere in
> the standard kernel and that's why I leaned against including them
> (they seemed like a very temporary thing to me).  Perhaps the driver
> could be fixed instead to not use the bad macros?
>

Yes, the next driver drop will have the _BAD() macros usage addressed.


Thanks,
Andrew Vasquez
