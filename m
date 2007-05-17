From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Thu, 17 May 2007 14:16:55 +0000
Subject: Re: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <ed5aea430705170716n7c56f130w7a51cef9dadef318@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517111651.GA760@lnx-holt.americas.sgi.com>
In-Reply-To: <20070517111651.GA760@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 5/17/07, Keith Owens <kaos@sgi.com> wrote:

> David Mosberger
> reckons that unwind should never cause an error, maybe we should be
> looking at adding more checks to the unwind code to cope with spurious
> addresses?

That's correct.  If the unwinder causes MCAs, it's broken.  Robin, can
you look into why the memory-access safety-checks in the unwinder
aren't sufficient to avoid the MCAs you're seeing?

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
