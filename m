From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 19 Jan 2017 11:20:17 +0000
Subject: Re: [PATCH v7 08/14] jump_label: move guard #endif down where it belongs
Message-Id: <20170119112017.GM28024@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
 <20170115211057.17167-9-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-9-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: bp@alien8.de, bp@suse.de, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org

On Sun, Jan 15, 2017 at 01:10:51PM -0800, Luis R. Rodriguez wrote:
> The ending header guard is misplaced. This has no
> functional change, this is just an eye-sore.
> 
> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
> ---
>  include/linux/jump_label.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/jump_label.h b/include/linux/jump_label.h
> index a0547c571800..b63d6b7b0db0 100644
> --- a/include/linux/jump_label.h
> +++ b/include/linux/jump_label.h
> @@ -402,6 +402,6 @@ extern bool ____wrong_branch_error(void);
>  #define static_branch_enable(x)		static_key_enable(&(x)->key)
>  #define static_branch_disable(x)	static_key_disable(&(x)->key)
>  
> -#endif	/* _LINUX_JUMP_LABEL_H */
> -
>  #endif /* __ASSEMBLY__ */
> +
> +#endif	/* _LINUX_JUMP_LABEL_H */
> -- 
> 2.11.0

Why is this in this patch series?
