From: Masahiro Yamada <masahiroy@kernel.org>
Date: Mon, 01 Feb 2021 20:58:51 +0000
Subject: Re: [PATCH] kbuild: remove PYTHON variable
Message-Id: <CAK7LNAQQ=kqhx6REix7j+ZndABjuCBEwp=yiQp71Z0fBrQZxog@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210201010024.654526-1-masahiroy@kernel.org> <87r1lzvj3q.fsf@meer.lwn.net>
In-Reply-To: <87r1lzvj3q.fsf@meer.lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jonathan Corbet <corbet@lwn.net>
Cc: Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Michal Marek <michal.lkml@markovi.net>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 2, 2021 at 1:38 AM Jonathan Corbet <corbet@lwn.net> wrote:
>
> Masahiro Yamada <masahiroy@kernel.org> writes:
>
> > Python retired in 2020, and some distributions do not provide the
> > 'python' command any more.
> >
> > As in commit 51839e29cb59 ("scripts: switch explicitly to Python 3"),
> > we need to use more specific 'python3' to invoke scripts even if they
> > are written in a way compatible with both Python 2 and 3.
> >
> > This commit removes the variable 'PYTHON', and switches the existing
> > users to 'PYTHON3'.
> >
> > BTW, PEP 394 (https://www.python.org/dev/peps/pep-0394/) is a helpful
> > material.
> >
> > Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
>
> So this will have the effect of making the docs build impossible for
> folks who only have Python 2.


Is this a problem?  Python 2 is EOL.

Everybody who wants to use Python
must install Python 3.


Rather, people are screaming
that the 'python' command does not exist.




>  As I said before, this is a step that we
> knew was coming, we just hadn't decided on the exact timing - I guess
> this decides for us :)
>
> That said, I'll copy linux-doc to see if anybody screams.  I assume this
> is a 5.12 change?


No, I am planning to do this for 5.11
(a pull request this week if there is no objection).








> Thanks,
>
> jon
>


-- 
Best Regards
Masahiro Yamada
