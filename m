From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 01 Aug 2000 00:03:05 +0000
Subject: Re: [Linux-ia64] Re: forwarded message from David Mosberger
Message-Id: <marc-linux-ia64-105590678205258@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205257@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205257@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 31 Jul 2000 19:53:20 -0400, Owen Taylor <otaylor@redhat.com> said:

  >> #define int_to_any_type(i) ({any_type_t a; a.i = i;})

  Owen> These are GCC specific. To be portable, you'd have to define
  Owen> (possibly inline) functions instead of macros.

That's true.  Since "inline" isn't really ANSI C either, regular
functions would have to be used (slow, but so what; I never understood
why GNU C is the only C variant to provide statement
expressions---it's a critically important feature when translating
other languages to C, for example).

  Owen> Instead, if you are doing programming using GLib, you should
  Owen> convert using:

  Owen>    GINT_TO_POINTER (i), GUINT_TO_POINTER (i) GPOINTER_TO_INT
  Owen> (p), GPOINTER_TO_UINT (p)

  Owen> Which are autoconf'ed to be correct for the platform in use.

Ah, that's fine then.  As long as there is a clean way for source code
to express the conversion, I don't really care how it's implemented.
Sorry for faulting gtk/glib without checking first (it's been too long
since I programmed with this toolkit, so I didn't remember how this
was handled... ;-).

	--david


