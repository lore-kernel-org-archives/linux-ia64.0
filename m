From: Ville Herva <vherva@niksula.hut.fi>
Date: Fri, 07 Dec 2001 17:03:56 +0000
Subject: Re: [Linux-ia64] eepro100 hang?
Message-Id: <marc-linux-ia64-105590698805646@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805637@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805637@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Dec 07, 2001 at 08:16:43AM -0800, you [David Mosberger] claimed:
> >>>>> On Fri, 7 Dec 2001 10:10:07 +0200, Ville Herva <vherva@niksula.hut.fi> said:
> 
>   Ville> at http://linuxia64.org/todo.html, it says EEPro100 ? Hangs
>   Ville> on >180MB xfers
> 
>   Ville> Is this supposed to be fixed?
> 
> I don't think the workstations (i2000) ever suffered from this problem.
> It appeared only on the 4-way server.

Ok.

> For what it's worth, I use an i2000 with an eepro100 all the time and
> haven't seen any hangs.  Of course, that doesn't prove anything; just
> a data point...

Yep. I haven't seen anything strange since I got Mandrake installed. It was
just during installation. Could've been Mandrake trakX problem, but it
seemed strange - it tried to read(2) 16kB from the socket and only got one
byte at a time. And that took half a second each time...



-- v --

v@iki.fi

