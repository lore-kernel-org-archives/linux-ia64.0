From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 25 Jan 2003 01:32:36 +0000
Subject: Re: [Linux-ia64] Problem with call across kernel modules
Message-Id: <marc-linux-ia64-105590709805750@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805718@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805718@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 24 Jan 2003 20:06:35 -0500, 
"MONTGOMERY,BOB (HP-FtCollins,ex1)" <bob.montgomery@hp.com> wrote:
>So it looks like the question has become: Why does the default exported
>symbol from an insmod'd module not correctly point to a function
>descriptor as required on IA64?  Or, if it isn't right, why make
>it visible?

I had not realised that you were relying on the "export everything by
default" behaviour.  That does not work for ia64 and I don't see any
way of making it work.  As you say, the global symbol for a function
must point to the function descriptor, not the address.  When you
EXPORT_SYMBOL(function_name),

__attribute__((section("__ksymtab"))) =                 \
{ (unsigned long)&sym, __kstrtab_##sym }

uses &function_name so gcc generates the function descriptor in the
modules export table.  However if you rely on default exporting, gcc
has not been told that the function will be exported so there is no
function descriptor to use.  That means there is nothing for insmod to
point to, except the function address.

Bottom line - do not rely on default export behaviour for ia64.

Nobody should rely on this feature anyway, the default export is
compatibility code that dates back to 2.0 kernels, current code should
explicitly export what it needs.  In 2.5 kernels that is exactly what
happens, default exporting is off.

modutils 2.4.23 will issue a big warning for all architectures that
have function descriptors when you load a module that relies on default
export behaviour.  "Functions must be explicitly exported on this
architecture, attempts to use functions in module <foo> will probably
kill your system".


