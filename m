From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 01 Aug 2000 02:20:47 +0000
Subject: Re: [Linux-ia64] Re: forwarded message from David Mosberger
Message-Id: <marc-linux-ia64-105590678205262@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205257@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205257@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Since "inline" isn't really ANSI C either

It is now, though it will be awhile before C9X (C99?) is widespread.

	I never understood
	why GNU C is the only C variant to provide statement
	expressions---it's a critically important feature when translating
	other languages to C, for example).

There is a debate currently on the gcc lists about this.  It turns out that
statement expressions conflict with the C++ language standard, and it isn't
clear if this problem can be solved.  This is a problem for g++ because glibc
uses statement expressions in some header files, and C++ programs that include
those header files may not work.  It isn't clear what is going to happen yet,
but some people are considering eliminating statement expressions.  That
probably won't happen, but eliminating or restricting statement expressions
in C++ probably will happen.

If you want to use C++, then don't use statement expressions.

Jim


