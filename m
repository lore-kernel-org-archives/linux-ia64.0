From: Aron Griffis <aron@hp.com>
Date: Tue, 29 Jan 2008 16:31:33 +0000
Subject: Re: [PATCH 0 of 3] cleanups for efi.c
Message-Id: <20080129163133.GC1289@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <patchbomb.1199849375@jenkins.nashua>
In-Reply-To: <patchbomb.1199849375@jenkins.nashua>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

These weren't forgotten, were they?  I know they're trivial, but I'd
still like to see them appled :-)

Thanks,
Aron

-----Original Message-----
From: Aron Griffis [mailto:aron@hp.com]
Sent: Tuesday, January 08, 2008 10:29 PM
Subject: [PATCH 0 of 3] cleanups for efi.c


These trivial patches clean up efi.c.  There are no functionality
changes introduced by these patches.  This submission incorporates
feedback from my last post on Dec 12:

- merge forward to current tree
- Tony suggested leaving efi_guidcmp() alone
- Peter suggested punctuation/grammar fixes

1/3 - fix whitespace, fit in 80 columns, repair some indentation
2/3 - spelling and punctuation
3/3 - add /* never reached */ to a couple returns

1 file changed, 273 insertions(+), 230 deletions(-)
arch/ia64/kernel/efi.c |  503 ++++++++++++++++++++++++++----------------------


-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

