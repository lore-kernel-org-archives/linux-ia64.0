From: Davide Libenzi <davidel@xmailserver.org>
Date: Mon, 17 May 2004 16:27:08 +0000
Subject: Re: Fw: epoll oops on 2.6.x
Message-Id: <Pine.LNX.4.58.0405170925490.19557@bigblue.dev.mdolabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40A3EAF6.1000902@cs.uwaterloo.ca>
In-Reply-To: <40A3EAF6.1000902@cs.uwaterloo.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 17 May 2004, Louay Gammo wrote:

> Davide Libenzi wrote:
> 
> >On Fri, 14 May 2004, Louay Gammo wrote:
> >
> >>I did #1 and #2 and ran my original experiment. I did not get a panic but
> >>I got 0 replies from the server. So I undid the #2 and I got a kernel 
> >>panic (included below).
> >>So I am going to try to overload the server on loopback interface (I think
> >>this is what you are saying) and I will let you know of the results.
> >>
> >>I am enclosing the kernel config just in case that might clue anyone to 
> >>a configuration problem.
> >>    
> >>
> >
> >Can you try also to run the appended test program, like:
> >
> ># ./pipetest -n 2000 -a 3 -w 20000
> >
> >  
> >
> Ok, and I got this:
> ~/pipetest> ./a.out -n 2000 -a 3 -w 20000
> 3.917762
> 3.868220
> 3.860521
> 3.855072
> 3.853522
> 3.853422
> 3.854822
> 3.853072
> 3.853972
> 3.854972
> 3.856022
> 3.855172
> 3.856572
> 3.860621
> 3.861171
> 3.855672
> 
> Does this help?

This proves that it works fine with pipes. Can you try to put your server 
listening on localhost and load it thru localhost?



- Davide

