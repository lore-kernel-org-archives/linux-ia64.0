From: Sam Ravnborg <sam@ravnborg.org>
Date: Sun, 18 Feb 2018 19:38:49 +0000
Subject: Re: [PATCH 00/14] Add Kconfig unit tests
Message-Id: <20180218193849.GA29324@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1517877294-4826-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1517877294-4826-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kbuild@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, "Luis R . Rodriguez" <mcgrof@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Ulf Magnusson <ulfalizer@gmail.com>, Michal Marek <michal.lkml@markovi.net>, Linus Torvalds <torvalds@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@suse.de>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Heinrich Schuchardt <xypron.glpk@gmx.de>, Yaakov Selkowitz <yselkowi@redhat.com>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Marc Herbert <marc.herbert@intel.com>

Hi Masahiro.

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
...

Great to see this done.
And +1 for basing this on a standard framework rather than inventing your own.

> If you have an idea for better implementation, comments are appreciated.
Nope, please continue with pytest.

	Sam
