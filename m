From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 12 Mar 2004 06:01:07 +0000
Subject: Re: 2.6.3 compilation problem
Message-Id: <5784.1079071267@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
In-Reply-To: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 11 Mar 2004 21:42:04 -0800, 
"H. J. Lu" <hjl@lucon.org> wrote:
>which means it will be discarded if the driver is builtin. If
>xxx_remove may be discarded, please make sure there is
>
>#ifdef MODULE
>	remove:	       xxx_remove,
>#endif
>
>so that xxx_remove won't be included when the driver is builtin.

	remove:		__devexit_p(xxx_remove),

is the correct method.  The pointer is required for CONFIG_MODULE
_or_ CONFIG_HOTPLUG, otherwise it must be set to NULL.  __devexit_p()
does all that.

