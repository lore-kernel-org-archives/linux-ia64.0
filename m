From: Jes Sorensen <jes@linuxcare.com>
Date: Tue, 27 Mar 2001 17:08:23 +0000
Subject: Re: [Linux-ia64] Bug in dynamic linker (glibc 2.2.2)
Message-Id: <marc-linux-ia64-105590693005358@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005357@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005357@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Francis" = Francis Galiegue <fg@mandrakesoft.com> writes:

Francis> The bug: when building qt 2.3.0, using libmng 1.0.0, when it
Francis> comes to build the designer, this error occurs when it tries
Francis> to run uic:

qt is C++, we haven't had nearly as much testing in that are.

Francis> BUG IN DYNAMIC LINKER ld.so: dl-version.c: 217:
Francis> _dl_check_map_versions: Assertion `needed != ((void *)0)'
Francis> failed!

Francis> I made a foo test program which only uses mng_version_text()
Francis> of said library, tried to link and run it and... it succeeds!

When you repor a bug like this you *must* provide a test case. Just
mailing us and saying it doesn't work is no good.

If you can provide a pre-processed file I can take a look at it. There
is no way I am going out compiling Qt on my own. You also need to tell
which toolchain version you are using.

Jes

