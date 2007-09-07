From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 07 Sep 2007 08:26:56 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <46E10B50.4050302@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Shaohua Li wrote:
> On Thu, 2007-09-06 at 15:59 +0200, Petr Tesarik wrote:
>>[...]
>> So, what happens if upon syscall entry notification the debugger
>> modifies the part of the RBS (in user-space) which corresponds to the
>> arguments of that syscall? Currently, the syscall takes the modified
>> arguments, but with your change it would still take the stale data
>> from
>> the kernel RBS.
> The patch does sync from user RBS to kernel RBS just after syscall trace
> enter. this is an exception I said doing sync just before syscall
> return. I thought this covers your case, no?

Ah, I'm sorry, I missed that part of the patch. Well, if we have to do a
sync on every syscall_trace_enter() and syscall_trace_leave(), then the
only cases where introducing TIF_RESTORE_RSE saves us a duplicate sync
seems to be in the clone/fork and exit paths. In other words, it's
probably not worth the added complexity. But since you have written the
whole complex thing already, I have no objections against it.

Regards,
Petr Tesarik
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFG4QtOjpY2ODFi2ogRArB1AJ0bcewvu+VQvpoQ7NMeloJDK9GDLACgnmVW
qw0ovAkl8PztYwpsru96eXc=eZUo
-----END PGP SIGNATURE-----
