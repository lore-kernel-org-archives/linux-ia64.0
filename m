From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 04 Apr 2003 05:04:42 +0000
Subject: Re: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705415@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jes" = Jes Sorensen <jes@wildopensource.com> writes:

Jes> Hi, I have been tracing a problem with tty->count hitting an
Jes> unidenfied state and I am starting to ponder if our current
Jes> spin_unlock() implementation is sufficient.

[snip]

Jes> Consider the following example:

Actually that example isn't valid, this one should be:

cpu1()
{
   spin_lock(&bleh);
   *a = foo;
   spin_unlock(&bleh);
   *b = bar;
}

cpu2()
{
   if (*b = bar)
      boink(*a);
}

Jes

