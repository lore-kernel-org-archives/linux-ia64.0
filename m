From: Grant Grundler <grundler@cup.hp.com>
Date: Sat, 11 Jan 2003 00:06:52 +0000
Subject: Re: [Linux-ia64] Re: Re: disabling nics using boot options.
Message-Id: <marc-linux-ia64-105590709805665@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805661@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805661@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Roy Dragseth wrote:
> But, if I put in a sleep 60 after ifup in the /etc/init.d/network 
> script, everything is ok.  

IIRC, dhclient forks and lets the child/fork do the actual work.
With sleep 60, seems the new process would run immediately.
Perhaps the problem is an issue with the dhclient child-process 
not getting executed before something else attempts to use the
interface?
You have time to try "sleep 1" or "sleep 5"?


> To me, an illiterate when it comes to drivers and network hardware, it seems 
> like the network card (or driver) needs some time to get ready to serve after
> beeing configured.  Again, the problem only occurs when running Gbit, it 
> never shows up when I connect to a 100Mbit switch.

hmmm...I don't know anything about Gbit vs 100Bt negotiations, but maybe
the Gbit negotiation is just taking longer?

grant

