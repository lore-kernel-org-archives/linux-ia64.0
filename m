From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Dec 2005 17:03:46 +0000
Subject: RE: SAL calling conventions + locking
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F052A3FAB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4399B3EE.6050408@bull.net>
In-Reply-To: <4399B3EE.6050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Can someone please tell me:
>- why the spec. requires to call the SAL with interrupts enabled,
>- why Linux calls the SAL with interrupts disabled,
>- what happens if the SAL is called with interrupts disabled?

A quick scan of the SAL spec didn't come up with text to match
that comment.  On the contrary in chapter 8 on calling conventions
table 8-2 on requirements for PSR says that the "i" bit is preserved
across SAL calls (with a footnote "b" remarking that SAL procedures
may not enable interrupts if they are disabled on entry).  This
appears to be very clear that the call can be made either with
interrupts enabled or disabled.

Section 9.1.1 on invoking runtime services in virtual mode does
say that "the normal operating system environment is with translation
on and interrupts enabled but operating system may choose to call SAL
runtime services in physical mode".  This is perhaps a bit hazy, but
I don't see that this should be interpreted as a requirement that
interrupts be enabled when calling in virtual mode.

The SAL_GET_STATE_INFO only says that it is callable in either virtual
or physical mode.

So I think that the comment is wrong, and the SAL spec does not
require that this be called with interrupts enabled.

-Tony
