From: Bill Nottingham <notting@redhat.com>
Date: Tue, 05 Dec 2000 22:17:55 +0000
Subject: Re: [Linux-ia64] Fault 26?
Message-Id: <marc-linux-ia64-105590678205792@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205788@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205788@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@hpl.hp.com) said: 
> >>>>> On Tue, 5 Dec 2000 16:53:45 -0500, Bill Nottingham <notting@redhat.com> said:
> 
>   Bill> What is fault type 26?  I'm getting a few of these recently.
> 
> It's the "NaT consumption fault".  Either buggy code is trying to eat
> a NaT value or something else goes wrong and a NaT value is created
> when it shouldn't be.

Hm. We're getting it (in cpp) when building the kernel.

Bill

