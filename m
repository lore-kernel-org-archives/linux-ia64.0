From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 27 Sep 2001 17:38:34 +0000
Subject: Re: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805269@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805251@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805251@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Sep 2001 09:31:25 +0200 (CEST), stefan <stefan@lkcc.org> said:

  stefan> Some more details about the pseudo code:

  stefan> [snip]

  stefan> Does this explain it better ?

Yes, I understand now what you're trying to do.

  stefan> I guess I can't just read r9 for the above purpose ?

I suppose you could.  Since the solution will be platform-dependent no
matter how you slice it, you might just as well rely on the ia64 linux
specific behavior of getcontext().  Below is a code fragment that shows
how swapcontext() can be implemented on ia64 linux.  You can use the
same approach for your case.

	--david

struct rv
  {
    long retval;
    long first_return;
  };

int
swapcontext (ucontext_t *oucp, const ucontext_t *ucp)
{
  struct rv rv = getcontext (oucp);
  if (rv.first_return)
    setcontext (ucp);
  return 0;
}

