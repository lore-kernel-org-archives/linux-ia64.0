From: Davide Libenzi <davidel@xmailserver.org>
Date: Fri, 14 May 2004 01:58:00 +0000
Subject: Re: Fw: epoll oops on 2.6.x
Message-Id: <Pine.LNX.4.58.0405131844560.12980@bigblue.dev.mdolabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40A3EAF6.1000902@cs.uwaterloo.ca>
In-Reply-To: <40A3EAF6.1000902@cs.uwaterloo.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 13 May 2004, Randy.Dunlap wrote:

> 
> Davide,
> >From the linux-ia64 mailing list, in case you didn't see it.....
> 
> Begin forwarded message:
> 
> Date: Thu, 13 May 2004 17:39:02 -0400
> From: Louay Gammo <lgammo@cs.uwaterloo.ca>
> To: linux-ia64@vger.kernel.org
> Subject: epoll oops on 2.6.x
> 
> 
> Hi,
> 
> I keep getting these oopses and kernel panics when I overload my 
> Itanium-2 box with http requests. I had these
> oopses in 2.6.1 through 2.6.5 and it is consistently happening while 
> using epoll, but not select. Also, these oopses
> happen only on IA-64.
> 
> I am including some of these oopses as attachements. I am not sure what 
> the 'normal' bug reporting mechanism is
> for IA-64 kernels.

I'm getting this from Randy, since I was not subscribed to linux-ia64. Now 
I am. I took a quick look at it and so far the clue is completely missing. 
Only one of the oops actually happen inside epoll, even if the other ones 
comes typically from __wake_up_common() (others from vfs_read(), that is 
quite unrelated), that let me think that it might be epoll related (epoll 
has a wait queue item dropped in). Can you try a few experiments?

1) Disable pre-emption (if enabled)
2) Load the server thru loopback
3) #define DEBUG_EPOLL 10

(Your machine does not look too much in shape looking at INIT messages 
though)



- Davide

