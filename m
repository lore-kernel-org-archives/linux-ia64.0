From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 19 Jan 2017 11:19:15 +0000
Subject: Re: [PATCH v7 06/14] firmware/Makefile: force recompilation if makefile changes
Message-Id: <20170119111915.GL28024@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
 <20170115211057.17167-7-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-7-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: bp@alien8.de, bp@suse.de, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org

On Sun, Jan 15, 2017 at 01:10:49PM -0800, Luis R. Rodriguez wrote:
> If you modify the target asm we currently do not force the
> recompilation of the firmware files. The target asm is in
> the firmware/Makefile, peg this file as a dependency to
> require re-compilation of firmware targets when the asm
> changes.
> 
> v3: introduced in this series
> 
> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
> ---
>  firmware/Makefile | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/firmware/Makefile b/firmware/Makefile
> index e297e1b52636..fa3e81c2a97b 100644
> --- a/firmware/Makefile
> +++ b/firmware/Makefile
> @@ -176,7 +176,8 @@ quiet_cmd_fwbin = MK_FW   $@
>  wordsize_deps := $(wildcard include/config/64bit.h include/config/32bit.h \
>  		include/config/ppc32.h include/config/ppc64.h \
>  		include/config/superh32.h include/config/superh64.h \
> -		include/config/x86_32.h include/config/x86_64.h)
> +		include/config/x86_32.h include/config/x86_64.h \
> +		firmware/Makefile)
>  
>  $(patsubst %,$(obj)/%.gen.S, $(fw-shipped-y)): %: $(wordsize_deps)
>  	$(call cmd,fwbin,$(patsubst %.gen.S,%,$@))

I don't understand why this patch is in this series :(
