From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 02 May 2001 19:18:07 +0000
Subject: Re: [Linux-ia64] ld --relax should be on by default
Message-Id: <marc-linux-ia64-105590693005513@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005510@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005510@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Are you running into this problem using the SGI compiler with the GNU linker?
That wasn't clear from your message.  That effects the kind of solution we
need, since fixing gcc to always pass --relax to the linker isn't going to
fix your problem.

Jim

