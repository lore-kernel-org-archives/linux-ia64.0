From: Jes Sorensen <jes@linuxcare.com>
Date: Mon, 31 Jul 2000 22:34:42 +0000
Subject: Re: [Linux-ia64] integer -> pointer question
Message-Id: <marc-linux-ia64-105590678205251@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Michael" = Michael Madore <mmadore@turbolinux.com> writes:

Michael> On the other hand, it is not unusual to see void pointers
Michael> used for storing integers, and the programmer has no
Michael> intention of ever de-referencing the pointer.  Glib and GTK+
Michael> make extensive use of this technique.

Michael> The problem is that this generates the same warning messages
Michael> as the first case, and it makes it more difficult to know if
Michael> a particular package has portability problems.

Michael> My question is: Is there a way to assign integers to void
Michael> pointers without triggering warnings from the compiler?

Hi Michael

Storing integers in void pointers without a cast is simply broken and
nobody should do that or to be more precise you cannot expect void *
to be the same size as int.

Basically the correct solution is to LART the programmer of the bad
code.

Jes


