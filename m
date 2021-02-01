From: Jonathan Corbet <corbet@lwn.net>
Date: Mon, 01 Feb 2021 21:21:48 +0000
Subject: Re: [PATCH] kbuild: remove PYTHON variable
Message-Id: <87czxjv5zn.fsf@meer.lwn.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210201010024.654526-1-masahiroy@kernel.org>
 <87r1lzvj3q.fsf@meer.lwn.net>
 <CAK7LNAQQ=kqhx6REix7j+ZndABjuCBEwp=yiQp71Z0fBrQZxog@mail.gmail.com>
In-Reply-To: <CAK7LNAQQ=kqhx6REix7j+ZndABjuCBEwp=yiQp71Z0fBrQZxog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>
Cc: Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Michal Marek <michal.lkml@markovi.net>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Masahiro Yamada <masahiroy@kernel.org> writes:

> On Tue, Feb 2, 2021 at 1:38 AM Jonathan Corbet <corbet@lwn.net> wrote:
>> So this will have the effect of making the docs build impossible for
>> folks who only have Python 2.
>
> Is this a problem?  Python 2 is EOL.
>
> Everybody who wants to use Python
> must install Python 3.

I honestly don't know, but people do keep things around for a
surprisingly long time.

>>  As I said before, this is a step that we
>> knew was coming, we just hadn't decided on the exact timing - I guess
>> this decides for us :)
>>
>> That said, I'll copy linux-doc to see if anybody screams.  I assume this
>> is a 5.12 change?
>
> No, I am planning to do this for 5.11
> (a pull request this week if there is no objection).

I'm not going to truly object and try to block this, but I worry that
it's soon and without warning.  It's not a change I would merge for
-rc7.  IMO this should be done in 5.12 with an appropriate note added to
Documentation/process/changes.rst as well.

Thanks,

jon
