From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Wed, 07 Mar 2018 02:22:46 +0000
Subject: Re: [PATCH v2 01/11] kbuild: define PYTHON2 and PYTHON3 variables instead of PYTHON
Message-Id: <CAK7LNARc+4n6B1c0LXigAfffnpUqY3GSVw+rw5PQP9VrOxbOuw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1519965121-12017-1-git-send-email-yamada.masahiro@socionext.com>
 <1519965121-12017-2-git-send-email-yamada.masahiro@socionext.com> <CA+8MBbLjdViZgUYuLT1qDAnxtBP62pCXnvNMbUCjZ=RP8Ok=Dw@mail.gmail.com>
In-Reply-To: <CA+8MBbLjdViZgUYuLT1qDAnxtBP62pCXnvNMbUCjZ=RP8Ok=Dw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: linux-kbuild <linux-kbuild@vger.kernel.org>, Sam Ravnborg <sam@ravnborg.org>, Michal Marek <michal.lkml@markovi.net>, Ulf Magnusson <ulfalizer@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, "Luis R . Rodriguez" <mcgrof@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>

2018-03-07 2:16 GMT+09:00 Tony Luck <tony.luck@intel.com>:
> On Thu, Mar 1, 2018 at 8:31 PM, Masahiro Yamada
> <yamada.masahiro@socionext.com> wrote:
>> arch/ia64/scripts/unwcheck.py is apparently written in Python 2, so
>> it should be invoked by 'python2'.
>
> I pushed the patch from Corentin Labbe to update this script to run with either
> python2 or python3. Linus took it yesterday:
>
> bd5edbe67794 ("ia64: convert unwcheck.py to python3")
>
> -Tony

Thanks for the reminder!

Yeah, I noticed this commit yesterday.
Now, unwcheck.py seems to be compatible
with both Python 2.x and 3.x
(I have not tested it, but I understood so from the
commit log.)

I will keep 'PYTHON' and arch/ia64/Makefile as they are.

I will just add 'PYTHON2' and 'PYTHON3'.




-- 
Best Regards
Masahiro Yamada
