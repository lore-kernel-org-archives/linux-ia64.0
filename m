From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Mon, 11 Feb 2008 22:24:34 +0000
Subject: Re: [PATCH 0/6] Convert ia64 sys_ptrace() to generic sys_ptrace()
Message-Id: <ed5aea430802111424p1625af5dv8923435fe0d11a42@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1202765984.9594.20.camel@elijah.suse.cz>
In-Reply-To: <1202765984.9594.20.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 2/11/08, Petr Tesarik <ptesarik@suse.cz> wrote:

> the following patch series makes the transition to the generic ptrace
> functions. Not a big deal, but feedback welcome.

Not a big deal?  That's got to be the understatement of the year!  The
patch removes what started out real simple, but has since grown into a
complicated hairball.  While I haven't reviewed the details, assuming
that it works as expected, this a great improvement!

  --david
