From: Simon Derr <Simon.Derr@bull.net>
Date: Thu, 25 Jan 2007 09:12:00 +0000
Subject: Re: Spinlock bug??
Message-Id: <Pine.LNX.4.61.0701251002490.11682@openx3.frec.bull.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <003e01c73fd8$6a46f730$7401a8c0@Maelstrom>
In-Reply-To: <003e01c73fd8$6a46f730$7401a8c0@Maelstrom>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>    Hi all;
>    I'm working on a Bull - 8 way ia64 system running a RedHat variant of
> 2.6.17.
>    I keep getting a spin lock bug and dump , attached.

Hello,

If you are running a Bull Linux kernel, I suggest that you contact 
directly Bull for this kind of issues. We have added a few custom patches 
that could hardly be adressed by other people from this list.

That being said, I'm going to see what's going on in this particular case.
You're probably right.

	Simon.



