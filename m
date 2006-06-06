From: Chris Wedgwood <cw@f00f.org>
Date: Tue, 06 Jun 2006 04:39:48 +0000
Subject: Re: [RFC 1/2] Xen/ia64 modified files
Message-Id: <20060606043948.GA8338@tuatara.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1149275354.5999.83.camel@lappy>
In-Reply-To: <1149275354.5999.83.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 02, 2006 at 01:09:14PM -0600, Alex Williamson wrote:

> +config XEN
> +	bool "Xen hypervisor support"
> +	default y

	select ARCH_XEN

?

> +	help
> +	  Enable Xen hypervisor support.  Resulting kernel runs
> +	  both as a guest OS on Xen and natively on hardware.
> +
> +config ARCH_XEN
> +	bool
> +	default y

would suffice surely?

that would mean you don't have to see/select this option
