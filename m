From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 13 May 2003 02:09:17 +0000
Subject: [Linux-ia64] Re: 2.5.69 process.c: cpu_idle() cleanup
Message-Id: <marc-linux-ia64-105590723705747@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705738@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705738@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> OK, I can probably live with that argument.  However, let's
David> make it a platform vector then (which I was opposed to back
David> when) and make it a single function (e.g., "mark_idle"), which
David> takes an "idleness" argument.

Hi David,

It was actually a deliberate decision of mine to not make it a machine
vector, because this was meant to be an optional feature. With a
machine vector one always ends up calling a dummy function on
platforms that do not wish to do anything here.

I'll be happy to change it over to a machine vector if you still
prefer, let me know.

Cheers,
Jes

