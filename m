From: "MONTGOMERY,BOB (HP-FtCollins,ex1)" <bob.montgomery@hp.com>
Date: Sat, 25 Jan 2003 01:06:35 +0000
Subject: RE: [Linux-ia64] Problem with call across kernel modules
Message-Id: <marc-linux-ia64-105590709805749@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805718@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805718@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I wrote last week:

> The Makefile makes two modules: caller.o and helper.o.  The 
> caller module
> calls the function helper from its init_module routine.  The helper
> function is in the helper module.
...  
 
> If you insmod caller.o first, it will fail with an unresolved symbol
> for helper, as expected.
> 
> After insmod'ing helper, the insmod of caller is expected to succeed,
> but the call to helper from init_module causes an Oops.  The oops
> message seems to indicate that the procedure call to helper lands at
> the wrong address.  The ISR 4294967296 (or 0x1 0000 0000) indicates
> the x bit (Execute exception - Interruption is associated with an
> instruction fetch).

After some more looking:

The problem is that the symbol exported by default for the helper
function (as visible from /proc/ksyms) is the address of the
function's entry point, and not the address of a function descriptor.

So when insmod connects the second module to it, the call stub code
that thinks it's loading the function address and the gp value is
really loading the first two words of the code of the function itself.
These work really badly as a function address and a gp value and show
up in the oops message as bizarre values for IP and r1.

One solution:
EXPORT_SYMBOL(helper) 
and add -DEXPORT_SYMTAB to the makefile.

If you don't use EXPORT_SYMBOL, but rely on the default "export
everything", even -DEXPORT_SYMTAB doesn't seem to help.  The symbol
that gets exported will be wrong as described above.

So it looks like the question has become: Why does the default exported
symbol from an insmod'd module not correctly point to a function
descriptor as required on IA64?  Or, if it isn't right, why make
it visible?

Hopefully this is getting closer to the real problem.

Bob Montgomery, HP




