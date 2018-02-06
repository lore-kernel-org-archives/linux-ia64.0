From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 06 Feb 2018 09:38:03 +0000
Subject: Re: [PATCH 00/14] Add Kconfig unit tests
Message-Id: <20180206093803.GC31558@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1517877294-4826-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1517877294-4826-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kbuild@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, "Luis R . Rodriguez" <mcgrof@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Ulf Magnusson <ulfalizer@gmail.com>, Sam Ravnborg <sam@ravnborg.org>, Michal Marek <michal.lkml@markovi.net>, Linus Torvalds <torvalds@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@suse.de>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Heinrich Schuchardt <xypron.glpk@gmx.de>, Yaakov Selkowitz <yselkowi@redhat.com>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Marc Herbert <marc.herbert@intel.com>

On Tue, Feb 06, 2018 at 09:34:40AM +0900, Masahiro Yamada wrote:
> I am applying various patches to Kconfig these days.
> 
> However, I fear regressions.  I have been thinking of unit-tests.
> 
> There are various cryptic parts in Kconfig and corner cases where
> it is difficult to notice breakage.  If unit-tests cover those,
> I will be able to apply changes more confidently.
> 
> So, here is the trial.
> 
> After fixing some problems, I will add a basic test framework.
> This is based on pytest.  Also, this is written in Python 3.
> Python 2 will return in 2020.  So, I believe new python tools should be
> written in Python 3.
> 
> This is my Python 3 and pytest versions.
> 
> $ python3 --version
> Python 3.5.2
> $ python3 -m pytest --version
> This is pytest version 3.4.0, imported from /home/masahiro/.local/lib/python3.5/site-packages/pytest.py
> 
> If I use old pytest version, some parts did not work as expected.
> If this does not work for you, please consider using newer pytest.
> 
> I will brush up the code more and add more test cases to do a better job.
> Before proceeding more, I'd like to get consensus for this approach.
> If you have an idea for better implementation, comments are appreciated.

Personally I think this is great stuff.  I too have never wanted to
touch Kconfig stuff due to the complexity, and having unit tests like
this is a great idea to help ensure that things do not break.

Your first 5 patches should be queued up for the next merge window, no
problem (see my comments on the 6th).  As for the rest, I don't have any
objection to them, and using python3 over python2 is a good idea.  And
anyone who wants to do Kconfig work can easily install the needed
packages, it's not required by any "normal" kernel developer.

Anyway, nice job, it's great to see this happening, no objection from me
at all!

greg k-h
