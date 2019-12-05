From: David Airlie <airlied@redhat.com>
Date: Thu, 05 Dec 2019 19:54:42 +0000
Subject: Re: [PATCH v2 0/5] agp: minor fixes, does the maintainer still there ?
Message-Id: <CAMwc25pgOx+_2NaJb4vb4bf_mvKD8QYfQAbP7TV2tRUa2yWjrw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
 <20191202133254.GA21550@Red> <CAMwc25obOebugXGSNVWd1bjPN+tR82wwFJ6PgqnvZXK4O6xAFw@mail.gmail.com>
 <20191205152945.GB10549@Red>
In-Reply-To: <20191205152945.GB10549@Red>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LABBE Corentin <clabbe@baylibre.com>
Cc: airlied <airlied@linux.ie>, arnd@arndb.de, fenghua.yu@intel.com, "KH, Greg" <gregkh@linuxfoundation.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

> Thanks for applying.
> Perhaps you need to fix your address in MAINTAINERS.
>
> When you has hardware, What was your tests procedure ?
Just boot and run gears type thing.

> I can on my freetime add some AGP hw on my kernelCI lab.
>

I don't know where to get AGP hw these days that isn't horrible power
consumption wise, I can't really wish for anyone to ever put it into
CI for an area that we change once a year.

I'd rather we just don't touch AGP too much and let it die and remove
support in 5-10 years.

Dave.
