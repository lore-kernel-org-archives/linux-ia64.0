From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 31 Jul 2000 23:21:21 +0000
Subject: Re: [Linux-ia64] integer -> pointer question
Message-Id: <marc-linux-ia64-105590678205256@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 31 Jul 2000 15:22:09 -0700 (PDT), Michael Madore <mmadore@turbolinux.com> said:

  Michael> Hi, When porting packages to IA64, it is very common to
  Michael> come across code where integers are being assigned to
  Michael> pointers.  This results in warning messages from the
  Michael> compiler about assigning integers to pointers of a
  Michael> different size.

  Michael> This is very helpful in the case where a function prototype
  Michael> has been omitted, or the programmer has simply made bad
  Michael> assumptions about the sizes of pointers and integers.

  Michael> On the other hand, it is not unusual to see void pointers
  Michael> used for storing integers, and the programmer has no
  Michael> intention of ever de-referencing the pointer.  Glib and
  Michael> GTK+ make extensive use of this technique.

It's sad that GTK/Glib is propagating this poor programming habit.
The clean solution is to use a union type such as:

	typedef union {
		void *v;
		long l;
		int i;
		char c;
		float f;
		double d;
		...other types you might like...;
	} any_type_t;

and then you can assign to a variable of type "any_type_t" without any
ugly casts.  It also makes it much clearer what the intended use of
the argument in question is.  If you don't like the additional
any_type_t variables you need to declare in return, you can avoid even
that by introducing cpp macros of the form:

	#define int_to_any_type(i)	({any_type_t a; a.i = i;})
	#define long_to_any_type(i)	({any_type_t a; a.l = l;})
	etc.

Unfortunately, it's unlikely that GTK/Glib will be fixed soon in this
respect, so in the meantime, just use the cast "(void *)(long) i" if
"i" is an integer.

	--david


