From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Thu, 22 Dec 2016 14:08:22 +0000
Subject: Re: [PATCH v5 09/14] jump_label: port __jump_table to linker tables
Message-Id: <1482415702.9552.125.camel@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
 <20161222023811.21246-1-mcgrof@kernel.org>
 <20161222023811.21246-10-mcgrof@kernel.org>
In-Reply-To: <20161222023811.21246-10-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, wangnan0@huawei.com, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, joro@8bytes.org, x86@kernel.org, fontana@sharpeleven.org, dsahern@gmail.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux@roeck-us.net, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org

On Wed, 2016-12-21 at 18:38 -0800, Luis R. Rodriguez wrote:
> Move the __jump_table from the a custom section solution
> to a generic solution, this avoiding extra vmlinux.lds.h
> customizations.
> 
> This also demos the use of the .data linker table and of
> the shared asm call push_section_tbl().
> 

>  {
>  	asm_volatile_goto("1:\n\t"
>  		 WASM(nop) "\n\t"
> -		 ".pushsection __jump_table,  \"aw\"\n\t"
> +		 push_section_tbl_any(.data, __jump_table, aw)
>  		 ".word 1b, %l[l_yes], %c0\n\t"
>  		 ".popsection\n\t"
>  		 : :  "i" (&((char *)key)[branch]) :  : l_yes);
> @@ -26,7 +28,7 @@ static __always_inline bool
> arch_static_branch_jump(struct static_key *key, bool
>  {
>  	asm_volatile_goto("1:\n\t"
>  		 WASM(b) " %l[l_yes]\n\t"
> -		 ".pushsection __jump_table,  \"aw\"\n\t"
> +		 push_section_tbl_any(.data, __jump_table, aw)
>  		 ".word 1b, %l[l_yes], %c0\n\t"
>  		 ".popsection\n\t"

Does it make sense to introduce something like

#define pop_section_tbl ".popsection\n\t"
#define pop_section_tbl_any pop_section_tbl

?

-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
