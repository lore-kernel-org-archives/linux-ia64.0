From: Cary Coutant <cary@cup.hp.com>
Date: Tue, 21 Oct 2003 21:57:50 +0000
Subject: Re: [RFC] Endianness and signals
Message-Id: <marc-linux-ia64-106677371825584@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106669369711349@msgid-missing>
In-Reply-To: <marc-linux-ia64-106669369711349@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The fourth case is that the application has signal handlers that
> expect to get called in the "opposite" byte-order and those are the
> ones that would break if we changed the current behavior.

Do you know of any such applications?

How likely is it that someone would code an application in such a way 
that they guarantee that a certain signal will occur only when 
executing in big-endian mode? (And, conversely, that other signals will 
occur only when executing in little-endian mode?)

If I were writing such an application, and I wanted to figure out what 
to expect when a signal handler is called, my first thought* would be 
to expect it to get called in a standard (i.e., little-endian) mode, no 
matter what. I might then test it and discover that I was wrong. At 
that point, I'd hardly consider that a definitive feature of Linux on 
IA-64; I'd be much more likely to consider it a bug, and bring it to 
someone's attention.

Of course, I realize that most people don't go through that thought 
process -- they assume that the way it works today is the way it will 
always work. I just have a hard time working up any sympathy for those 
people.

By the way, when you arm the signal handler, do you copy the function 
pointer or the function descriptor? Will the user-space code that makes 
the call to the signal handler work if you're in big-endian mode?

-cary

* Actually, my first thought would be to see if it's documented 
somewhere. But this is Linux. :-)

