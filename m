From: Jonathan Corbet <corbet@lwn.net>
Date: Mon, 01 Feb 2021 16:38:33 +0000
Subject: Re: [PATCH] kbuild: remove PYTHON variable
Message-Id: <87r1lzvj3q.fsf@meer.lwn.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210201010024.654526-1-masahiroy@kernel.org>
In-Reply-To: <20210201010024.654526-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>, linux-kbuild@vger.kernel.org
Cc: linux-doc@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Michal Marek <michal.lkml@markovi.net>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org

Masahiro Yamada <masahiroy@kernel.org> writes:

> Python retired in 2020, and some distributions do not provide the
> 'python' command any more.
>
> As in commit 51839e29cb59 ("scripts: switch explicitly to Python 3"),
> we need to use more specific 'python3' to invoke scripts even if they
> are written in a way compatible with both Python 2 and 3.
>
> This commit removes the variable 'PYTHON', and switches the existing
> users to 'PYTHON3'.
>
> BTW, PEP 394 (https://www.python.org/dev/peps/pep-0394/) is a helpful
> material.
>
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>

So this will have the effect of making the docs build impossible for
folks who only have Python 2.  As I said before, this is a step that we
knew was coming, we just hadn't decided on the exact timing - I guess
this decides for us :)

That said, I'll copy linux-doc to see if anybody screams.  I assume this
is a 5.12 change?

Thanks,

jon
