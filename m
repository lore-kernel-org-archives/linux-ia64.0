From: Matthew Wilcox <willy@debian.org>
Date: Wed, 23 Apr 2003 15:01:07 +0000
Subject: Re: [Linux-ia64] RT Timers problem
Message-Id: <marc-linux-ia64-105590723705589@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705588@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705588@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 23, 2003 at 07:54:04AM -0700, Steve Woodruff wrote:
> 1. RT signals RTMIN, RTMIN+1, RTMIN+2 are not being
>    delivered.  I created a simple test case that sets
>    an interval timer set to fire once per second, 
>    but the signal never arrives!  When i use RTMIN+3
>    or greater, then the code works fine.  I can 
>    provide the test code to anyone who is interested
>    in trying it out on their system.

Aren't these used by libc for thread management purposes?  RH uses NPTL
so it ses different methods.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

