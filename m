From: James E Wilson <wilson@tuliptree.org>
Date: Fri, 17 Mar 2006 20:45:44 +0000
Subject: Re: PATCH: Fix gnu-efi-3.0b-041222 for ia32
Message-Id: <1142628344.24881.42.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317202301.GA20807@lucon.org>
In-Reply-To: <20060317202301.GA20807@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-03-17 at 12:23, H. J. Lu wrote:
> -   *(.text)
> +   *(.text*)

That should be .text.*, not .text*.  The distinction here is important.
Admittedly, it will probably never matter for gnu-efi, but get this
wrong in binutils and you will break some end user code.



