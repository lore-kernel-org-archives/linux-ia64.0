From: Owen Taylor <otaylor@redhat.com>
Date: Mon, 31 Jul 2000 23:53:20 +0000
Subject: [Linux-ia64] Re: forwarded message from David Mosberger
Message-Id: <marc-linux-ia64-105590678205257@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tom Tromey forwarded me the following -

David Mosberger <davidm@hpl.hp.com> wrote:

> It's sad that GTK/Glib is propagating this poor programming habit.

The assumption we we make is not that the size of ints and pointers
are the same, but simply that it is possible to store small (< 32 bit)
integers in a pointer variable.

While this assumption is not ANSI compliant, and I wouldn't defend it
on theoretical grounds, in practice it is very portable across the
platforms we care about, convenient, and efficient.

The two grounds on which it might be attacked as a poor programming
habit would be lack of portability or lack of readability. It's stood
up well in porting GTK+ to a large number of platforms, and
readability, especially with the cast macros discussed below, is not
worse than the alternatives.

It is a bit kludgy, and I'd never use such a thing without looking for
a better way of structuring the code. I think the same could be said
about most other experienced GTK+ programmers. But it is a nice tool
to have around at times.

> The clean solution is to use a union type such as:
> 
> 	typedef union {
> 		void *v;
> 		long l;
> 		int i;
> 		char c;
> 		float f;
p> 		double d;
> 		...other types you might like...;
> 	} any_type_t;
> 
> and then you can assign to a variable of type "any_type_t" without any
> ugly casts.  It also makes it much clearer what the intended use of
> the argument in question is.  If you don't like the additional
> any_type_t variables you need to declare in return, you can avoid even
> that by introducing cpp macros of the form:
> 
> 	#define int_to_any_type(i)	({any_type_t a; a.i = i;})
> 	#define long_to_any_type(i)	({any_type_t a; a.l = l;})

These are GCC specific. To be portable, you'd have to define 
(possibly inline) functions instead of macros.

 	etc.
> 
> Unfortunately, it's unlikely that GTK/Glib will be fixed soon in this
> respect, so in the meantime, just use the cast "(void *)(long) i" if
> "i" is an integer.

Simply using a cast like this is a bad idea, since it will break
on platforms where sizeof(long) != sizeof(ptr), such as IRIX
with some compilation options.

Instead, if you are doing programming using GLib, you should convert
using:

   GINT_TO_POINTER (i), GUINT_TO_POINTER (i)
   GPOINTER_TO_INT (p), GPOINTER_TO_UINT (p)

Which are autoconf'ed to be correct for the platform in use. 

Regards,
                                        Owen


