From: Rik van Riel <riel@conectiva.com.br>
Date: Mon, 30 Jul 2001 22:15:42 +0000
Subject: Re: [Linux-ia64] gcc 3.0 question: ILP32 mode ?
Message-Id: <marc-linux-ia64-105590693005957@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 27 Jul 2001, Jose Luu wrote:
> Hans wrote:
> > Supporting another ABI is very expensive.  The tradeoffs for HP/UX are
> > different.
>
> I am sure I don't realize how expensive it is, but it seems
> worth investigating, for our purposes we need the libc and
> libX11, little else.

And the compiler, the linker, support for the ABI in
the kernel, system call wrappers, etc...

Oh, and of course all of these will need to be maintained
across 25 different releases the next 10 years - in random
combinations of version numbers.

I'm sure you have the time to implement all of the above
right now, but do you have the time to maintain it for the
next decade ?

(oh, and with "you" I really do mean YOU, unless of course
you hire somebody else to take care of it for you ;))

cheers,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/


