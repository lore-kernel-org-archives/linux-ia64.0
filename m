From: John Kohl <jtk@rational.com>
Date: Tue, 05 Dec 2000 22:04:06 +0000
Subject: [Linux-ia64] missing exports of __strlen_user(), __strncpy_from_user()?
Message-Id: <marc-linux-ia64-105590678205789@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

i386 kernels export strnlen_user() and strncpy_from_user(); the former
is referenced by the macro for strlen_user().

ia64 does not export either __strlen_user() or __strncpy_from_user()
(referenced by strlen_user() and strncpy_from_user() macros functions).
We need these symbols to implement some code in our kernel module
(ClearCase MVFS).

I presume this is just an oversight, and they should be added to
arch/ia64/kernel/ia64_ksyms.c?  I'd suggest adding these, as similar to
exported symbols in i386, to make copy_{from,to}_user(),
strncpy_from_user(), and clear_user() usable by modules.

EXPORT_SYMBOL(__strncpy_from_user);
EXPORT_SYMBOL(__do_clear_user);
EXPORT_SYMBOL(__strlen_user);
EXPORT_SYMBOL(__strnlen_user);
EXPORT_SYMBOL(__copy_user);


-- 
=John Kohl <jtk@rational.com>, Software Engineer
Rational Software, Configuration Management Business Unit
Mark your calendars!  Rational User Conference 2001, July 22-26, 2001
in beautiful Denver, Colorado

