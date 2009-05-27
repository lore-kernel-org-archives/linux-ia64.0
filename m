From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 27 May 2009 07:46:11 +0000
Subject: Re: [Patch 4/4] module: trim exception table in module_free()
Message-Id: <4A1CEFC3.2010309@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090526083717.5050.32719.sendpatchset@localhost.localdomain> <200905271151.28045.rusty@rustcorp.com.au> <4A1CAF44.7000002@redhat.com> <200905271453.51914.rusty@rustcorp.com.au>
In-Reply-To: <200905271453.51914.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, jdike@addtoit.com, mingo@elte.hu, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org

Rusty Russell wrote:
> __ex_table ends up with two entries:
>
> Contents of section __ex_table:
>  0000 0c000000 00000000 0e000000 00000000  ................
>  0010 10000000 0a000000 12000000 0a000000  ................
>
> The first is for the __put_user in .text (extable_not_init()) and the second is 
> for the one in .init.text (init()).
>
> Depending on how the module gets allocated, the one referring to .init.text 
> may be first or last.
>   

Hmm, how about the following? :-)

struct exception_table_entry *p = mod->extable;

for (;p <= mod->extable+mod->num_exentries; p++ )
         if (with_in_module_init(p->insn, mod))
                   trim_it(p);



