From: Bill Nottingham <notting@redhat.com>
Date: Wed, 21 Feb 2001 19:15:55 +0000
Subject: Re: [Linux-ia64] Re: Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005181@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005178@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005178@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@hpl.hp.com) said: 
>   Bill> 2P BigSur, using UP 010131 kernel, on top of 2.4.1-ac16
>   Bill> (certainly, this could cause problems).
> 
> Thanks for the info.  I haven't looked at or tried the ac patches, so
> I don't know whether they are safe for IA-64.

There's a definite SMP problem currently (not a hang, just
bizarre behavior); this is the UP kernel I'm seeing the hangs on.

> By completely dead you mean that it responded neither on the console
> nor to network pings?

Yes. 

>   Bill> Since it has happened when I wasn't watching the machine
>   Bill> intently, it's entirely possible it's related to when it turns
>   Bill> off the monitor via DPMS, but that would just be weird.
> 
> Don't know if that has been tested.  Any of the X experts know?

This is DPMS on the console, actually; I was not in X for either
of the hangs.

Bill

