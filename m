From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 05 Dec 2000 22:18:21 +0000
Subject: Re: [Linux-ia64] missing exports of __strlen_user(), __strncpy_from_user()?
Message-Id: <marc-linux-ia64-105590678205791@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205789@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205789@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

__copy_user and __do_clear_user were already in the current kernel
sources but I added the other three now.

Thanks,

	--david

>>>>> On Tue, 5 Dec 2000 17:04:06 -0500 (EST), John Kohl <jtk@rational.com> said:

  John> i386 kernels export strnlen_user() and strncpy_from_user();
  John> the former is referenced by the macro for strlen_user().

  John> ia64 does not export either __strlen_user() or
  John> __strncpy_from_user() (referenced by strlen_user() and
  John> strncpy_from_user() macros functions).  We need these symbols
  John> to implement some code in our kernel module (ClearCase MVFS).

  John> I presume this is just an oversight, and they should be added
  John> to arch/ia64/kernel/ia64_ksyms.c?  I'd suggest adding these,
  John> as similar to exported symbols in i386, to make
  John> copy_{from,to}_user(), strncpy_from_user(), and clear_user()
  John> usable by modules.

  John> EXPORT_SYMBOL(__strncpy_from_user);
  John> EXPORT_SYMBOL(__do_clear_user); EXPORT_SYMBOL(__strlen_user);
  John> EXPORT_SYMBOL(__strnlen_user); EXPORT_SYMBOL(__copy_user);


  John> -- =John Kohl <jtk@rational.com>, Software Engineer Rational
  John> Software, Configuration Management Business Unit Mark your
  John> calendars!  Rational User Conference 2001, July 22-26, 2001 in
  John> beautiful Denver, Colorado

  John> _______________________________________________ Linux-IA64
  John> mailing list Linux-IA64@linuxia64.org
  John> http://lists.linuxia64.org/lists/listinfo/linux-ia64

