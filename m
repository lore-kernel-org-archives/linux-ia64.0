From: Roy Dragseth <royd@cc.uit.no>
Date: Sun, 12 Jan 2003 19:53:42 +0000
Subject: Re: [Linux-ia64] Re: Re: disabling nics using boot options.
Message-Id: <marc-linux-ia64-105590709805667@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805661@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805661@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Saturday 11 January 2003 01:06, Grant Grundler wrote:
> Roy Dragseth wrote:
> > But, if I put in a sleep 60 after ifup in the /etc/init.d/network
> > script, everything is ok.
>
> IIRC, dhclient forks and lets the child/fork do the actual work.
> With sleep 60, seems the new process would run immediately.
> Perhaps the problem is an issue with the dhclient child-process
> not getting executed before something else attempts to use the
> interface?

Well, as I said in a later mail the problem maninifests itself even if I us=
e=20
static ip.

> You have time to try "sleep 1" or "sleep 5"

No, I haven't.

>
> > To me, an illiterate when it comes to drivers and network hardware, it
> > seems like the network card (or driver) needs some time to get ready to
> > serve after beeing configured.  Again, the problem only occurs when
> > running Gbit, it never shows up when I connect to a 100Mbit switch.
>
> hmmm...I don't know anything about Gbit vs 100Bt negotiations, but maybe
> the Gbit negotiation is just taking longer?
>

Yes, that migth be the case.

r.

--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8, Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no


