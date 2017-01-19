From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 19 Jan 2017 11:04:08 +0000
Subject: Re: [PATCH v4 4/6] tools: expand export.h with VMLINUX_SYMBOL()
Message-Id: <20170119110408.GE28024@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109150249.11667-1-mcgrof@kernel.org>
 <20170115211215.17216-1-mcgrof@kernel.org>
 <20170115211215.17216-5-mcgrof@kernel.org>
In-Reply-To: <20170115211215.17216-5-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: bp@alien8.de, bp@suse.de, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org

On Sun, Jan 15, 2017 at 01:12:13PM -0800, Luis R. Rodriguez wrote:
> This will be used later by the linker-table userspace sandbox.
> 
> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
> ---
>  tools/include/linux/export.h | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/tools/include/linux/export.h b/tools/include/linux/export.h
> index d07e586b9ba0..cb7d6b490e08 100644
> --- a/tools/include/linux/export.h
> +++ b/tools/include/linux/export.h
> @@ -1,6 +1,28 @@
>  #ifndef _TOOLS_LINUX_EXPORT_H_
>  #define _TOOLS_LINUX_EXPORT_H_
>  
> +/*
> + * Export symbols from the kernel to modules.  Forked from module.h
> + * to reduce the amount of pointless cruft we feed to gcc when only
> + * exporting a simple symbol or two.

You copied it, yet did not remove it from the original?

> + *
> + * Try not to add #includes here.  It slows compilation and makes kernel
> + * hackers place grumpy comments in header files.

Define "slows" please.  I doubt it is measurable, and so, why even
mention it here?

thanks,

greg k-h
